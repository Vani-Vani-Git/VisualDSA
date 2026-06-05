import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sp_graph_model.dart';

// ── Internal draw vertex/edge ─────────────────────────────────────────────────
class _DV {
  int id;
  String label;
  Offset pos;
  _DV({required this.id, required this.label, required this.pos});
  _DV copy() => _DV(id: id, label: label, pos: pos);
}

class _DE {
  int fromId;
  int toId;
  int weight;
  _DE({required this.fromId, required this.toId, this.weight = 1});
  _DE copy() => _DE(fromId: fromId, toId: toId, weight: weight);
}

class _Snap {
  final List<_DV> verts;
  final List<_DE> edges;
  final int nextId;
  _Snap({required this.verts, required this.edges, required this.nextId});
}

// ── SpUnifiedCanvas ───────────────────────────────────────────────────────────
// Single canvas that handles: Draw mode, Random display, and Algorithm vis.
class SpUnifiedCanvas extends StatefulWidget {
  final SpGraphProperties props;
  // Algo visualization state — null means show draw/graph only
  final SpAnimStep? animStep;
  final int? srcNode;
  final void Function(SpGraphModel) onGraphReady;

  const SpUnifiedCanvas({
    super.key,
    required this.props,
    required this.onGraphReady,
    this.animStep,
    this.srcNode,
  });

  @override
  State<SpUnifiedCanvas> createState() => SpUnifiedCanvasState();
}

class SpUnifiedCanvasState extends State<SpUnifiedCanvas> {
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

  // ── Public: load a SpGraphModel into the canvas (from Random) ───────────────
  void loadGraph(SpGraphModel g) {
    setState(() {
      _drawMode = false;
      _verts.clear();
      _edges.clear();
      _nextId = 0;
      _selId = null;
      _dragEdgeFrom = null;
      _dragPos = null;
      _isDraggingEdge = false;
      _undo.clear();
      _redo.clear();

      for (final v in g.vertices) {
        _verts.add(_DV(id: v.id, label: v.label, pos: v.position));
        if (v.id >= _nextId) _nextId = v.id + 1;
      }
      for (final e in g.edges) {
        _edges.add(_DE(fromId: e.from, toId: e.to, weight: e.weight));
      }
    });
    _emit();
  }

  // ── Undo/redo ────────────────────────────────────────────────────────────────
  void _snap() {
    _undo.add(_Snap(
      verts: _verts.map((v) => v.copy()).toList(),
      edges: _edges.map((e) => e.copy()).toList(),
      nextId: _nextId,
    ));
    _redo.clear();
    if (_undo.length > 60) _undo.removeAt(0);
  }

  void _doUndo() {
    if (_undo.isEmpty) return;
    _redo.add(_Snap(
      verts: _verts.map((v) => v.copy()).toList(),
      edges: _edges.map((e) => e.copy()).toList(),
      nextId: _nextId,
    ));
    _restore(_undo.removeLast());
  }

  void _doRedo() {
    if (_redo.isEmpty) return;
    _undo.add(_Snap(
      verts: _verts.map((v) => v.copy()).toList(),
      edges: _edges.map((e) => e.copy()).toList(),
      nextId: _nextId,
    ));
    _restore(_redo.removeLast());
  }

  void _restore(_Snap s) => setState(() {
        _verts
          ..clear()
          ..addAll(s.verts.map((v) => v.copy()));
        _edges
          ..clear()
          ..addAll(s.edges.map((e) => e.copy()));
        _nextId = s.nextId;
        _selId = null;
        _dragEdgeFrom = null;
        _dragPos = null;
        _isDraggingEdge = false;
      });

  // ── Helpers ──────────────────────────────────────────────────────────────────
  _DV? _vertAt(Offset p) {
    for (final v in _verts.reversed) {
      if ((v.pos - p).distance <= _r + 8) return v;
    }
    return null;
  }

  _DE? _edgeAt(Offset p) {
    for (final e in _edges) {
      final a = _vById(e.fromId);
      final b = _vById(e.toId);
      if (a == null || b == null) continue;
      final mid = (a.pos + b.pos) / 2;
      if ((mid - p).distance < 22) return e;
    }
    return null;
  }

