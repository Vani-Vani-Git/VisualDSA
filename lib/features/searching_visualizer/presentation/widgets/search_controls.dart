import 'package:flutter/material.dart';

class SearchControls extends StatefulWidget {
  final bool playing;
  final bool finished;
  final int stepIndex;
  final int totalSteps;
  final int speedMs;
  final int? target;
  final String algorithm;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBack;
  final VoidCallback onReset;
  final void Function(int ms) onSpeedChanged;
  final void Function(int target) onTargetChanged;

  const SearchControls({
    super.key,
    required this.playing,
    required this.finished,
    required this.stepIndex,
    required this.totalSteps,
    required this.speedMs,
    required this.target,
    required this.algorithm,
    required this.onPlay,
    required this.onPause,
    required this.onStepForward,
    required this.onStepBack,
    required this.onReset,
    required this.onSpeedChanged,
    required this.onTargetChanged,
  });

  @override
  State<SearchControls> createState() => _SearchControlsState();
}

class _SearchControlsState extends State<SearchControls> {
  late TextEditingController _targetCtrl;

  @override
  void initState() {
    super.initState();
    _targetCtrl =
        TextEditingController(text: widget.target?.toString() ?? '');
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
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
        child: Icon(
          icon,
          color: onTap == null
              ? const Color(0xFF4B5563)
              : (color ?? const Color(0xFFE2E8F0)),
          size: 17,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canBack = widget.stepIndex > 0 && !widget.playing;
    final canForward = !widget.playing && !widget.finished;
    final progress =
        widget.totalSteps > 0 ? widget.stepIndex / widget.totalSteps : 0.0;

    // Note for binary/jump search
    final needsSorted =
        widget.algorithm == 'binary_search' || widget.algorithm == 'jump_search';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Target input row ────────────────────────────────────────────────
        Row(
          children: [
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
                    const Text(
                      'Target:',
                      style: TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _targetCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'enter value',
                          hintStyle: TextStyle(
                              color: Color(0xFF4B5563), fontSize: 12),
                        ),
                        onSubmitted: (v) {
                          final n = int.tryParse(v.trim());
                          if (n != null) widget.onTargetChanged(n);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final n = int.tryParse(_targetCtrl.text.trim());
                if (n != null) widget.onTargetChanged(n);
              },
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (needsSorted)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 12, color: Color(0xFF8B949E)),
                const SizedBox(width: 4),
                Text(
                  '${widget.algorithm == 'binary_search' ? 'Binary' : 'Jump'} Search requires a sorted array — auto-sorted.',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 10),

        // ── Playback buttons ────────────────────────────────────────────────
        Row(
          children: [
            _iconBtn(Icons.replay, widget.onReset,
                color: const Color(0xFF8B949E)),
            const SizedBox(width: 8),
            _iconBtn(
                Icons.skip_previous, canBack ? widget.onStepBack : null),
            const SizedBox(width: 8),
            // Play / Pause main button
            GestureDetector(
              onTap: widget.playing
                  ? widget.onPause
                  : (widget.finished ? widget.onReset : widget.onPlay),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: widget.playing
                      ? const Color(0xFFF59E0B)
                      : (widget.finished
                          ? const Color(0xFF374151)
                          : const Color(0xFF2563EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.playing
                          ? Icons.pause
                          : (widget.finished
                              ? Icons.replay
                              : Icons.play_arrow),
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.playing
                          ? 'Pause'
                          : (widget.finished ? 'Restart' : 'Play'),
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
            _iconBtn(
                Icons.skip_next, canForward ? widget.onStepForward : null),
            const Spacer(),
            Text(
              widget.totalSteps > 0
                  ? '${widget.stepIndex}/${widget.totalSteps}'
                  : '--',
              style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Progress bar ────────────────────────────────────────────────────
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
        const SizedBox(height: 8),

        // ── Speed slider ────────────────────────────────────────────────────
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
                  activeTrackColor: const Color(0xFF3B82F6),
                  inactiveTrackColor: const Color(0xFF21262D),
                  thumbColor: const Color(0xFF3B82F6),
                  overlayColor:
                      const Color(0xFF3B82F6).withOpacity(0.2),
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: (700 - widget.speedMs).toDouble(),
                  min: 0,
                  max: 650,
                  onChanged: (v) =>
                      widget.onSpeedChanged((700 - v).round().clamp(50, 700)),
                ),
              ),
            ),
            const Text('🐇', style: TextStyle(fontSize: 13)),
          ],
        ),

        // ── Color legend ────────────────────────────────────────────────────
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _Dot(color: Color(0xFFA78BFA), label: 'Comparing'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFF22C55E), label: 'Found'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFF3B82F6), label: 'Mid (Binary)'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFFF59E0B), label: 'Jump block'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFF22D3EE), label: 'Linear scan'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFF4B5563), label: 'Eliminated'),
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
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
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