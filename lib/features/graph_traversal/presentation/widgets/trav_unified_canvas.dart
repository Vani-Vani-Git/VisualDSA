import 'dart:math';
import 'package:flutter/material.dart';
import '../models/trav_graph_model.dart';

// ── Internal draw models ──────────────────────────────────────────────────────
class _DV {
  int id; String label; Offset pos;
  _DV({required this.id, required this.label, required this.pos});
  _DV copy() => _DV(id: id, label: label, pos: pos);
}
class _DE {
  int fromId, toId;
  _DE({required this.fromId, required this.toId});
  _DE copy() => _DE(fromId: fromId, toId: toId);
}
class _Snap {
  final List<_DV> v; final List<_DE> e; final int nxt;
  _Snap({required this.v, required this.e, required this.nxt});
}

// ── TravUnifiedCanvas ─────────────────────────────────────────────────────────
class TravUnifiedCanvas extends StatefulWidget {
  final TravGraphProperties props;
  final TravAnimStep? animStep;
  final String? activeAlgo; // 'bfs' | 'dfs'
  final void Function(TravGraphModel) onGraphReady;

  const TravUnifiedCanvas({
    super.key,
    required this.props,
    required this.onGraphReady,
    this.animStep,
    this.activeAlgo,
  });

  @override
  State<TravUnifiedCanvas> createState() => TravUnifiedCanvasState();
}

class TravUnifiedCanvasState extends State<TravUnifiedCanvas> {
  bool _drawMode = false;
  final List<_DV> _verts = [];
  final List<_DE> _edges = [];
  int _nextId = 0;
  int? _selId;
  int? _dragEdgeFrom;
  Offset? _dragPos;
  bool _isDraggingEdge = false;
  final List<_Snap> _undo = [];
  final List<_Snap> _redo = [];
  static const double _r = 22.0;

  void loadGraph(TravGraphModel g) {
    setState(() {
      _drawMode = false; _verts.clear(); _edges.clear();
      _nextId = 0; _selId = null; _dragEdgeFrom = null;
      _dragPos = null; _isDraggingEdge = false;
      _undo.clear(); _redo.clear();
      for (final v in g.vertices) {
        _verts.add(_DV(id: v.id, label: v.label, pos: v.position));
        if (v.id >= _nextId) _nextId = v.id + 1;
      }
      for (final e in g.edges) _edges.add(_DE(fromId: e.from, toId: e.to));
    });
    _emit();
  }

  void _snap() {
    _undo.add(_Snap(
      v: _verts.map((v) => v.copy()).toList(),
      e: _edges.map((e) => e.copy()).toList(),
      nxt: _nextId,
    ));
    _redo.clear();
    if (_undo.length > 60) _undo.removeAt(0);
  }

  void _doUndo() {
    if (_undo.isEmpty) return;
    _redo.add(_Snap(v: _verts.map((v) => v.copy()).toList(),
        e: _edges.map((e) => e.copy()).toList(), nxt: _nextId));
    _restore(_undo.removeLast());
  }

  void _doRedo() {
    if (_redo.isEmpty) return;
    _undo.add(_Snap(v: _verts.map((v) => v.copy()).toList(),
        e: _edges.map((e) => e.copy()).toList(), nxt: _nextId));
    _restore(_redo.removeLast());
  }

  void _restore(_Snap s) => setState(() {
    _verts..clear()..addAll(s.v.map((v) => v.copy()));
    _edges..clear()..addAll(s.e.map((e) => e.copy()));
    _nextId = s.nxt; _selId = null;
    _dragEdgeFrom = null; _dragPos = null; _isDraggingEdge = false;
  });

  _DV? _vertAt(Offset p) {
    for (final v in _verts.reversed) {
      if ((v.pos - p).distance <= _r + 8) return v;
    }
    return null;
  }

  bool _edgeExists(int a, int b) {
    if (widget.props.directed) return _edges.any((e) => e.fromId == a && e.toId == b);
    return _edges.any((e) => (e.fromId==a&&e.toId==b)||(e.fromId==b&&e.toId==a));
  }

