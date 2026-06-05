import 'package:flutter/material.dart';

class GraphDropdown extends StatefulWidget {
  final String selected;
  final void Function(String) onChanged;

  const GraphDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<GraphDropdown> createState() => _GraphDropdownState();
}

class _GraphDropdownState extends State<GraphDropdown> {
  bool _open = false;

  static const _modes = {
    'create_graph': 'Create Graph',
    'adjacency_matrix': 'Adjacency Matrix',
    'adjacency_list': 'Adjacency List',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF30363D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _modes[widget.selected] ?? widget.selected,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                Icon(
                  _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF8B949E),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2128),
              border: Border.all(color: const Color(0xFF30363D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _modes.entries.map((e) {
                final sel = e.key == widget.selected;
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(e.key);
                    setState(() => _open = false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    color: sel ? const Color(0xFF21262D) : Colors.transparent,
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE2E8F0),
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}