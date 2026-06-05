import 'package:flutter/material.dart';

class OperationDropdown extends StatefulWidget {
  final String selected;
  final void Function(String) onChanged;

  const OperationDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<OperationDropdown> createState() => _OperationDropdownState();
}

class _OperationDropdownState extends State<OperationDropdown> {
  bool _open = false;

  static const _ops = {
    'sort': 'Sort',
    'insert': 'Insert',
    'update': 'Update',
    'delete': 'Delete',
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
                  _ops[widget.selected] ?? widget.selected,
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
              children: _ops.entries.map((e) {
                final isSelected = e.key == widget.selected;
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(e.key);
                    setState(() => _open = false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    color: isSelected ? const Color(0xFF21262D) : Colors.transparent,
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
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