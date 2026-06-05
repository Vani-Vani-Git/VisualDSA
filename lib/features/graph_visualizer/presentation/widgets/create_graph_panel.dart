import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CREATE GRAPH PANEL  — rewritten per requirements
//
// REMOVED:  Vertex / adjacency text-input section
// REMOVED:  Apply Graph button
// REMOVED:  Navigation to a separate full-screen draw page
//
// ADDED:
//   • Draw button → enables inline draw-mode on the graph_canvas area
//   • Random button → generates a graph respecting checkboxes
//   • Checkbox-aware drawing:
//       – Directed checked  → edges drawn with arrowheads
//       – Directed unchecked→ edges drawn as plain lines
//       – Weighted checked  → tapping edge midpoint opens weight dialog
//       – Weighted unchecked→ weight dialog never shown
//       – Connected checked → random graph guaranteed connected
//   • Undo / Redo toolbar shown while draw mode is active
//   • "Done" button commits the drawn graph and exits draw mode
// ─────────────────────────────────────────────────────────────────────────────

// ── Internal data models ──────────────────────────────────────────────────────

class _DVertex {
  int    id;
  int    label;
  Offset position;
  _DVertex({required this.id, required this.label, required this.position});
  _DVertex copy() => _DVertex(id: id, label: label, position: position);
}

class _DEdge {
  int fromId;
  int toId;
  int weight; // 0 = no weight
  _DEdge({required this.fromId, required this.toId, this.weight = 0});
  _DEdge copy() => _DEdge(fromId: fromId, toId: toId, weight: weight);
}

class _GSnap {
  final List<_DVertex> vertices;
  final List<_DEdge>   edges;
  final int            nextId;
  _GSnap({required this.vertices, required this.edges, required this.nextId});
}

// ── Result passed out via callback ────────────────────────────────────────────

class GraphDrawResult {
  final List<int>              vertices;
  final Map<int, List<int>>    adjacency;
  final Map<int, Map<int, int>> weights;   // vertex → neighbour → weight
  final int                    edgeCount;
  final bool                   isDirected;
  final bool                   isWeighted;
  final bool                   isConnected;

