import 'package:flutter/material.dart';

class MstAnimControls extends StatelessWidget {
  final bool playing;
  final bool finished;
  final int stepIndex;
  final int totalSteps;
  final int speedMs;
  final String statusMsg;
  final int currentWeight;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBack;
  final VoidCallback onReset;
  final void Function(int ms) onSpeedChanged;

  const MstAnimControls({
    super.key,
    required this.playing,
    required this.finished,
    required this.stepIndex,
    required this.totalSteps,
    required this.speedMs,
    required this.statusMsg,
    required this.currentWeight,
    required this.onPlay,
    required this.onPause,
    required this.onStepForward,
    required this.onStepBack,
    required this.onReset,
    required this.onSpeedChanged,
  });

  Widget _iconBtn(IconData icon, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            border: Border.all(color: const Color(0xFF30363D)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: onTap == null
                  ? const Color(0xFF374151)
                  : const Color(0xFFE2E8F0),
              size: 15),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final canBack = stepIndex > 0 && !playing;
    final canFwd = !playing && !finished && totalSteps > 0;
    final progress = totalSteps > 0 ? stepIndex / totalSteps : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MST weight badge
        if (currentWeight > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.12),
                border: Border.all(
                    color: const Color(0xFF22C55E).withOpacity(0.4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_tree_outlined,
                      color: Color(0xFF22C55E), size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'MST Weight: $currentWeight',
                    style: const TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),

        // Status message
        if (statusMsg.isNotEmpty)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.08),
              border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusMsg,
              style: const TextStyle(
                  color: Color(0xFF93C5FD),
                  fontSize: 11,
                  fontFamily: 'monospace',
                  height: 1.4),
            ),
          ),

        // Control row
        Row(
          children: [
            _iconBtn(Icons.replay, onReset),
            const SizedBox(width: 5),
            _iconBtn(Icons.skip_previous, canBack ? onStepBack : null),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: playing
                  ? onPause
                  : (finished ? onReset : onPlay),
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: playing
                      ? const Color(0xFFF59E0B)
                      : finished
                          ? const Color(0xFF374151)
                          : const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      playing
                          ? Icons.pause
                          : finished
                              ? Icons.replay
                              : Icons.play_arrow,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      playing ? 'Pause' : finished ? 'Restart' : 'Play',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            _iconBtn(Icons.skip_next, canFwd ? onStepForward : null),
            const Spacer(),
            Text(
              totalSteps > 0 ? '$stepIndex/$totalSteps' : '--',
              style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 11,
                  fontFamily: 'monospace'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF21262D),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
            minHeight: 4,
          ),
        ),

        const SizedBox(height: 6),

        // Speed slider
        Row(
          children: [
            const Text('Speed: ',
                style: TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 10,
                    fontFamily: 'monospace')),
            const Text('🐢', style: TextStyle(fontSize: 11)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF22C55E),
                  inactiveTrackColor: const Color(0xFF21262D),
                  thumbColor: const Color(0xFF22C55E),
                  overlayColor:
                      const Color(0xFF22C55E).withOpacity(0.2),
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: (800 - speedMs).toDouble(),
                  min: 0,
                  max: 750,
                  onChanged: (v) =>
                      onSpeedChanged((800 - v).round().clamp(50, 800)),
                ),
              ),
            ),
            const Text('🐇', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}