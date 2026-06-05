import 'package:flutter/material.dart';
import '../models/mst_graph_model.dart';

class MstPropertyCheckboxes extends StatelessWidget {
  final MstGraphProperties props;
  final void Function(MstGraphProperties) onChanged;

  const MstPropertyCheckboxes({
    super.key,
    required this.props,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Weighted checkbox
          GestureDetector(
            onTap: () => onChanged(props.copyWith(weighted: !props.weighted)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: props.weighted,
                    onChanged: (v) =>
                        onChanged(props.copyWith(weighted: v ?? true)),
                    activeColor: const Color(0xFF2563EB),
                    checkColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF8B949E)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Weighted',
                    style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 13,
                        fontFamily: 'monospace')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Fixed info chips
          _infoChip('— Undirected', const Color(0xFF3B82F6)),
          const SizedBox(width: 6),
          _infoChip('◎ Connected', const Color(0xFF22C55E)),
        ],
      ),
    );
  }

  Widget _infoChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          border: Border.all(color: color.withOpacity(0.35)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontFamily: 'monospace')),
      );
}