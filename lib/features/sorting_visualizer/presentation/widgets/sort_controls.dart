import 'package:flutter/material.dart';

class SortControls extends StatelessWidget {
  final bool playing;
  final bool finished;
  final int stepIndex;
  final int totalSteps;
  final int speedMs;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBack;
  final VoidCallback onReset;
  final void Function(int ms) onSpeedChanged;

  const SortControls({
    super.key,
    required this.playing,
    required this.finished,
    required this.stepIndex,
    required this.totalSteps,
    required this.speedMs,
    required this.onPlay,
    required this.onPause,
    required this.onStepForward,
    required this.onStepBack,
    required this.onReset,
    required this.onSpeedChanged,
  });

  Widget _iconBtn(IconData icon, VoidCallback? onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: onTap == null
              ? const Color(0xFF4B5563)
              : (color ?? const Color(0xFFE2E8F0)),
          size: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canBack = stepIndex > 0 && !playing;
    final canForward = !playing && !finished;
    final progress = totalSteps > 0 ? stepIndex / totalSteps : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Control buttons ────────────────────────────────────────────────
        Row(
          children: [
            // Reset
            _iconBtn(Icons.replay, onReset, color: const Color(0xFF8B949E)),
            const SizedBox(width: 8),
            // Step back
            _iconBtn(Icons.skip_previous, canBack ? onStepBack : null),
            const SizedBox(width: 8),
            // Play / Pause (big button)
            GestureDetector(
              onTap: playing ? onPause : (finished ? onReset : onPlay),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: playing
                      ? const Color(0xFFF59E0B)
                      : (finished ? const Color(0xFF374151) : const Color(0xFF2563EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      playing
                          ? Icons.pause
                          : (finished ? Icons.replay : Icons.play_arrow),
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      playing ? 'Pause' : (finished ? 'Restart' : 'Play'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Step forward
            _iconBtn(Icons.skip_next, canForward ? onStepForward : null),
            const Spacer(),
            // Step counter
            Text(
              totalSteps > 0 ? '$stepIndex/$totalSteps' : '--',
              style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Progress bar ───────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF21262D),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 10),

        // ── Speed slider ───────────────────────────────────────────────────
        Row(
          children: [
            const Text(
              'Speed:',
              style: TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 4),
            const Text('🐢', style: TextStyle(fontSize: 13)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF3B82F6),
                  inactiveTrackColor: const Color(0xFF21262D),
                  thumbColor: const Color(0xFF3B82F6),
                  overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: (600 - speedMs).toDouble(), // invert: right = fast
                  min: 0,
                  max: 550,
                  onChanged: (v) => onSpeedChanged((600 - v).round().clamp(50, 600)),
                ),
              ),
            ),
            const Text('🐇', style: TextStyle(fontSize: 13)),
          ],
        ),

        // ── Legend ─────────────────────────────────────────────────────────
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _LegendDot(color: Color(0xFF60A5FA), label: 'Default'),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFFA78BFA), label: 'Comparing'),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFFF59E0B), label: 'Swapping'),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFF22C55E), label: 'Sorted'),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFFF97316), label: 'Pivot'),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFF22D3EE), label: 'Merging'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B949E),
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}