  void _editLabel(_DV vertex) async {
    final ctrl = TextEditingController(text: vertex.label);
    ctrl.selection = TextSelection(baseOffset: 0, extentOffset: ctrl.text.length);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Node Label',
            style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14,
                fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        content: TextField(
          controller: ctrl, autofocus: true, maxLength: 4,
          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 20, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            hintText: 'Label (max 4 chars)',
            hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 12),
            counterStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 10),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3B82F6))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF60A5FA), width: 2)),
          ),
          onSubmitted: (v) { if (v.trim().isNotEmpty) Navigator.pop(context, v.trim()); },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B949E), fontFamily: 'monospace'))),
          TextButton(onPressed: () {
            final t = ctrl.text.trim();
            if (t.isNotEmpty) Navigator.pop(context, t);
          }, child: const Text('Save', style: TextStyle(color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) { setState(() => vertex.label = result); _emit(); }
  }

  void _onTapDown(TapDownDetails d) {
    if (!_drawMode) return;
    final p = d.localPosition;
    final vHit = _vertAt(p);
    if (vHit == null) {
      _snap();
      setState(() { _selId = null; _verts.add(_DV(id: _nextId, label: '$_nextId', pos: p)); _nextId++; });
      _emit();
    } else if (_selId == null) {
      setState(() => _selId = vHit.id);
    } else if (_selId == vHit.id) {
      setState(() => _selId = null);
      _editLabel(vHit);
    } else {
      final from = _selId!;
      if (!_edgeExists(from, vHit.id)) {
        _snap();
        setState(() { _edges.add(_DE(fromId: from, toId: vHit.id)); _selId = null; });
        _emit();
      } else { setState(() => _selId = null); }
    }
  }

  void _onLongPressStart(LongPressStartDetails d) {
    if (!_drawMode) return;
    final vHit = _vertAt(d.localPosition);
    if (vHit != null) {
      _snap();
      setState(() { _isDraggingEdge = true; _dragEdgeFrom = vHit.id; _dragPos = d.localPosition; });
    }
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails d) {
    if (!_drawMode || !_isDraggingEdge) return;
    setState(() => _dragPos = d.localPosition);
  }

  void _onLongPressEnd(LongPressEndDetails d) {
    if (!_drawMode || !_isDraggingEdge) return;
    final vHit = _vertAt(d.localPosition);
    if (vHit != null && vHit.id != _dragEdgeFrom) {
      final from = _dragEdgeFrom!;
      if (!_edgeExists(from, vHit.id)) { setState(() => _edges.add(_DE(fromId: from, toId: vHit.id))); _emit(); }
    }
    setState(() { _isDraggingEdge = false; _dragEdgeFrom = null; _dragPos = null; });
  }

  void _clear() {
    _snap();
    setState(() { _verts.clear(); _edges.clear(); _nextId = 0; _selId = null; });
  }

  void _emit() {
    if (_verts.isEmpty) return;
    widget.onGraphReady(TravGraphModel(
      vertices: _verts.map((v) => TravVertex(id: v.id, label: v.label, position: v.pos)).toList(),
      edges: _edges.map((e) => TravEdge(from: e.fromId, to: e.toId)).toList(),
      properties: widget.props,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasGraph = _verts.isNotEmpty;
    final inAlgoMode = widget.animStep != null;
    final accentColor = widget.activeAlgo == 'dfs'
        ? const Color(0xFF9333EA)
        : const Color(0xFF3B82F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Draw / Random buttons
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () { if (inAlgoMode) return; setState(() => _drawMode = !_drawMode); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: _drawMode ? const Color(0xFF9333EA) : const Color(0xFF30363D),
                  width: _drawMode ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.gesture,
                    color: _drawMode ? const Color(0xFF9333EA) : const Color(0xFF8B949E), size: 16),
                const SizedBox(width: 6),
                Text('Draw', style: TextStyle(
                    color: _drawMode ? const Color(0xFF9333EA) : const Color(0xFFE2E8F0),
                    fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
              ]),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: GestureDetector(
            onTap: inAlgoMode ? null : () {
              final size = MediaQuery.of(context).size;
              loadGraph(TravGraphModel.random(widget.props, Size(size.width - 24, 280)));
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.shuffle,
                    color: inAlgoMode ? const Color(0xFF374151) : const Color(0xFF8B949E), size: 16),
                const SizedBox(width: 6),
                Text('Random', style: TextStyle(
                    color: inAlgoMode ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
                    fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
              ]),
            ),
          )),
        ]),

        const SizedBox(height: 6),

        // Draw mode toolbar
        if (_drawMode && !inAlgoMode) ...[
          Wrap(spacing: 6, children: [
            _chip(widget.props.directed ? '→ Directed' : '— Undirected', const Color(0xFF3B82F6)),
          ]),
          const SizedBox(height: 4),
          const Text(
            'Tap empty → add node  ·  Tap two nodes → add edge\n'
            'Double-tap node → edit label  ·  Long-press drag → draw edge',
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 9, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 6),
          Row(children: [
            _toolBtn(Icons.undo, _undo.isNotEmpty ? _doUndo : null),
            const SizedBox(width: 6),
            _toolBtn(Icons.redo, _redo.isNotEmpty ? _doRedo : null),
            const SizedBox(width: 6),
            _toolBtn(Icons.delete_outline, _verts.isNotEmpty ? _clear : null),
            const Spacer(),
            GestureDetector(
              onTap: hasGraph ? () { _emit(); setState(() => _drawMode = false); } : null,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: hasGraph ? const Color(0xFF2563EB) : const Color(0xFF1C2128),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check,
                      color: hasGraph ? Colors.white : const Color(0xFF374151), size: 14),
                  const SizedBox(width: 4),
                  Text('Done', style: TextStyle(
                      color: hasGraph ? Colors.white : const Color(0xFF374151),
                      fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 6),
        ],

        // Canvas
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            border: Border.all(
              color: _drawMode
                  ? const Color(0xFF9333EA).withOpacity(0.5)
                  : inAlgoMode
                      ? accentColor.withOpacity(0.4)
                      : const Color(0xFF21262D),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _verts.isEmpty && !_drawMode
                ? const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.account_tree_outlined, color: Color(0xFF374151), size: 34),
                      SizedBox(height: 10),
                      Text(
                        'Press Draw to sketch a graph\nor Random to generate one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ]),
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: _onTapDown,
                    onLongPressStart: _onLongPressStart,
                    onLongPressMoveUpdate: _onLongPressMoveUpdate,
                    onLongPressEnd: _onLongPressEnd,
                    child: CustomPaint(
                      size: const Size(double.infinity, 280),
                      painter: _TravPainter(
                        verts: _verts, edges: _edges,
                        selId: _selId, dragFrom: _dragEdgeFrom,
                        dragPos: _dragPos, isDragging: _isDraggingEdge,
                        isDirected: widget.props.directed,
                        r: _r, animStep: widget.animStep,
                        drawMode: _drawMode,
                      ),
                    ),
                  ),
          ),
        ),

        // Info strip
        if (hasGraph && !_drawMode)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(children: [
              Text(
                '${_verts.length}V · ${_edges.length}E'
                '${widget.props.directed ? " · directed" : " · undirected"}',
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10, fontFamily: 'monospace'),
              ),
              const Spacer(),
              if (inAlgoMode) ...[
                _legend(const Color(0xFFF59E0B), 'Current'),
                const SizedBox(width: 8),
                _legend(const Color(0xFF3B82F6), 'In Queue'),
                const SizedBox(width: 8),
                _legend(const Color(0xFF22C55E), 'Visited'),
              ],
            ]),
          ),
      ],
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      border: Border.all(color: color.withOpacity(0.4)),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontFamily: 'monospace')),
  );

  Widget _toolBtn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon,
          color: onTap == null ? const Color(0xFF374151) : const Color(0xFFE2E8F0), size: 14),
    ),
  );

  Widget _legend(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(color: color, fontSize: 9, fontFamily: 'monospace')),
  ]);
}

