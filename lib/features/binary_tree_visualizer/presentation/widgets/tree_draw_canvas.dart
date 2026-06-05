import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tree_node.dart';

// ── Data classes ──────────────────────────────────────────────────────────────

class _DrawnNode {
  int id;
  Offset position;
  String label;
  _DrawnNode({required this.id, required this.position, this.label = ''});
}

class _DrawnEdge {
  int fromId;
  int toId;
  _DrawnEdge(this.fromId, this.toId);
}

// ── Draw tool ─────────────────────────────────────────────────────────────────

enum _DrawTool { node, edge, select, deleteItem }

// ── Full-screen Draw Canvas Modal ─────────────────────────────────────────────

class TreeDrawCanvas extends StatefulWidget {
  /// Called when user taps "Use Tree" — passes the root of the built BT.
  final void Function(TreeNode? root, List<int> levelOrder) onConfirm;

  const TreeDrawCanvas({super.key, required this.onConfirm});

  @override
  State<TreeDrawCanvas> createState() => _TreeDrawCanvasState();
}

class _TreeDrawCanvasState extends State<TreeDrawCanvas> {
  static const double _nodeR = 24.0;

  final List<_DrawnNode> _nodes = [];
  final List<_DrawnEdge> _edges = [];
  int _nextId = 1;

  _DrawTool _tool = _DrawTool.node;

  // Edge drawing state
  int? _edgeFromId;

  // Drag state
  int? _draggingId;
  Offset _dragOffset = Offset.zero;

  // Label editing
  int? _editingId;
  final _labelCtrl = TextEditingController();
  final _labelFocus = FocusNode();

  String? _errorMsg;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _labelFocus.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  _DrawnNode? _nodeAt(Offset pos) {
    for (final n in _nodes.reversed) {
      if ((n.position - pos).distance <= _nodeR + 6) return n;
    }
    return null;
  }

  void _startEditLabel(int id) {
    final node = _nodes.firstWhere((n) => n.id == id);
    setState(() {
      _editingId = id;
      _labelCtrl.text = node.label;
    });
    Future.delayed(const Duration(milliseconds: 80), () {
      _labelFocus.requestFocus();
      _labelCtrl.selection =
          TextSelection(baseOffset: 0, extentOffset: _labelCtrl.text.length);
    });
  }

  void _commitLabel() {
    if (_editingId == null) return;
    setState(() {
      final node = _nodes.firstWhere((n) => n.id == _editingId);
      node.label = _labelCtrl.text.trim();
      _editingId = null;
    });
  }

  void _deleteNode(int id) {
    setState(() {
      _nodes.removeWhere((n) => n.id == id);
      _edges.removeWhere((e) => e.fromId == id || e.toId == id);
      _edgeFromId = null;
      _editingId = null;
    });
  }

  void _deleteEdge(Offset tap) {
    for (int i = _edges.length - 1; i >= 0; i--) {
      final e = _edges[i];
      final a = _nodes.firstWhere((n) => n.id == e.fromId).position;
      final b = _nodes.firstWhere((n) => n.id == e.toId).position;
      if (_distPointToSegment(tap, a, b) < 10) {
        setState(() => _edges.removeAt(i));
        return;
      }
    }
  }

