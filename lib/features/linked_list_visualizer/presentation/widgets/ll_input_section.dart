import 'dart:math';
import 'package:flutter/material.dart';

class LLInputSection extends StatefulWidget {
  final String initialValue;
  final void Function(List<String> values) onChanged;
  const LLInputSection({super.key, required this.initialValue, required this.onChanged});
  @override
  State<LLInputSection> createState() => _LLInputSectionState();
}

class _LLInputSectionState extends State<LLInputSection> {
  late TextEditingController _ctrl;

  @override
  void initState() { super.initState(); _ctrl = TextEditingController(text: widget.initialValue); }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _apply() {
    final vals = _ctrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (vals.isNotEmpty) widget.onChanged(vals);
  }

  void _random() {
    final rng = Random();
    final len = rng.nextInt(4) + 4;
    final vals = List.generate(len, (_) => (rng.nextInt(90) + 5).toString());
    _ctrl.text = vals.join(', ');
    widget.onChanged(vals);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.linear_scale, color: Color(0xFF3B82F6), size: 15),
          SizedBox(width: 6),
          Text('Linked List', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
          SizedBox(width: 6),
          Text('(comma-separated values)', style: TextStyle(color: Color(0xFF4B5563), fontSize: 10, fontFamily: 'monospace')),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF0F1117), border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Text('Nodes:', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12, fontFamily: 'monospace')),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontFamily: 'monospace'),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                hintText: 'e.g. 10, 20, 30, 40',
                hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontFamily: 'monospace')),
              onSubmitted: (_) => _apply(),
            )),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          GestureDetector(onTap: _apply, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(7)),
            child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace')))),
          const SizedBox(width: 8),
          GestureDetector(onTap: _random, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFF374151), borderRadius: BorderRadius.circular(7)),
            child: const Text('Random', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace')))),
        ]),
      ]),
    );
  }
}