  GraphDrawResult({
    required this.vertices,
    required this.adjacency,
    required this.weights,
    required this.edgeCount,
    required this.isDirected,
    required this.isWeighted,
    required this.isConnected,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CreateGraphPanel
//
// Props received from parent:
//   isWeighted / isDirected / isConnected  — current checkbox state
//   onGraphReady(GraphDrawResult)          — called when user taps Done or Random
// ─────────────────────────────────────────────────────────────────────────────

class CreateGraphPanel extends StatefulWidget {
  final bool isWeighted;
  final bool isDirected;
  final bool isConnected;
  final void Function(GraphDrawResult result) onGraphReady;

  const CreateGraphPanel({
    super.key,
    required this.isWeighted,
    required this.isDirected,
    required this.isConnected,
    required this.onGraphReady,
  });

  @override
  State<CreateGraphPanel> createState() => _CreateGraphPanelState();
}

class _CreateGraphPanelState extends State<CreateGraphPanel> {
  // ── Draw-mode state ────────────────────────────────────────────────────────
  bool _drawMode = false;

  final List<_DVertex> _vertices = [];
  final List<_DEdge>   _edges    = [];
  int  _nextId = 0;

  int?    _selectedVertexId;
  int?    _draggingVertexId;
  Offset? _dragOffset;
  int?    _dragEdgeFromId;
  Offset? _dragEdgeCurrentPos;
  bool    _isDraggingEdge = false;

  static const double _radius        = 24.0;
  static const double _edgeStartDist = _radius + 8;

  final List<_GSnap> _undoStack = [];
  final List<_GSnap> _redoStack = [];

  // ── Snapshot helpers ───────────────────────────────────────────────────────

  void _snap() {
    _undoStack.add(_GSnap(
      vertices: _vertices.map((v) => v.copy()).toList(),
      edges:    _edges.map((e) => e.copy()).toList(),
      nextId:   _nextId,
    ));
    _redoStack.clear();
    if (_undoStack.length > 60) _undoStack.removeAt(0);
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_GSnap(
      vertices: _vertices.map((v) => v.copy()).toList(),
      edges:    _edges.map((e) => e.copy()).toList(),
      nextId:   _nextId,
    ));
    _restore(_undoStack.removeLast());
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_GSnap(
      vertices: _vertices.map((v) => v.copy()).toList(),
      edges:    _edges.map((e) => e.copy()).toList(),
      nextId:   _nextId,
    ));
    _restore(_redoStack.removeLast());
  }

  void _restore(_GSnap s) => setState(() {
        _vertices..clear()..addAll(s.vertices.map((v) => v.copy()));
        _edges..clear()..addAll(s.edges.map((e) => e.copy()));
        _nextId = s.nextId;
        _selectedVertexId = null;
        _cancelEdgeDrag();
      });

  void _cancelEdgeDrag() {
    _dragEdgeFromId     = null;
    _dragEdgeCurrentPos = null;
    _isDraggingEdge     = false;
  }

  // ── Hit testing ────────────────────────────────────────────────────────────

  _DVertex? _vertexAt(Offset p) {
    for (final v in _vertices.reversed) {
      if ((v.position - p).distance <= _radius + 6) return v;
    }
    return null;
  }

  _DEdge? _edgeAt(Offset p) {
    for (final e in _edges) {
      final a = _vById(e.fromId);
      final b = _vById(e.toId);
      if (a == null || b == null) continue;
      if (((a.position + b.position) / 2 - p).distance < 22) return e;
    }
    return null;
  }

  _DVertex? _vById(int id) {
    for (final v in _vertices) if (v.id == id) return v;
    return null;
  }

  bool _edgeExists(int a, int b) {
    if (widget.isDirected) return _edges.any((e) => e.fromId == a && e.toId == b);
    return _edges.any((e) =>
        (e.fromId == a && e.toId == b) || (e.fromId == b && e.toId == a));
  }

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails d) {
    if (!_drawMode) return;
    final pos = d.localPosition;

    // Edge midpoint → weight dialog (only when weighted)
    if (widget.isWeighted) {
      final eHit = _edgeAt(pos);
      if (eHit != null) { _editWeight(eHit); return; }
    }

    final vHit = _vertexAt(pos);
    if (vHit == null) {
      // Create vertex
      _snap();
      setState(() {
        _selectedVertexId = null;
        _vertices.add(_DVertex(id: _nextId, label: _nextId, position: pos));
        _nextId++;
      });
    } else if (_selectedVertexId == null) {
      setState(() => _selectedVertexId = vHit.id);
    } else if (_selectedVertexId == vHit.id) {
      setState(() => _selectedVertexId = null);
    } else {
      final from = _selectedVertexId!;
      if (!_edgeExists(from, vHit.id)) {
        _snap();
        setState(() {
          _edges.add(_DEdge(fromId: from, toId: vHit.id));
          _selectedVertexId = null;
        });
      } else {
        setState(() => _selectedVertexId = null);
      }
    }
  }

  void _onDoubleTap(TapDownDetails d) {
    if (!_drawMode) return;
    final v = _vertexAt(d.localPosition);
    if (v != null) {
      _snap();
      setState(() {
        _vertices.removeWhere((x) => x.id == v.id);
        _edges.removeWhere((e) => e.fromId == v.id || e.toId == v.id);
        if (_selectedVertexId == v.id) _selectedVertexId = null;
      });
    }
  }

  void _onLongPress(LongPressStartDetails d) {
    if (!_drawMode) return;
    final v = _vertexAt(d.localPosition);
    if (v != null) _editLabel(v);
  }