  double _distPointToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final t = (ap.dx * ab.dx + ap.dy * ab.dy) /
        (ab.dx * ab.dx + ab.dy * ab.dy + 0.0001);
    final tc = t.clamp(0.0, 1.0);
    final closest = a + Offset(ab.dx * tc, ab.dy * tc);
    return (p - closest).distance;
  }

  // ── Build the BT from drawn graph ─────────────────────────────────────────
  // Uses top-most node as root, then assigns children by relative position.

  TreeNode? _buildTree() {
    if (_nodes.isEmpty) return null;

    // Find root: node with no incoming edges
    final hasParent = <int>{};
    for (final e in _edges) hasParent.add(e.toId);
    final roots =
        _nodes.where((n) => !hasParent.contains(n.id)).toList();

    if (roots.isEmpty) {
      setState(() => _errorMsg = 'No root found! A root node must have no incoming edge.');
      return null;
    }
    if (roots.length > 1) {
      // Pick top-most as root
      roots.sort((a, b) => a.position.dy.compareTo(b.position.dy));
    }

    // Validate: each node at most 2 children
    for (final n in _nodes) {
      final children =
          _edges.where((e) => e.fromId == n.id).toList();
      if (children.length > 2) {
        setState(() =>
            _errorMsg = 'Node ${n.label.isEmpty ? n.id : n.label} has ${children.length} children. Binary tree allows max 2.');
        return null;
      }
    }

    setState(() => _errorMsg = null);

    TreeNode build(int id) {
      final n = _nodes.firstWhere((nd) => nd.id == id);
      final val = int.tryParse(n.label) ?? n.id;
      final node = TreeNode(val);
      // Sort children left-to-right by x position
      final children = _edges
          .where((e) => e.fromId == id)
          .map((e) => _nodes.firstWhere((nd) => nd.id == e.toId))
          .toList()
        ..sort((a, b) => a.position.dx.compareTo(b.position.dx));
      if (children.isNotEmpty) node.left = build(children[0].id);
      if (children.length > 1) node.right = build(children[1].id);
      return node;
    }

    return build(roots.first.id);
  }

  List<int> _levelOrder(TreeNode? root) {
    if (root == null) return [];
    final result = <int>[];
    final q = <TreeNode>[root];
    while (q.isNotEmpty) {
      final n = q.removeAt(0);
      result.add(n.value);
      if (n.left != null) q.add(n.left!);
      if (n.right != null) q.add(n.right!);
    }
    return result;
  }

  void _onConfirmTap() {
    _commitLabel();
    final root = _buildTree();
    if (root == null && _nodes.isNotEmpty) return; // error already set
    widget.onConfirm(root, _levelOrder(root));
    Navigator.pop(context);
  }

  // ── Gesture handling ───────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails d) {
    final pos = d.localPosition;
    _commitLabel();

    switch (_tool) {
      case _DrawTool.node:
        // Tap on existing node → start editing label
        final hit = _nodeAt(pos);
        if (hit != null) {
          _startEditLabel(hit.id);
        } else {
          // Create new node
          setState(() {
            _nodes.add(_DrawnNode(id: _nextId++, position: pos));
          });
          _startEditLabel(_nodes.last.id);
        }
        break;

      case _DrawTool.edge:
        final hit = _nodeAt(pos);
        if (hit == null) {
          setState(() => _edgeFromId = null);
          return;
        }
        if (_edgeFromId == null) {
          setState(() => _edgeFromId = hit.id);
        } else {
          if (_edgeFromId != hit.id) {
            // Prevent duplicate edge
            final exists = _edges.any((e) =>
                e.fromId == _edgeFromId && e.toId == hit.id);
            if (!exists) {
              setState(() {
                _edges.add(_DrawnEdge(_edgeFromId!, hit.id));
              });
            }
          }
          setState(() => _edgeFromId = null);
        }
        break;

      case _DrawTool.deleteItem:
        final hit = _nodeAt(pos);
        if (hit != null) {
          _deleteNode(hit.id);
        } else {
          _deleteEdge(pos);
        }
        break;

      case _DrawTool.select:
        break;
    }
  }

  void _onPanStart(DragStartDetails d) {
    if (_tool != _DrawTool.select) return;
    _commitLabel();
    final hit = _nodeAt(d.localPosition);
    if (hit != null) {
      setState(() {
        _draggingId = hit.id;
        _dragOffset = d.localPosition - hit.position;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_draggingId == null) return;
    setState(() {
      final node = _nodes.firstWhere((n) => n.id == _draggingId);
      node.position = d.localPosition - _dragOffset;
    });
  }

  void _onPanEnd(DragEndDetails _) => setState(() => _draggingId = null);

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text('Draw Binary Tree',
            style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace')),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF8B949E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _onConfirmTap,
            child: const Text('Use Tree',
                style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ),
        ],
      ),
      body: Column(children: [
        // ── Tool bar ──────────────────────────────────────────────────────
        _buildToolbar(),

        // ── Error msg ─────────────────────────────────────────────────────
        if (_errorMsg != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.12),
              border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_errorMsg!,
                style: const TextStyle(
                    color: Color(0xFFFC8181),
                    fontSize: 11,
                    fontFamily: 'monospace')),
          ),

        // ── Hint ─────────────────────────────────────────────────────────
        _buildHint(),

        // ── Canvas ───────────────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTapDown: _onTapDown,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              width: double.infinity,
              color: const Color(0xFF1C2128),
              child: Stack(children: [
                // Edges layer
                CustomPaint(
                  painter: _EdgePainter(
                    nodes: _nodes,
                    edges: _edges,
                    edgeFromId: _edgeFromId,
                  ),
                  child: const SizedBox.expand(),
                ),
                // Nodes layer
                ..._nodes.map((n) => _buildNodeWidget(n)),
              ]),
            ),
          ),
        ),

        // ── Bottom bar ────────────────────────────────────────────────────
        _buildBottomBar(),
      ]),
    );
  }

  Widget _buildToolbar() {
    const tools = [
      (_DrawTool.node,       Icons.circle_outlined,  'Add Node'),
      (_DrawTool.edge,       Icons.timeline,         'Add Edge'),
      (_DrawTool.select,     Icons.open_with,        'Move'),
      (_DrawTool.deleteItem, Icons.delete_outline,   'Delete'),
    ];
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: tools.map((t) {
        final active = _tool == t.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _tool = t.$1;
              _edgeFromId = null;
            }),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF3B82F6).withOpacity(0.18)
                    : Colors.transparent,
                border: Border.all(
                  color: active
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF30363D),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.$2,
                      color: active
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF8B949E),
                      size: 18),
                  const SizedBox(height: 3),
                  Text(t.$3,
                      style: TextStyle(
                          color: active
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF8B949E),
                          fontSize: 9,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          ),
        );
      }).toList()),
    );
  }

  Widget _buildHint() {
    String hint;
    Color color;
    switch (_tool) {
      case _DrawTool.node:
        hint = 'Tap canvas → create node  •  Tap node → edit number';
        color = const Color(0xFF3B82F6);
        break;
      case _DrawTool.edge:
        hint = _edgeFromId == null
            ? 'Tap first node (parent)'
            : 'Tap second node (child) to connect';
        color = const Color(0xFFF59E0B);
        break;
      case _DrawTool.select:
        hint = 'Drag nodes to reposition';
        color = const Color(0xFF8B949E);
        break;
      case _DrawTool.deleteItem:
        hint = 'Tap a node or edge to delete it';
        color = const Color(0xFFEF4444);
        break;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0xFF0F1117),
      child: Text(hint,
          style: TextStyle(
              color: color, fontSize: 11, fontFamily: 'monospace')),
    );
  }

  Widget _buildNodeWidget(_DrawnNode node) {
    final isEdgeFrom = _edgeFromId == node.id;
    final isEditing = _editingId == node.id;

    return Positioned(
      left: node.position.dx - _nodeR,
      top: node.position.dy - _nodeR,
      width: _nodeR * 2,
      height: _nodeR * 2,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEdgeFrom
              ? const Color(0xFFF59E0B).withOpacity(0.25)
              : const Color(0xFF1C2128),
          border: Border.all(
            color: isEdgeFrom
                ? const Color(0xFFF59E0B)
                : isEditing
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF4B82F6),
            width: isEdgeFrom || isEditing ? 2.5 : 1.8,
          ),
          boxShadow: isEdgeFrom || isEditing
              ? [
                  BoxShadow(
                    color: (isEdgeFrom
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF3B82F6))
                        .withOpacity(0.3),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Center(
          child: isEditing
              ? SizedBox(
                  width: _nodeR * 1.4,
                  child: TextField(
                    controller: _labelCtrl,
                    focusNode: _labelFocus,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _commitLabel(),
                  ),
                )
              : Text(
                  node.label.isEmpty ? '?' : node.label,
                  style: TextStyle(
                    color: node.label.isEmpty
                        ? const Color(0xFF4B5563)
                        : const Color(0xFFE2E8F0),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(children: [
        // Node count badge
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('${_nodes.length} nodes  •  ${_edges.length} edges',
              style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 11,
                  fontFamily: 'monospace')),
        ),
        const Spacer(),
        // Clear
        GestureDetector(
          onTap: () => setState(() {
            _nodes.clear();
            _edges.clear();
            _edgeFromId = null;
            _editingId = null;
            _errorMsg = null;
          }),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Clear',
                style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ),
        ),
        const SizedBox(width: 8),
        // Use Tree
        GestureDetector(
          onTap: _onConfirmTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          ),
        ),
      ]),
    );
  }
}

