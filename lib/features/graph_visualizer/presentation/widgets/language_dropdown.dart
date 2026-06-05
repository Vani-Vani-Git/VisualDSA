import 'package:flutter/material.dart';

class LanguageDropdown extends StatefulWidget {
  final String selected;
  final void Function(String) onChanged;

  const LanguageDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  bool _open = false;
  static const _langs = ['Python', 'Java', 'C', 'C++'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF30363D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.selected,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    )),
                Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8B949E), size: 16),
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
              children: _langs.map((l) {
                final sel = l == widget.selected;
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(l);
                    setState(() => _open = false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    color: sel ? const Color(0xFF21262D) : Colors.transparent,
                    child: Text(l,
                        style: TextStyle(
                          color: sel ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontFamily: 'monospace',
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}