// ── Painter ───────────────────────────────────────────────────────────────────
class _TravPainter extends CustomPainter {
  final List<_DV> verts; final List<_DE> edges;
  final int? selId; final int? dragFrom; final Offset? dragPos;
  final bool isDragging; final bool isDirected; final double r;
  final TravAnimStep? animStep; final bool drawMode;

  _TravPainter({
    required this.verts, required this.edges, this.selId, this.dragFrom,
    this.dragPos, this.isDragging = false, required this.isDirected,
    required this.r, this.animStep, required this.drawMode,
  });

  _DV? _v(int id) { for (final v in verts) { if (v.id == id) return v; } return null; }

  static String _ek(int a, int b, bool d) => d ? '$a->$b' : (a < b ? '$a-$b' : '$b-$a');

  bool _isTreeEdge(int a, int b) => animStep?.treeEdges.contains(_ek(a, b, isDirected)) ?? false;
  bool _isCrossEdge(int a, int b) => animStep?.crossEdges.contains(_ek(a, b, isDirected)) ?? false;
  bool _isActiveEdge(int a, int b) =>
      animStep != null && animStep!.fromNode == a && animStep!.toNode == b ||
      (!isDirected && animStep != null && animStep!.fromNode == b && animStep!.toNode == a);

  void _drawLine(Canvas canvas, Offset p1, Offset p2, Color color, double w) {
    canvas.drawLine(p1, p2, Paint()..color = color..strokeWidth = w
        ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }

  Offset _borderPt(Offset c, Offset t) {
    final d = t - c; final l = d.distance;
    return l < 0.001 ? c : c + d / l * (r + 2);
  }

  void _arrowHead(Canvas canvas, Offset s, Offset e, Color color) {
    const aLen = 12.0; const aAng = 0.42;
    final angle = atan2(e.dy - s.dy, e.dx - s.dx);
    final p1 = e + Offset(cos(angle + pi - aAng) * aLen, sin(angle + pi - aAng) * aLen);
    final p2 = e + Offset(cos(angle + pi + aAng) * aLen, sin(angle + pi + aAng) * aLen);
    canvas.drawPath(
      Path()..moveTo(e.dx, e.dy)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..close(),
      Paint()..color = color..style = PaintingStyle.fill,
    );
  }

  void _label(Canvas canvas, String text, Offset c,
      {Color color = Colors.white, double fs = 12, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text,
          style: TextStyle(color: color, fontSize: fs,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final isAlgo = animStep != null;

    // ── Edges ──────────────────────────────────────────────────────────────
    for (final e in edges) {
      final a = _v(e.fromId); final b = _v(e.toId);
      if (a == null || b == null) continue;

      Color ec; double sw;
      if (isAlgo) {
        if (_isTreeEdge(e.fromId, e.toId)) {
          ec = const Color(0xFF22C55E); sw = 3.0;
        } else if (_isActiveEdge(e.fromId, e.toId)) {
          ec = const Color(0xFFF59E0B); sw = 2.5;
        } else if (_isCrossEdge(e.fromId, e.toId)) {
          ec = const Color(0xFFEF4444).withOpacity(0.5); sw = 1.5;
        } else {
          ec = const Color(0xFF374151); sw = 1.8;
        }
      } else {
        ec = const Color(0xFF60A5FA); sw = 2.0;
      }

      if (isDirected) {
        final s = _borderPt(a.pos, b.pos);
        final end = _borderPt(b.pos, a.pos);
        if ((end - s).distance > 2) {
          _drawLine(canvas, s, end, ec, sw);
          _arrowHead(canvas, s, end, ec);
        }
      } else {
        _drawLine(canvas, a.pos, b.pos, ec, sw);
      }
    }

    // ── Drag preview ───────────────────────────────────────────────────────
    if (!isAlgo && isDragging && dragFrom != null && dragPos != null) {
      final src = _v(dragFrom!);
      if (src != null) {
        _DV? snap;
        for (final v in verts) {
          if (v.id != dragFrom && (v.pos - dragPos!).distance <= r + 10) { snap = v; break; }
        }
        _drawLine(canvas, src.pos, snap?.pos ?? dragPos!,
            const Color(0xFF4ADE80).withOpacity(0.85), 2.2);
        if (snap != null) {
          canvas.drawCircle(snap.pos, r + 8,
              Paint()..color = const Color(0xFF4ADE80).withOpacity(0.22)..style = PaintingStyle.fill);
        }
      }
    }

    // ── Vertices ───────────────────────────────────────────────────────────
    for (final v in verts) { _drawVertex(canvas, v, isAlgo); }

    // ── Visit order badges ─────────────────────────────────────────────────
    if (isAlgo) {
      final order = animStep!.visitOrder;
      for (int i = 0; i < order.length; i++) {
        final dv = _v(order[i]);
        if (dv == null) continue;
        final badgePos = Offset(dv.pos.dx + r - 2, dv.pos.dy - r + 2);
        canvas.drawCircle(badgePos, 9,
            Paint()..color = const Color(0xFF22C55E));
        canvas.drawCircle(badgePos, 9,
            Paint()..color = const Color(0xFF0F1117)..style = PaintingStyle.stroke..strokeWidth = 1.5);
        _label(canvas, '${i + 1}', badgePos,
            color: Colors.white, fs: 8, bold: true);
      }
    }
  }

  void _drawVertex(Canvas canvas, _DV v, bool isAlgo) {
    Color fill, stroke, textColor;

    if (isAlgo) {
      final step = animStep!;
      final isCurrent = v.id == step.currentNode;
      final isVisited = step.visited.contains(v.id);
      final isInQueue = step.inQueue.contains(v.id);
      final isActive = v.id == step.fromNode || v.id == step.toNode;
      final isDone = step.type == TravStepType.done;

      if (isDone && isVisited) {
        fill = const Color(0xFF22C55E).withOpacity(0.28);
        stroke = const Color(0xFF22C55E);
        textColor = const Color(0xFF4ADE80);
      } else if (isCurrent) {
        fill = const Color(0xFFF59E0B).withOpacity(0.30);
        stroke = const Color(0xFFF59E0B);
        textColor = const Color(0xFFFBBF24);
        // Pulsing outer ring
        canvas.drawCircle(v.pos, r + 8,
            Paint()..color = const Color(0xFFF59E0B).withOpacity(0.18)..style = PaintingStyle.fill);
        canvas.drawCircle(v.pos, r + 8,
            Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 1.5..style = PaintingStyle.stroke);
      } else if (isVisited) {
        fill = const Color(0xFF22C55E).withOpacity(0.22);
        stroke = const Color(0xFF22C55E);
        textColor = const Color(0xFF4ADE80);
      } else if (isInQueue) {
        fill = const Color(0xFF3B82F6).withOpacity(0.22);
        stroke = const Color(0xFF3B82F6);
        textColor = const Color(0xFF93C5FD);
      } else if (isActive && !isVisited) {
        fill = const Color(0xFF9333EA).withOpacity(0.20);
        stroke = const Color(0xFFA855F7);
        textColor = const Color(0xFFD8B4FE);
      } else {
        fill = const Color(0xFF1D4ED8).withOpacity(0.12);
        stroke = const Color(0xFF374151);
        textColor = const Color(0xFF6B7280);
      }
    } else {
      final isSel = v.id == selId;
      final isDragSrc = v.id == dragFrom;
      if (isSel) {
        fill = const Color(0xFFF97316).withOpacity(0.22);
        stroke = const Color(0xFFF97316);
        textColor = const Color(0xFFF97316);
        canvas.drawCircle(v.pos, r + 8,
            Paint()..color = const Color(0xFFF97316).withOpacity(0.15)..style = PaintingStyle.fill);
      } else if (isDragSrc) {
        fill = const Color(0xFF4ADE80).withOpacity(0.18);
        stroke = const Color(0xFF4ADE80);
        textColor = const Color(0xFF4ADE80);
      } else {
        fill = const Color(0xFF1D4ED8).withOpacity(0.20);
        stroke = const Color(0xFF3B82F6);
        textColor = const Color(0xFFE2E8F0);
      }
    }

    canvas.drawCircle(v.pos, r, Paint()..color = fill);
    canvas.drawCircle(v.pos, r, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 2.0);
    _label(canvas, v.label, v.pos, color: textColor, fs: 13, bold: true);
  }

  @override
  bool shouldRepaint(_TravPainter old) => true;
}