  _DV? _vById(int id) {
    for (final v in _verts) {
      if (v.id == id) return v;
    }
    return null;
  }

  bool _edgeExists(int a, int b) {
    if (widget.props.directed) {
      return _edges.any((e) => e.fromId == a && e.toId == b);
    }
    return _edges.any(
        (e) => (e.fromId == a && e.toId == b) || (e.fromId == b && e.toId == a));
  }

  // ── Weight dialog ─────────────────────────────────────────────────────────
  void _editWeight(_DE edge) async {
    final ctrl = TextEditingController(text: '${edge.weight}');
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Weight: ${edge.fromId} → ${edge.toId}',
          style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace'),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(
              color: Color(0xFFE2E8F0), fontSize: 18, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            hintText: 'Weight (1–99)',
            hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 13),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3B82F6))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF60A5FA), width: 2)),
          ),
          onSubmitted: (_) {
            final v = int.tryParse(ctrl.text.trim());
            if (v != null && v > 0) Navigator.pop(context, v);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                    color: Color(0xFF8B949E), fontFamily: 'monospace')),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              if (v != null && v > 0) Navigator.pop(context, v);
            },
            child: const Text('Set',
                style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => edge.weight = result);
      _emit();
    }
  }

  // ── Label edit dialog ─────────────────────────────────────────────────────
  void _editLabel(_DV vertex) async {
    final ctrl = TextEditingController(text: vertex.label);
    ctrl.selection =
        TextSelection(baseOffset: 0, extentOffset: ctrl.text.length);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Edit Node Label',
          style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace'),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 4,
          style: const TextStyle(
              color: Color(0xFFE2E8F0), fontSize: 20, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            hintText: 'Label (max 4 chars)',
            hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 12),
            counterStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 10),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3B82F6))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF60A5FA), width: 2)),
          ),
          onSubmitted: (v) {
            final t = v.trim();
            if (t.isNotEmpty) Navigator.pop(context, t);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                    color: Color(0xFF8B949E), fontFamily: 'monospace')),
          ),
          TextButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isNotEmpty) Navigator.pop(context, t);
            },
            child: const Text('Save',
                style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => vertex.label = result.trim());
      _emit();
    }
  }

  // ── Gesture handlers (draw mode only) ────────────────────────────────────────
  void _onTapDown(TapDownDetails d) {
    if (!_drawMode) return;
    final p = d.localPosition;

    // Weighted: tap edge midpoint to edit weight
    if (widget.props.weighted) {
      final eHit = _edgeAt(p);
      if (eHit != null) {
        _editWeight(eHit);
        return;
      }
    }

    final vHit = _vertAt(p);
    if (vHit == null) {
      // Add new vertex
      _snap();
      setState(() {
        _selId = null;
        _verts.add(_DV(id: _nextId, label: '$_nextId', pos: p));
        _nextId++;
      });
      _emit();
    } else if (_selId == null) {
      // First tap → select the vertex
      setState(() => _selId = vHit.id);
    } else if (_selId == vHit.id) {
      // Second tap on same vertex → open label editor
      setState(() => _selId = null);
      _editLabel(vHit);
    } else {
      // Connect _selId → vHit.id
      final from = _selId!;
      if (!_edgeExists(from, vHit.id)) {
        _snap();
        final newEdge = _DE(fromId: from, toId: vHit.id);
        setState(() {
          _edges.add(newEdge);
          _selId = null;
        });
        if (widget.props.weighted) {
          Future.microtask(() => _editWeight(newEdge));
        } else {
          _emit();
        }
      } else {
        setState(() => _selId = null);
      }
    }
  }

  void _onLongPressStart(LongPressStartDetails d) {
    if (!_drawMode) return;
    final vHit = _vertAt(d.localPosition);
    if (vHit != null) {
      _snap();
      setState(() {
        _isDraggingEdge = true;
        _dragEdgeFrom = vHit.id;
        _dragPos = d.localPosition;
      });
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
      if (!_edgeExists(from, vHit.id)) {
        final newEdge = _DE(fromId: from, toId: vHit.id);
        setState(() => _edges.add(newEdge));
        if (widget.props.weighted) {
          Future.microtask(() => _editWeight(newEdge));
        } else {
          _emit();
        }
      }
    }
    setState(() {
      _isDraggingEdge = false;
      _dragEdgeFrom = null;
      _dragPos = null;
    });
  }

  void _clear() {
    _snap();
    setState(() {
      _verts.clear();
      _edges.clear();
      _nextId = 0;
      _selId = null;
    });
  }

  void _emit() {
    if (_verts.isEmpty) return;
    final verts = _verts
        .map((v) => SpVertex(id: v.id, label: v.label, position: v.pos))
        .toList();
    final edges = _edges
        .map((e) => SpEdge(from: e.fromId, to: e.toId, weight: e.weight))
        .toList();
    widget.onGraphReady(
        SpGraphModel(vertices: verts, edges: edges, properties: widget.props));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hasGraph = _verts.isNotEmpty;
    final inAlgoMode = widget.animStep != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Draw / Random buttons ────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (inAlgoMode) return; // block during algo
                  setState(() => _drawMode = !_drawMode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: _drawMode
                          ? const Color(0xFF9333EA)
                          : const Color(0xFF30363D),
                      width: _drawMode ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gesture,
                          color: _drawMode
                              ? const Color(0xFF9333EA)
                              : const Color(0xFF8B949E),
                          size: 16),
                      const SizedBox(width: 6),
                      Text('Draw',
                          style: TextStyle(
                            color: _drawMode
                                ? const Color(0xFF9333EA)
                                : const Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: inAlgoMode
                    ? null
                    : () {
                        final size = MediaQuery.of(context).size;
                        final g = SpGraphModel.random(
                          widget.props,
                          Size(size.width - 24, 280),
                        );
                        loadGraph(g);
                      },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    border: Border.all(color: const Color(0xFF30363D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shuffle,
                          color: inAlgoMode
                              ? const Color(0xFF374151)
                              : const Color(0xFF8B949E),
                          size: 16),
                      const SizedBox(width: 6),
                      Text('Random',
                          style: TextStyle(
                            color: inAlgoMode
                                ? const Color(0xFF374151)
                                : const Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ── Draw mode chips + hints ──────────────────────────────────────────
        if (_drawMode && !inAlgoMode) ...[
          Wrap(
            spacing: 6,
            children: [
              _chip(
                widget.props.directed ? '→ Directed' : '— Undirected',
                const Color(0xFF3B82F6),
              ),
              if (widget.props.weighted)
                _chip('W Weighted', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap empty area → add vertex  ·  Tap two vertices → add edge'
            '\nDouble-tap vertex → edit label  ·  Long-press drag → draw edge'
            '${widget.props.weighted ? "\nTap edge midpoint → set weight" : ""}',
            style: const TextStyle(
                color: Color(0xFF4B5563), fontSize: 9, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 6),
          // Toolbar
          Row(
            children: [
              _toolBtn(Icons.undo, _undo.isNotEmpty ? _doUndo : null),
              const SizedBox(width: 6),
              _toolBtn(Icons.redo, _redo.isNotEmpty ? _doRedo : null),
              const SizedBox(width: 6),
              _toolBtn(Icons.delete_outline, _verts.isNotEmpty ? _clear : null),
              const Spacer(),
              GestureDetector(
                onTap: hasGraph
                    ? () {
                        _emit();
                        setState(() => _drawMode = false);
                      }
                    : null,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: hasGraph
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF1C2128),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check,
                          color: hasGraph ? Colors.white : const Color(0xFF374151),
                          size: 14),
                      const SizedBox(width: 4),
                      Text('Done',
                          style: TextStyle(
                            color: hasGraph ? Colors.white : const Color(0xFF374151),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],

        // ── THE SINGLE UNIFIED CANVAS ────────────────────────────────────────
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            border: Border.all(
              color: _drawMode
                  ? const Color(0xFF9333EA).withOpacity(0.5)
                  : inAlgoMode
                      ? const Color(0xFF3B82F6).withOpacity(0.4)
                      : const Color(0xFF21262D),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _verts.isEmpty && !_drawMode
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hub_outlined,
                            color: Color(0xFF374151), size: 34),
                        SizedBox(height: 10),
                        Text(
                          'Press Draw to sketch a graph\nor Random to generate one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 12,
                              fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: _onTapDown,
                    onLongPressStart: _onLongPressStart,
                    onLongPressMoveUpdate: _onLongPressMoveUpdate,
                    onLongPressEnd: _onLongPressEnd,
                    child: CustomPaint(
                      size: const Size(double.infinity, 280),
                      painter: _UnifiedPainter(
                        verts: _verts,
                        edges: _edges,
                        selId: _selId,
                        dragFrom: _dragEdgeFrom,
                        dragPos: _dragPos,
                        isDragging: _isDraggingEdge,
                        isDirected: widget.props.directed,
                        isWeighted: widget.props.weighted,
                        r: _r,
                        animStep: widget.animStep,
                        srcNode: widget.srcNode,
                        drawMode: _drawMode,
                      ),
                    ),
                  ),
          ),
        ),

        // ── Bottom info strip ───────────────────────────────────────────────
        if (hasGraph && !_drawMode)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              children: [
                Text(
                  '${_verts.length}V · ${_edges.length}E'
                  '${widget.props.directed ? " · directed" : " · undirected"}'
                  '${widget.props.weighted ? " · weighted" : ""}',
                  style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 10,
                      fontFamily: 'monospace'),
                ),
                const Spacer(),
                // Legend for algo mode
                if (inAlgoMode) ...[
                  _legend(const Color(0xFFF59E0B), 'Current'),
                  const SizedBox(width: 8),
                  _legend(const Color(0xFF22C55E), 'Updated'),
                  const SizedBox(width: 8),
                  _legend(const Color(0xFF3B82F6), 'Visited'),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style:
              TextStyle(color: color, fontSize: 10, fontFamily: 'monospace')),
    );
  }

  Widget _toolBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            color: onTap == null
                ? const Color(0xFF374151)
                : const Color(0xFFE2E8F0),
            size: 14),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 9, fontFamily: 'monospace')),
      ],
    );
  }
}

// ── Unified CustomPainter — draw mode + algo vis in one ─────────────────────
class _UnifiedPainter extends CustomPainter {
  final List<_DV> verts;
  final List<_DE> edges;
  final int? selId;
  final int? dragFrom;
  final Offset? dragPos;
  final bool isDragging;
  final bool isDirected;
  final bool isWeighted;
  final double r;
  final SpAnimStep? animStep;
  final int? srcNode;
  final bool drawMode;

  _UnifiedPainter({
    required this.verts,
    required this.edges,
    this.selId,
    this.dragFrom,
    this.dragPos,
    this.isDragging = false,
    required this.isDirected,
    required this.isWeighted,
    required this.r,
    this.animStep,
    this.srcNode,
    required this.drawMode,
  });

  _DV? _v(int id) {
    for (final v in verts) {
      if (v.id == id) return v;
    }
    return null;
  }

  bool _isPathEdge(int from, int to) {
    if (animStep == null) return false;
    return animStep!.pathEdges.contains('$from-$to') ||
        animStep!.pathEdges.contains('$to-$from');
  }

  bool _isActiveEdge(int from, int to) {
    if (animStep == null) return false;
    return (animStep!.fromNode == from && animStep!.toNode == to) ||
        (!isDirected &&
            animStep!.fromNode == to &&
            animStep!.toNode == from);
  }

  bool _isRelaxedEdge(int from, int to) {
    if (animStep == null) return false;
    return animStep!.type == SpStepType.edgeRelaxed &&
        animStep!.fromNode == from &&
        animStep!.toNode == to;
  }

  // ── Edge drawing ──────────────────────────────────────────────────────────
  void _drawEdge(Canvas canvas, Offset from, Offset to, Color color,
      double strokeW,
      {bool preview = false}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;

    if (isDirected) {
      final s = _borderPt(from, to);
      final e = _borderPt(to, from);
      if ((e - s).distance < 2) return;
      canvas.drawLine(s, e, paint);
      _arrowHead(canvas, s, e, color);
    } else {
      canvas.drawLine(from, to, paint);
    }
  }

  Offset _borderPt(Offset center, Offset towards) {
    final d = towards - center;
    final l = d.distance;
    return l < 0.001 ? center : center + d / l * (r + 2);
  }

  void _arrowHead(Canvas canvas, Offset s, Offset e, Color color) {
    const aLen = 12.0;
    const aAng = 0.42;
    final angle = atan2(e.dy - s.dy, e.dx - s.dx);
    final p1 = e +
        Offset(cos(angle + pi - aAng) * aLen, sin(angle + pi - aAng) * aLen);
    final p2 = e +
        Offset(cos(angle + pi + aAng) * aLen, sin(angle + pi + aAng) * aLen);
    canvas.drawPath(
      Path()
        ..moveTo(e.dx, e.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close(),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _weightLabel(Canvas canvas, String text, Offset pos, Color textColor) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    final bg = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: pos, width: tp.width + 8, height: tp.height + 4),
        const Radius.circular(3));
    canvas.drawRRect(bg, Paint()..color = const Color(0xFF0D1117));
    canvas.drawRRect(
        bg,
        Paint()
          ..color = textColor.withOpacity(0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _textLabel(Canvas canvas, String text, Offset c,
      {Color color = Colors.white, double fs = 12, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fs,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  // ── Main paint ────────────────────────────────────────────────────────────
  @override
  void paint(Canvas canvas, Size size) {
    final isAlgoMode = animStep != null;

    // ── Draw edges ────────────────────────────────────────────────────────
    for (final e in edges) {
      final a = _v(e.fromId);
      final b = _v(e.toId);
      if (a == null || b == null) continue;

      Color edgeColor;
      double strokeW;

      if (isAlgoMode) {
        if (_isPathEdge(e.fromId, e.toId)) {
          edgeColor = const Color(0xFF22C55E);
          strokeW = 3.0;
        } else if (_isRelaxedEdge(e.fromId, e.toId)) {
          edgeColor = const Color(0xFF4ADE80);
          strokeW = 2.5;
        } else if (_isActiveEdge(e.fromId, e.toId)) {
          edgeColor = const Color(0xFFF59E0B);
          strokeW = 2.5;
        } else {
          edgeColor = const Color(0xFF374151);
          strokeW = 1.8;
        }
      } else {
        // Draw / display mode
        edgeColor = const Color(0xFF60A5FA);
        strokeW = 2.0;
      }

      _drawEdge(canvas, a.pos, b.pos, edgeColor, strokeW);

      // Weight label
      final mid = (a.pos + b.pos) / 2;
      final dx = b.pos.dx - a.pos.dx;
      final dy = b.pos.dy - a.pos.dy;
      final len = sqrt(dx * dx + dy * dy);
      final px = len > 0 ? -dy / len * 14 : 0.0;
      final py = len > 0 ? dx / len * 14 : -14.0;
      final labelPos = Offset(mid.dx + px, mid.dy + py);

      final wColor = isAlgoMode
          ? (edgeColor == const Color(0xFF374151)
              ? const Color(0xFF6B7280)
              : const Color(0xFFE2E8F0))
          : const Color(0xFFF59E0B);

      if (isWeighted) _weightLabel(canvas, '${e.weight}', labelPos, wColor);
    }

    // ── Drag preview (draw mode) ──────────────────────────────────────────
    if (!isAlgoMode && isDragging && dragFrom != null && dragPos != null) {
      final src = _v(dragFrom!);
      if (src != null) {
        _DV? snap;
        for (final v in verts) {
          if (v.id != dragFrom && (v.pos - dragPos!).distance <= r + 10) {
            snap = v;
            break;
          }
        }
        final endPt = snap?.pos ?? dragPos!;
        _drawEdge(canvas, src.pos, endPt,
            const Color(0xFF4ADE80).withOpacity(0.85), 2.2);
        if (snap != null) {
          canvas.drawCircle(
              snap.pos,
              r + 8,
              Paint()
                ..color = const Color(0xFF4ADE80).withOpacity(0.22)
                ..style = PaintingStyle.fill);
        }
      }
    }

    // ── Draw vertices ─────────────────────────────────────────────────────
    for (final v in verts) {
      _drawVertex(canvas, v, isAlgoMode);
    }
  }

  void _drawVertex(Canvas canvas, _DV v, bool isAlgoMode) {
    Color fill, stroke, textColor;
    bool showDistBadge = false;

    if (isAlgoMode) {
      final step = animStep!;
      final isPath = step.inPath.contains(v.id);
      final isCurrent = v.id == step.currentNode;
      final isActiveNode =
          v.id == step.fromNode || v.id == step.toNode;
      final isFinalized = step.visited.contains(v.id);
      final isSrc = v.id == srcNode;

      showDistBadge = true;

      if (isPath && step.type == SpStepType.pathFound) {
        fill = const Color(0xFF22C55E).withOpacity(0.28);
        stroke = const Color(0xFF22C55E);
        textColor = const Color(0xFF22C55E);
      } else if (isCurrent) {
        fill = const Color(0xFFF59E0B).withOpacity(0.28);
        stroke = const Color(0xFFF59E0B);
        textColor = const Color(0xFFFBBF24);
      } else if (isActiveNode) {
        fill = const Color(0xFF9333EA).withOpacity(0.22);
        stroke = const Color(0xFFA855F7);
        textColor = const Color(0xFFD8B4FE);
      } else if (isFinalized) {
        fill = const Color(0xFF3B82F6).withOpacity(0.22);
        stroke = const Color(0xFF3B82F6);
        textColor = const Color(0xFF93C5FD);
      } else {
        fill = const Color(0xFF1D4ED8).withOpacity(0.12);
        stroke = const Color(0xFF374151);
        textColor = const Color(0xFF6B7280);
      }

      // Source node: outer ring
      if (isSrc) {
        canvas.drawCircle(
            v.pos,
            r + 8,
            Paint()
              ..color = const Color(0xFFF59E0B).withOpacity(0.20)
              ..style = PaintingStyle.fill);
        canvas.drawCircle(
            v.pos,
            r + 8,
            Paint()
              ..color = const Color(0xFFF59E0B)
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke);
      }
    } else {
      // Draw / display mode
      final isSel = v.id == selId;
      final isDragSrc = v.id == dragFrom;

      if (isSel) {
        fill = const Color(0xFFF97316).withOpacity(0.22);
        stroke = const Color(0xFFF97316);
        textColor = const Color(0xFFF97316);
        canvas.drawCircle(
            v.pos,
            r + 8,
            Paint()
              ..color = const Color(0xFFF97316).withOpacity(0.15)
              ..style = PaintingStyle.fill);
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
    canvas.drawCircle(
        v.pos,
        r,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);
    _textLabel(canvas, v.label, v.pos,
        color: textColor, fs: 13, bold: true);

    // Distance badge (algo mode only) — shown above the node
    if (showDistBadge) {
      final d = animStep!.dist[v.id] ?? 999999;
      final distStr = d >= 999999 ? '∞' : '$d';
      final badgePos = Offset(v.pos.dx, v.pos.dy - r - 14);
      final highlight = animStep!.inPath.contains(v.id) ||
          v.id == animStep!.currentNode;
      final badgeColor = highlight
          ? const Color(0xFFFBBF24)
          : const Color(0xFF8B949E);

      final tp = TextPainter(
        text: TextSpan(
            text: distStr,
            style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace')),
        textDirection: TextDirection.ltr,
      )..layout();
      final bg = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: badgePos,
              width: tp.width + 6,
              height: tp.height + 3),
          const Radius.circular(3));
      canvas.drawRRect(bg, Paint()..color = const Color(0xFF0D1117));
      canvas.drawRRect(
          bg,
          Paint()
            ..color = badgeColor.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
      tp.paint(canvas, badgePos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_UnifiedPainter old) => true;
}