  void _onPanStart(DragStartDetails d) {
    if (!_drawMode) return;
    final pos  = d.localPosition;
    final vHit = _vertexAt(pos);
    if (vHit != null) {
      setState(() {
        _dragEdgeFromId     = vHit.id;
        _dragEdgeCurrentPos = pos;
        _isDraggingEdge     = false;
        _draggingVertexId   = null;
        _selectedVertexId   = null;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_drawMode) return;
    final pos = d.localPosition;
    if (_dragEdgeFromId != null) {
      final src = _vById(_dragEdgeFromId!);
      if (src == null) return;
      final dist = (src.position - pos).distance;
      if (!_isDraggingEdge && _draggingVertexId == null) {
        if (dist > _edgeStartDist) {
          setState(() => _isDraggingEdge = true);
        } else if (dist > 6) {
          setState(() {
            _draggingVertexId = _dragEdgeFromId;
            _dragOffset       = src.position - pos;
            _dragEdgeFromId   = null;
          });
        }
      }
      if (_isDraggingEdge) setState(() => _dragEdgeCurrentPos = pos);
      else if (_draggingVertexId != null) {
        final v = _vById(_draggingVertexId!);
        if (v != null) setState(() => v.position = pos + (_dragOffset ?? Offset.zero));
      }
    } else if (_draggingVertexId != null) {
      final v = _vById(_draggingVertexId!);
      if (v != null) setState(() => v.position = pos + (_dragOffset ?? Offset.zero));
    }
  }

  void _onPanEnd(DragEndDetails _) {
    if (!_drawMode) return;
    if (_isDraggingEdge && _dragEdgeFromId != null && _dragEdgeCurrentPos != null) {
      final target = _vertexAt(_dragEdgeCurrentPos!);
      if (target != null && target.id != _dragEdgeFromId) {
        if (!_edgeExists(_dragEdgeFromId!, target.id)) {
          _snap();
          setState(() => _edges.add(_DEdge(fromId: _dragEdgeFromId!, toId: target.id)));
        }
      }
    }
    setState(() {
      _draggingVertexId = null;
      _dragOffset       = null;
      _cancelEdgeDrag();
    });
  }

  // ── Editors ────────────────────────────────────────────────────────────────

  Future<void> _editLabel(_DVertex v) async {
    final ctrl = TextEditingController(text: '${v.label}');
    final res  = await showDialog<int>(
      context: context,
      builder: (_) => _NumDialog(title: 'Vertex Label', hint: 'Enter a number', ctrl: ctrl, confirm: 'Set'),
    );
    if (res != null) { _snap(); setState(() => v.label = res); }
  }

  Future<void> _editWeight(_DEdge e) async {
    final a = _vById(e.fromId);
    final b = _vById(e.toId);
    final lbl = a != null && b != null ? '${a.label} — ${b.label}' : 'Edge';
    final ctrl = TextEditingController(text: e.weight > 0 ? '${e.weight}' : '');
    final res  = await showDialog<int>(
      context: context,
      builder: (_) => _NumDialog(
          title: 'Weight  $lbl', hint: 'Enter weight (0 = remove)',
          ctrl: ctrl, confirm: 'Set', allowZero: true),
    );
    if (res != null) { _snap(); setState(() => e.weight = res); }
  }

  // ── Done — commit drawn graph ──────────────────────────────────────────────

  void _commitDraw() {
    if (_vertices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Draw at least one vertex first.',
            style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final sorted = List<_DVertex>.from(_vertices)
      ..sort((a, b) => a.label.compareTo(b.label));
    final labels = sorted.map((v) => v.label).toList();
    final id2lbl = <int, int>{for (final v in _vertices) v.id: v.label};

    final adj     = <int, List<int>>{for (final l in labels) l: []};
    final weights = <int, Map<int, int>>{for (final l in labels) l: {}};

    for (final e in _edges) {
      final aL = id2lbl[e.fromId]!;
      final bL = id2lbl[e.toId]!;
      if (!adj[aL]!.contains(bL)) adj[aL]!.add(bL);
      if (widget.isWeighted && e.weight > 0) weights[aL]![bL] = e.weight;

      // For undirected graphs, add reverse direction too
      if (!widget.isDirected) {
        if (!adj[bL]!.contains(aL)) adj[bL]!.add(aL);
        if (widget.isWeighted && e.weight > 0) weights[bL]![aL] = e.weight;
      }
    }

    widget.onGraphReady(GraphDrawResult(
      vertices:    labels,
      adjacency:   adj,
      weights:     weights,
      edgeCount:   _edges.length,
      isDirected:  widget.isDirected,
      isWeighted:  widget.isWeighted,
      isConnected: widget.isConnected,
    ));

    setState(() => _drawMode = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        '✓  Graph applied: ${labels.length} vertices, ${_edges.length} edges.',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
      ),
      backgroundColor: const Color(0xFF22C55E),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  // ── Random graph generator ─────────────────────────────────────────────────

  void _generateRandom() {
    final rng = Random();
    final n   = rng.nextInt(4) + 4; // 4–7 vertices

    // Layout vertices in a circle
    final centre = const Offset(150, 150); // nominal; parent will scale
    final r      = 110.0;
    final verts  = List.generate(n, (i) {
      final angle = (2 * pi * i / n) - pi / 2;
      return _DVertex(
        id:       i,
        label:    i,
        position: Offset(
          centre.dx + r * cos(angle),
          centre.dy + r * sin(angle),
        ),
      );
    });

    final edges = <_DEdge>[];

    if (widget.isConnected) {
      // Guarantee connectivity: random spanning tree first
      final shuffled = List<int>.from(List.generate(n, (i) => i))..shuffle(rng);
      for (int i = 1; i < n; i++) {
        final from = shuffled[rng.nextInt(i)];
        final to   = shuffled[i];
        edges.add(_DEdge(
          fromId: from,
          toId:   to,
          weight: widget.isWeighted ? rng.nextInt(9) + 1 : 0,
        ));
        // For undirected connected, also add reverse check handled at commit
      }
      // Add some extra random edges (20–40% density on top)
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          if (i == j) continue;
          final alreadyHas = edges.any((e) => e.fromId == i && e.toId == j);
          if (!alreadyHas && rng.nextDouble() < 0.25) {
            edges.add(_DEdge(
              fromId: i,
              toId:   j,
              weight: widget.isWeighted ? rng.nextInt(9) + 1 : 0,
            ));
          }
        }
      }
    } else {
      // Random with ~30% edge density
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          if (i == j) continue;
          if (rng.nextDouble() < 0.30) {
            edges.add(_DEdge(
              fromId: i,
              toId:   j,
              weight: widget.isWeighted ? rng.nextInt(9) + 1 : 0,
            ));
          }
        }
      }
    }

    setState(() {
      _vertices.clear();
      _edges.clear();
      _vertices.addAll(verts);
      _edges.addAll(edges);
      _nextId           = n;
      _selectedVertexId = null;
      _undoStack.clear();
      _redoStack.clear();
      _cancelEdgeDrag();
    });

    // Build and emit result immediately
    final labels  = verts.map((v) => v.label).toList();
    final adj     = <int, List<int>>{for (final l in labels) l: []};
    final weights = <int, Map<int, int>>{for (final l in labels) l: {}};

    for (final e in edges) {
      final aL = e.fromId;
      final bL = e.toId;
      if (!adj[aL]!.contains(bL)) adj[aL]!.add(bL);
      if (widget.isWeighted && e.weight > 0) weights[aL]![bL] = e.weight;
      if (!widget.isDirected) {
        if (!adj[bL]!.contains(aL)) adj[bL]!.add(aL);
        if (widget.isWeighted && e.weight > 0) weights[bL]![aL] = e.weight;
      }
    }

    widget.onGraphReady(GraphDrawResult(
      vertices:    labels,
      adjacency:   adj,
      weights:     weights,
      edgeCount:   edges.length,
      isDirected:  widget.isDirected,
      isWeighted:  widget.isWeighted,
      isConnected: widget.isConnected,
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Control bar: Draw | Random | (undo/redo/done when drawing) ──────
        _buildControlBar(),

        // ── Canvas (always visible; interactive only in draw mode) ──────────
        const SizedBox(height: 8),
        _buildCanvas(),
      ],
    );
  }

