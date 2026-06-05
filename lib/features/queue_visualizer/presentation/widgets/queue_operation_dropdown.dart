import 'package:flutter/material.dart';

class QueueOperationDropdown extends StatefulWidget {
  final String selected;
  final void Function(String) onChanged;

  const QueueOperationDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<QueueOperationDropdown> createState() =>
      _QueueOperationDropdownState();
}

class _QueueOperationDropdownState extends State<QueueOperationDropdown> {
  bool _open = false;

  static const _operations = {
    'enqueue': (
      'Enqueue',
      Icons.arrow_forward_rounded,
      Color(0xFF22C55E),
      'Insert element at REAR'
    ),
    'dequeue': (
      'Dequeue',
      Icons.arrow_back_rounded,
      Color(0xFFA78BFA),
      'Remove element from FRONT'
    ),
    'peek': (
      'Peek',
      Icons.visibility_outlined,
      Color(0xFF3B82F6),
      'View FRONT element'
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cur = _operations[widget.selected];

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
                    Icon(cur?.$2 ?? Icons.queue,
                        color: cur?.$3 ?? const Color(0xFF8B949E),
                        size: 16),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cur?.$1 ?? 'Select Operation',
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          cur?.$4 ?? '',
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value.$1,
                              style: TextStyle(
                                color: isSel
                                    ? e.value.$3
                                    : const Color(0xFFE2E8F0),
                                fontSize: 13,
                                fontFamily: 'monospace',
                                fontWeight: isSel
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              e.value.$4,
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
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