import 'package:flutter/material.dart';

class HeapOperationDropdown extends StatefulWidget {
  final String selected;
  final void Function(String) onChanged;

  const HeapOperationDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<HeapOperationDropdown> createState() =>
      _HeapOperationDropdownState();
}

class _HeapOperationDropdownState extends State<HeapOperationDropdown> {
  bool _open = false;

  static const _ops = {
    'insert': (
      'Insert',
      Icons.add_circle_outline,
      Color(0xFF22C55E),
      'Add a new value & heapify up'
    ),
    'delete': (
      'Delete',
      Icons.remove_circle_outline,
      Color(0xFFEF4444),
      'Remove node by index & heapify'
    ),
    'update': (
      'Update',
      Icons.edit_outlined,
      Color(0xFF3B82F6),
      'Change value at index & heapify'
    ),
    'sort': (
      'Heap Sort',
      Icons.sort,
      Color(0xFFF59E0B),
      'Extract root repeatedly → sorted'
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cur = _ops[widget.selected];

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
                    Icon(cur?.$2 ?? Icons.settings,
                        color: cur?.$3 ?? const Color(0xFF8B949E),
                        size: 16),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cur?.$1 ?? 'Select Operation',
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
              children: _ops.entries.map((e) {
                final isSel = e.key == widget.selected;
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(e.key);
                    setState(() => _open = false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
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