  // ── Control bar ───────────────────────────────────────────────────────────

  Widget _buildControlBar() {
    if (_drawMode) {
      // Draw-mode toolbar
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF21262D)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode badge + actions row
            Row(
              children: [
                // Active mode badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.draw_outlined, color: Color(0xFF7C3AED), size: 13),
                      SizedBox(width: 5),
                      Text('Drawing', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                    ],
                  ),
                ),

                // Property badges
                const SizedBox(width: 8),
                if (widget.isDirected)
                  _propBadge('Directed', Icons.arrow_forward, const Color(0xFF3B82F6)),
                if (widget.isWeighted)
                  _propBadge('Weighted', Icons.tag, const Color(0xFFF59E0B)),
                if (widget.isConnected)
                  _propBadge('Connected', Icons.hub_outlined, const Color(0xFF22C55E)),

                const Spacer(),

                // Undo
                _iconBtn(Icons.undo,
                    _undoStack.isNotEmpty ? _undo : null,
                    color: _undoStack.isNotEmpty ? const Color(0xFF93C5FD) : const Color(0xFF374151)),
                const SizedBox(width: 4),
                // Redo
                _iconBtn(Icons.redo,
                    _redoStack.isNotEmpty ? _redo : null,
                    color: _redoStack.isNotEmpty ? const Color(0xFF93C5FD) : const Color(0xFF374151)),
                const SizedBox(width: 4),

                // Clear
                if (_vertices.isNotEmpty)
                  _iconBtn(Icons.delete_outline, () {
                    _snap();
                    setState(() {
                      _vertices.clear(); _edges.clear();
                      _selectedVertexId = null; _nextId = 0;
                      _cancelEdgeDrag();
                    });
                  }, color: const Color(0xFFEF4444)),

                const SizedBox(width: 4),

                // Done
                GestureDetector(
                  onTap: _commitDraw,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                  ),
                ),

