import 'package:flutter/material.dart';

class StackOperationDropdown extends StatefulWidget {
  final String selected;
  final void Function(String) onChanged;

  const StackOperationDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<StackOperationDropdown> createState() => _StackOperationDropdownState();
}

class _StackOperationDropdownState extends State<StackOperationDropdown> {
  bool _open = false;

  static const _operations = {
    'push': ('Push', Icons.arrow_downward_rounded, Color(0xFF3B82F6)),
    'pop': ('Pop', Icons.arrow_upward_rounded, Color(0xFFA78BFA)),
    'peek': ('Peek', Icons.visibility_outlined, Color(0xFF22C55E)),
  };

  @override
  Widget build(BuildContext context) {
    final current = _operations[widget.selected];

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
                Row(
                  children: [
                    Icon(current?.$2 ?? Icons.layers,
                        color: current?.$3 ?? const Color(0xFF8B949E),
                        size: 16),
                    const SizedBox(width: 8),
                    Text(
                      current?.$1 ?? 'Select Operation',
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
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
              children: _operations.entries.map((e) {
                final isSel = e.key == widget.selected;
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(e.key);
                    setState(() => _open = false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    color: isSel
                        ? const Color(0xFF21262D)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Icon(e.value.$2,
                            color: isSel
                                ? e.value.$3
                                : const Color(0xFF8B949E),
                            size: 15),
                        const SizedBox(width: 10),
                        Text(
                          e.value.$1,
                          style: TextStyle(
                            color: isSel
                                ? e.value.$3
                                : const Color(0xFFE2E8F0),
                            fontSize: 14,
                            fontFamily: 'monospace',
                            fontWeight: isSel
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
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