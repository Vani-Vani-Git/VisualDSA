import 'package:flutter/material.dart';
import '../models/trav_graph_model.dart';

class TravPropertyCheckboxes extends StatelessWidget {
  final TravGraphProperties props;
  final void Function(TravGraphProperties) onChanged;

  const TravPropertyCheckboxes({
    super.key,
    required this.props,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(String, bool, TravGraphProperties Function(bool))>[
      ('Directed', props.directed, (v) => props.copyWith(directed: v)),
      ('Connected', props.connected, (v) => props.copyWith(connected: v)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: items.map((item) {
          final label = item.$1;
          final value = item.$2;
          final updater = item.$3;
          return GestureDetector(
            onTap: () => onChanged(updater(!value)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 20, height: 20,
                child: Checkbox(
                  value: value,
                  onChanged: (v) => onChanged(updater(v ?? false)),
                  activeColor: const Color(0xFF2563EB),
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF8B949E)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(
                  color: Color(0xFFE2E8F0), fontSize: 13, fontFamily: 'monospace')),
              const SizedBox(width: 12),
            ]),
          );
        }).toList(),
      ),
    );
  }
}