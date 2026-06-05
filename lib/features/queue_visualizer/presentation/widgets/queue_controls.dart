import 'package:flutter/material.dart';

class QueueControls extends StatefulWidget {
  final String operation;
  final bool playing;
  final bool finished;
  final int stepIndex;
  final int totalSteps;
  final int speedMs;
  final VoidCallback? onPlay; // null = no steps ready yet
  final VoidCallback onPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBack;
  final VoidCallback onReset;
  final void Function(int ms) onSpeedChanged;
  final void Function(int value) onExecute;

  const QueueControls({
    super.key,
    required this.operation,
    required this.playing,
    required this.finished,
    required this.stepIndex,
    required this.totalSteps,
    required this.speedMs,
    this.onPlay,              // optional — null disables Play
    required this.onPause,
    required this.onStepForward,
    required this.onStepBack,
    required this.onReset,
    required this.onSpeedChanged,
    required this.onExecute,
  });

  @override
  State<QueueControls> createState() => _QueueControlsState();
}

class _QueueControlsState extends State<QueueControls> {
  final _valCtrl = TextEditingController();

  @override
  void dispose() {
    _valCtrl.dispose();
    super.dispose();
  }

  Widget _iconBtn(IconData icon, VoidCallback? onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: onTap == null
                ? const Color(0xFF4B5563)
                : (color ?? const Color(0xFFE2E8F0)),
            size: 17),
      ),
    );
  }

  void _onExecuteTap() {
    if (widget.operation == 'enqueue') {
      final v = int.tryParse(_valCtrl.text.trim());
      if (v != null) widget.onExecute(v);
    } else {
      widget.onExecute(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnqueue = widget.operation == 'enqueue';
    final canBack   = widget.stepIndex > 0 && !widget.playing;
    final canFwd    = !widget.playing && !widget.finished;
    final progress  = widget.totalSteps > 0
        ? widget.stepIndex / widget.totalSteps
        : 0.0;

    // Button colour per operation
    final execColor = isEnqueue
        ? const Color(0xFF16A34A)
        : widget.operation == 'dequeue'
            ? const Color(0xFF7C3AED)
            : const Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Value input (Enqueue only) + Execute button ─────────────────
        Row(
          children: [
            if (isEnqueue) ...[
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    border: Border.all(color: const Color(0xFF30363D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('Value:',
                          style: TextStyle(
                              color: Color(0xFF8B949E),
                              fontSize: 12,
                              fontFamily: 'monospace')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _valCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontFamily: 'monospace'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'enter value',
                            hintStyle: TextStyle(
                                color: Color(0xFF4B5563), fontSize: 12),
                          ),
                          onSubmitted: (_) => _onExecuteTap(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: _onExecuteTap,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: execColor,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text(
                    isEnqueue
                        ? 'Enqueue'
                        : widget.operation == 'dequeue'
                            ? 'Dequeue'
                            : 'Peek',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Playback buttons ────────────────────────────────────────────
        Row(
          children: [
            _iconBtn(Icons.replay, widget.onReset,
                color: const Color(0xFF8B949E)),
            const SizedBox(width: 8),
            _iconBtn(Icons.skip_previous,
                canBack ? widget.onStepBack : null),
            const SizedBox(width: 8),
            GestureDetector(
              // null onPlay → tap does nothing (greyed out)
              onTap: widget.playing
                  ? widget.onPause
                  : widget.finished
                      ? widget.onReset
                      : widget.onPlay,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.playing
                      ? const Color(0xFFF59E0B)
                      : widget.finished
                          ? const Color(0xFF374151)
                          : widget.onPlay != null
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF21262D), // grey = no steps ready
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.playing
                          ? Icons.pause
                          : widget.finished
                              ? Icons.replay
                              : Icons.play_arrow,
                      color: (widget.onPlay != null ||
                              widget.playing ||
                              widget.finished)
                          ? Colors.white
                          : const Color(0xFF4B5563),
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.playing
                          ? 'Pause'
                          : widget.finished
                              ? 'Restart'
                              : 'Play',
                      style: TextStyle(
                          color: (widget.onPlay != null ||
                                  widget.playing ||
                                  widget.finished)
                              ? Colors.white
                              : const Color(0xFF4B5563),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _iconBtn(Icons.skip_next,
                canFwd ? widget.onStepForward : null),
            const Spacer(),
            Text(
              widget.totalSteps > 0
                  ? '${widget.stepIndex}/${widget.totalSteps}'
                  : '--',
              style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 11,
                  fontFamily: 'monospace'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Progress bar ────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF21262D),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
            minHeight: 4,
          ),
        ),

        const SizedBox(height: 8),

        // ── Hint when no steps ready ─────────────────────────────────────
        if (widget.onPlay == null && !widget.playing && !widget.finished)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 12, color: Color(0xFF4B5563)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.operation == 'enqueue'
                        ? 'Enter a value and press Enqueue to start.'
                        : widget.operation == 'dequeue'
                            ? 'Press Dequeue to remove the front element.'
                            : 'Press Peek to view the front element.',
                    style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 10,
                        fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),

        // ── Speed slider ────────────────────────────────────────────────
        Row(
          children: [
            const Text('Speed: ',
                style: TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 12,
                    fontFamily: 'monospace')),
            const Text('🐢', style: TextStyle(fontSize: 13)),
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
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: (700 - widget.speedMs).toDouble(),
                  min: 0,
                  max: 650,
                  onChanged: (v) => widget
                      .onSpeedChanged((700 - v).round().clamp(50, 700)),
                ),
              ),
            ),
            const Text('🐇', style: TextStyle(fontSize: 13)),
          ],
        ),

        const SizedBox(height: 4),

        // ── Colour legend ───────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _Dot(color: Color(0xFF22C55E), label: 'Enqueue / Rear'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFFA78BFA), label: 'Dequeue / Front'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFF3B82F6), label: 'Peek'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFFEF4444), label: 'Index / Error'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 10,
                fontFamily: 'monospace')),
      ],
    );
  }
}