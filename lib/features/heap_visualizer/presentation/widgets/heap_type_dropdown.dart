import 'package:flutter/material.dart';

class HeapTypeDropdown extends StatefulWidget {
  final String selected; // 'max' | 'min'
  final void Function(String) onChanged;

  const HeapTypeDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<HeapTypeDropdown> createState() => _HeapTypeDropdownState();
}

class _HeapTypeDropdownState extends State<HeapTypeDropdown> {
  bool _open = false;

  static const _types = {
    'max': (
      'Max-Heap',
      Icons.keyboard_double_arrow_up,
      Color(0xFFEF4444),
      'Root = largest element'
    ),
    'min': (
      'Min-Heap',
      Icons.keyboard_double_arrow_down,
      Color(0xFF3B82F6),
      'Root = smallest element'
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cur = _types[widget.selected];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                    Icon(cur?.$2 ?? Icons.layers,
                        color: cur?.$3 ?? const Color(0xFF8B949E),
                        size: 16),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cur?.$1 ?? 'Select Heap Type',
                            style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace')),
                        Text(cur?.$4 ?? '',
                            style: const TextStyle(
                                color: Color(0xFF8B949E),
                                fontSize: 10,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ],
                ),
                Icon(
                    _open
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8B949E),
                    size: 18),
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
              children: _types.entries.map((e) {
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value.$1,
                                style: TextStyle(
                                    color: isSel
                                        ? e.value.$3
                                        : const Color(0xFFE2E8F0),
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    fontWeight: isSel
                                        ? FontWeight.w700
                                        : FontWeight.normal)),
                            Text(e.value.$4,
                                style: const TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 10,
                                    fontFamily: 'monospace')),
                          ],
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