// ── Edge painter ──────────────────────────────────────────────────────────────

class _EdgePainter extends CustomPainter {
  final List<_DrawnNode> nodes;
  final List<_DrawnEdge> edges;
  final int? edgeFromId;

  _EdgePainter({
    required this.nodes,
    required this.edges,
    this.edgeFromId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4B82F6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final e in edges) {
      final fromNode =
          nodes.firstWhere((n) => n.id == e.fromId, orElse: () => _DrawnNode(id: -1, position: Offset.zero));
      final toNode =
          nodes.firstWhere((n) => n.id == e.toId, orElse: () => _DrawnNode(id: -1, position: Offset.zero));
      if (fromNode.id == -1 || toNode.id == -1) continue;

      final from = fromNode.position;
      final to = toNode.position;

      // Shorten line to node radius
      final dir = (to - from);
      final dist = dir.distance;
      if (dist < 1) continue;
      final unit = dir / dist;
      const r = 24.0 + 2;
      final p1 = from + unit * r;
      final p2 = to - unit * r;

      canvas.drawLine(p1, p2, paint);

      // Arrow head
      _arrowHead(canvas, p2, unit, paint);
    }

    // Highlight selected-from node ring
    if (edgeFromId != null) {
      final n = nodes.firstWhere((nd) => nd.id == edgeFromId,
          orElse: () => _DrawnNode(id: -1, position: Offset.zero));
      if (n.id != -1) {
        canvas.drawCircle(
          n.position,
          28,
          Paint()
            ..color = const Color(0xFFF59E0B).withOpacity(0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
    }
  }

  void _arrowHead(Canvas canvas, Offset tip, Offset dir, Paint paint) {
    const size = 9.0;
    const angle = 0.4;
    final perp = Offset(-dir.dy, dir.dx);
    final p1 = tip - dir * size + perp * size * angle;
    final p2 = tip - dir * size - perp * size * angle;
    canvas.drawLine(tip, p1, paint..strokeWidth = 1.8);
    canvas.drawLine(tip, p2, paint);
  }

  @override
  bool shouldRepaint(_EdgePainter old) => true;
}