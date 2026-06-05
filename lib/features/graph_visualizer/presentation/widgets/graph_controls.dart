import 'package:flutter/material.dart';

class GraphAnimControls extends StatelessWidget {
  final bool playing;
  final bool finished;
  final int stepIndex;
  final int totalSteps;
  final int speedMs;
  final String statusMsg;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBack;
  final VoidCallback onReset;
  final void Function(int ms) onSpeedChanged;

  const GraphAnimControls({
    super.key,
    required this.playing,
    required this.finished,
    required this.stepIndex,
    required this.totalSteps,
    required this.speedMs,
    required this.statusMsg,
    required this.onPlay,
    required this.onPause,
    required this.onStepForward,
    required this.onStepBack,
    required this.onReset,
    required this.onSpeedChanged,
  });

  Widget _iconBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: onTap == null
              ? const Color(0xFF4B5563)
              : const Color(0xFFE2E8F0),
          size: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canBack = stepIndex > 0 && !playing;
    final canForward = !playing && !finished && totalSteps > 0;
    final progress =
        totalSteps > 0 ? stepIndex / totalSteps : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status message
        if (statusMsg.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusMsg,
              style: const TextStyle(
                color: Color(0xFF93C5FD),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),

        // Control row
        Row(
          children: [
            _iconBtn(Icons.replay, onReset),
            const SizedBox(width: 6),
            _iconBtn(Icons.skip_previous, canBack ? onStepBack : null),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: playing
                  ? onPause
                  : (finished ? onReset : onPlay),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: playing
                      ? const Color(0xFFF59E0B)
                      : (finished
                          ? const Color(0xFF374151)
                          : const Color(0xFF2563EB)),
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
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      playing
                          ? 'Pause'
                          : (finished ? 'Restart' : 'Play'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            _iconBtn(Icons.skip_next, canForward ? onStepForward : null),
            const Spacer(),
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
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF21262D),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('Speed: ',
                style: TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 11,
                    fontFamily: 'monospace')),
            const Text('🐢', style: TextStyle(fontSize: 12)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF3B82F6),
                  inactiveTrackColor: const Color(0xFF21262D),
                  thumbColor: const Color(0xFF3B82F6),
                  overlayColor:
                      const Color(0xFF3B82F6).withOpacity(0.2),
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
            const Text('🐇', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}