                const SizedBox(width: 4),

                // Cancel
                GestureDetector(
                  onTap: () => setState(() {
                    _drawMode = false;
                    _selectedVertexId = null;
                    _cancelEdgeDrag();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12, fontFamily: 'monospace')),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Instruction strip
            Text(
              _buildInstructions(),
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontFamily: 'monospace', height: 1.5),
            ),

            // Status strip for selected vertex / dragging edge
            if (_selectedVertexId != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(children: [
                  const Icon(Icons.radio_button_checked, color: Color(0xFF7C3AED), size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'Vertex ${_vById(_selectedVertexId!)?.label ?? '?'} selected — tap another to connect',
                    style: const TextStyle(color: Color(0xFFBB86FC), fontSize: 11, fontFamily: 'monospace'),
                  ),
                ]),
              ),
            ],
          ],
        ),
      );
    }

    // ── Default: Draw | Random buttons ───────────────────────────────────────
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Draw button
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _drawMode         = true;
                    _selectedVertexId = null;
                    _cancelEdgeDrag();
                  }),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1117),
                      border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.draw_outlined, color: Color(0xFF7C3AED), size: 16),
                        SizedBox(width: 6),
                        Text('Draw', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Random button
              Expanded(
                child: GestureDetector(
                  onTap: _generateRandom,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      border: Border.all(color: const Color(0xFF4B5563)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shuffle, color: Color(0xFFE2E8F0), size: 16),
                        SizedBox(width: 6),
                        Text('Random', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Active property chips
          Wrap(
            spacing: 6,
            children: [
              if (widget.isDirected)  _propBadge('Directed',  Icons.arrow_forward,   const Color(0xFF3B82F6)),
              if (widget.isWeighted)  _propBadge('Weighted',  Icons.tag,             const Color(0xFFF59E0B)),
              if (widget.isConnected) _propBadge('Connected', Icons.hub_outlined,    const Color(0xFF22C55E)),
              if (!widget.isDirected && !widget.isWeighted && !widget.isConnected)
                const Text('No properties selected.',
                    style: TextStyle(color: Color(0xFF4B5563), fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '↑ Draw to sketch your graph on the canvas below, or Random to auto-generate.',
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 10, fontFamily: 'monospace', height: 1.4),
          ),
        ],
      ),
    );
  }

  String _buildInstructions() {
    final parts = <String>[
      '• Tap empty → add vertex',
      '• Tap vertex → select   • Tap 2nd vertex → connect edge',
      '• Drag vertex→vertex → connect edge',
    ];
    if (widget.isWeighted) parts.add('• Tap edge midpoint dot → set weight');
    parts.add('• Long-press vertex → edit label   • Double-tap vertex → delete');
    if (!widget.isDirected) parts.add('• Edges are UNDIRECTED (no arrows)');
    if (widget.isDirected)  parts.add('• Edges are DIRECTED (arrows shown)');
    return parts.join('\n');
  }

  // ── Canvas ─────────────────────────────────────────────────────────────────

  Widget _buildCanvas() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1117),
        border: Border.all(
          color: _drawMode ? const Color(0xFF7C3AED) : const Color(0xFF21262D),
          width: _drawMode ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _drawMode
            ? GestureDetector(
                onTapDown:        _onTapDown,
                onDoubleTapDown:  _onDoubleTap,
                onLongPressStart: _onLongPress,
                onPanStart:       _onPanStart,
                onPanUpdate:      _onPanUpdate,
                onPanEnd:         _onPanEnd,
                child: CustomPaint(
                  painter: _DrawPainter(
                    vertices:           _vertices,
                    edges:              _edges,
                    selectedVertexId:   _selectedVertexId,
                    dragEdgeFromId:     _dragEdgeFromId,
                    dragEdgeCurrentPos: _dragEdgeCurrentPos,
                    isDraggingEdge:     _isDraggingEdge,
                    isDirected:         widget.isDirected,
                    isWeighted:         widget.isWeighted,
                    radius:             _radius,
                  ),
                  child: const SizedBox.expand(),
                ),
              )
            : _vertices.isEmpty
                ? const Center(
                    child: Text(
                      'Press Draw to sketch a graph\nor Random to generate one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontFamily: 'monospace', height: 1.5),
                    ),
                  )
                : CustomPaint(
                    painter: _DrawPainter(
                      vertices:           _vertices,
                      edges:              _edges,
                      selectedVertexId:   null,
                      dragEdgeFromId:     null,
                      dragEdgeCurrentPos: null,
                      isDraggingEdge:     false,
                      isDirected:         widget.isDirected,
                      isWeighted:         widget.isWeighted,
                      radius:             _radius,
                    ),
                    child: const SizedBox.expand(),
                  ),
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────

  Widget _propBadge(String label, IconData icon, Color color) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 11),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _iconBtn(IconData icon, VoidCallback? onTap, {Color? color}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1117),
            border: Border.all(color: const Color(0xFF30363D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color ?? const Color(0xFF8B949E), size: 17),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _DrawPainter — respects isDirected and isWeighted flags
// ─────────────────────────────────────────────────────────────────────────────

class _DrawPainter extends CustomPainter {
  final List<_DVertex> vertices;
  final List<_DEdge>   edges;
  final int?    selectedVertexId;
  final int?    dragEdgeFromId;
  final Offset? dragEdgeCurrentPos;
  final bool    isDraggingEdge;
  final bool    isDirected;
  final bool    isWeighted;
  final double  radius;

  _DrawPainter({
    required this.vertices,
    required this.edges,
    this.selectedVertexId,
    this.dragEdgeFromId,
    this.dragEdgeCurrentPos,
    this.isDraggingEdge = false,
    this.isDirected     = true,
    this.isWeighted     = false,
    this.radius         = 24,
  });

  _DVertex? _v(int id) {
    for (final v in vertices) if (v.id == id) return v;
    return null;
  }

  Offset _border(Offset c, Offset towards) {
    final d = towards - c;
    final l = d.distance;
    return l < 0.001 ? c : c + d / l * (radius + 2);
  }

  void _drawEdge(Canvas canvas, Offset from, Offset to, Color color, {bool preview = false}) {
    final sw = preview ? 2.2 : 2.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke;

    if (isDirected) {
      // Directed: arrow
      final s = _border(from, to);
      final e = _border(to, from);
      if ((e - s).distance < 2) return;
      canvas.drawLine(s, e, paint);
      const len = 13.0;
      const ang = 0.40;
      final a  = atan2(e.dy - s.dy, e.dx - s.dx);
      final p1 = e + Offset(cos(a + pi - ang) * len, sin(a + pi - ang) * len);
      final p2 = e + Offset(cos(a + pi + ang) * len, sin(a + pi + ang) * len);
      canvas.drawPath(
        Path()..moveTo(e.dx, e.dy)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..close(),
        Paint()..color = color..style = PaintingStyle.fill,
      );
    } else {
      // Undirected: plain line
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ── 1. Committed edges ─────────────────────────────────────────────────
    for (final e in edges) {
      final a = _v(e.fromId);
      final b = _v(e.toId);
      if (a == null || b == null) continue;

      const edgeColor = Color(0xFF60A5FA);
      _drawEdge(canvas, a.position, b.position, edgeColor);

      final mid = (a.position + b.position) / 2;

      // Midpoint dot (always shown — tap target for weight)
      canvas.drawCircle(mid, 6, Paint()..color = const Color(0xFF1E40AF).withOpacity(0.9));
      canvas.drawCircle(mid, 6,
          Paint()..color = const Color(0xFF93C5FD)..strokeWidth = 1.3..style = PaintingStyle.stroke);

      // Weight label only when weighted and weight > 0
      if (isWeighted && e.weight > 0) {
        final dx  = b.position.dx - a.position.dx;
        final dy  = b.position.dy - a.position.dy;
        final len = sqrt(dx * dx + dy * dy);
        final px  = len > 0 ? -dy / len * 17 : 0.0;
        final py  = len > 0 ?  dx / len * 17 : -17.0;
        _wLabel(canvas, '${e.weight}', Offset(mid.dx + px, mid.dy + py));
      }
    }

    // ── 2. Live drag preview ───────────────────────────────────────────────
    if (isDraggingEdge && dragEdgeFromId != null && dragEdgeCurrentPos != null) {
      final src = _v(dragEdgeFromId!);
      if (src != null) {
        _DVertex? snap;
        for (final v in vertices) {
          if (v.id != dragEdgeFromId &&
              (v.position - dragEdgeCurrentPos!).distance <= radius + 10) {
            snap = v;
            break;
          }
        }
        final endPos = snap?.position ?? dragEdgeCurrentPos!;
        _drawEdge(canvas, src.position, endPos, const Color(0xFF4ADE80).withOpacity(0.85), preview: true);
        if (snap != null) {
          canvas.drawCircle(snap.position, radius + 7,
              Paint()..color = const Color(0xFF4ADE80).withOpacity(0.22)..style = PaintingStyle.fill);
        }
      }
    }

    // ── 3. Vertices (always on top) ────────────────────────────────────────
    for (final v in vertices) {
      final isSel     = v.id == selectedVertexId;
      final isDragSrc = v.id == dragEdgeFromId;

      if (isSel || isDragSrc) {
        canvas.drawCircle(v.position, radius + 7,
            Paint()
              ..color = (isDragSrc ? const Color(0xFF4ADE80) : const Color(0xFFF97316)).withOpacity(0.22)
              ..style = PaintingStyle.fill);
      }

      canvas.drawCircle(v.position, radius,
          Paint()
            ..color = isSel
                ? const Color(0xFFF97316).withOpacity(0.22)
                : isDragSrc
                    ? const Color(0xFF4ADE80).withOpacity(0.18)
                    : const Color(0xFF1D4ED8).withOpacity(0.20)
            ..style = PaintingStyle.fill);

      canvas.drawCircle(v.position, radius,
          Paint()
            ..color = isSel
                ? const Color(0xFFF97316)
                : isDragSrc
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFF3B82F6)
            ..strokeWidth = (isSel || isDragSrc) ? 2.5 : 2.0
            ..style = PaintingStyle.stroke);

      _txt(canvas, '${v.label}', v.position,
          color: isSel
              ? const Color(0xFFF97316)
              : isDragSrc
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFFE2E8F0),
          fontSize: 14, bold: true);
    }
  }

  void _wLabel(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(text: text,
          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    final bg = RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: tp.width + 8, height: tp.height + 5),
        const Radius.circular(3));
    canvas.drawRRect(bg, Paint()..color = const Color(0xFF0F1117).withOpacity(0.9));
    canvas.drawRRect(bg,
        Paint()..color = const Color(0xFFF59E0B).withOpacity(0.45)..style = PaintingStyle.stroke..strokeWidth = 1);
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _txt(Canvas canvas, String text, Offset c,
      {Color color = Colors.white, double fontSize = 13, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text,
          style: TextStyle(color: color, fontSize: fontSize,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_DrawPainter _) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// _NumDialog — reusable integer input dialog
// ─────────────────────────────────────────────────────────────────────────────

class _NumDialog extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController ctrl;
  final String confirm;
  final bool allowZero;

  const _NumDialog({
    required this.title, required this.hint,
    required this.ctrl, required this.confirm,
    this.allowZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2128),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title,
          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 18, fontFamily: 'monospace'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3B82F6))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF60A5FA), width: 2)),
        ),
        onSubmitted: (_) => _ok(context),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B949E), fontFamily: 'monospace'))),
        TextButton(onPressed: () => _ok(context),
            child: Text(confirm, style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
      ],
    );
  }

  void _ok(BuildContext context) {
    final val = int.tryParse(ctrl.text.trim());
    if (val == null) return;
    if (!allowZero && val < 0) return;
    Navigator.pop(context, val);
  }
}