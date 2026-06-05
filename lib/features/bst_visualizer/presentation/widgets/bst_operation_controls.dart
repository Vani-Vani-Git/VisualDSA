import 'package:flutter/material.dart';

class BSTOperationControls extends StatefulWidget {
  final String selectedOp;
  final bool playing;
  final bool finished;
  final int stepIndex;
  final int totalSteps;
  final int speedMs;
  final void Function(String op) onOpChanged;
  final void Function(int value) onExecute;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBack;
  final VoidCallback onReset;
  final void Function(int ms) onSpeedChanged;

  const BSTOperationControls({
    super.key,
    required this.selectedOp,
    required this.playing,
    required this.finished,
    required this.stepIndex,
    required this.totalSteps,
    required this.speedMs,
    required this.onOpChanged,
    required this.onExecute,
    required this.onPlay,
    required this.onPause,
    required this.onStepForward,
    required this.onStepBack,
    required this.onReset,
    required this.onSpeedChanged,
  });

  @override
  State<BSTOperationControls> createState() => _BSTOperationControlsState();
}

class _BSTOperationControlsState extends State<BSTOperationControls> {
  bool _dropOpen = false;
  final _valCtrl = TextEditingController();

  static const _ops = {
    'insert': 'Insertion',
    'delete': 'Deletion',
    'search': 'Searching',
  };

  static const _opIcons = {
    'insert': Icons.add_circle_outline,
    'delete': Icons.remove_circle_outline,
    'search': Icons.search,
  };

  static const _opColors = {
    'insert': Color(0xFF22C55E),
    'delete': Color(0xFFEF4444),
    'search': Color(0xFF3B82F6),
  };

  static const _opHints = {
    'insert': 'Value to insert',
    'delete': 'Value to delete',
    'search': 'Value to search',
  };

  @override
  void dispose() {
    _valCtrl.dispose();
    super.dispose();
  }

  void _execute() {
    final v = int.tryParse(_valCtrl.text.trim());
    if (v == null) return;
    widget.onExecute(v);
  }

  Widget _iconBtn(IconData icon, VoidCallback? onTap, {Color? color}) {
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
        child: Icon(icon,
            color: onTap == null
                ? const Color(0xFF4B5563)
                : (color ?? const Color(0xFFE2E8F0)),
            size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opColor = _opColors[widget.selectedOp] ?? const Color(0xFF3B82F6);
    final canBack = widget.stepIndex > 0 && !widget.playing;
    final canFwd = !widget.playing &&
        !widget.finished &&
        widget.totalSteps > 0;
    final progress = widget.totalSteps > 0
        ? (widget.stepIndex / widget.totalSteps).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Operation Dropdown ─────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _dropOpen = !_dropOpen),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(_opIcons[widget.selectedOp], color: opColor, size: 17),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _ops[widget.selectedOp] ?? widget.selectedOp,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Icon(
                    _dropOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8B949E),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          if (_dropOpen)
            Container(
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128),
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: _ops.entries.map((e) {
                  final sel = e.key == widget.selectedOp;
                  final c = _opColors[e.key]!;
                  return GestureDetector(
                    onTap: () {
                      widget.onOpChanged(e.key);
                      setState(() => _dropOpen = false);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      color: sel
                          ? const Color(0xFF21262D)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(_opIcons[e.key], color: c, size: 16),
                          const SizedBox(width: 10),
                          Text(
                            e.value,
                            style: TextStyle(
                              color: sel ? c : const Color(0xFFE2E8F0),
                              fontSize: 14,
                              fontFamily: 'monospace',
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 10),

          // ── Value input + Execute button ───────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    border: Border.all(color: const Color(0xFF30363D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Key:',
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _valCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: _opHints[widget.selectedOp],
                            hintStyle: const TextStyle(
                                color: Color(0xFF4B5563), fontSize: 11),
                          ),
                          onSubmitted: (_) => _execute(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _execute,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: opColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _ops[widget.selectedOp] ?? 'Run',
                      style: const TextStyle(
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

          const SizedBox(height: 10),

          // ── Playback row ───────────────────────────────────────────────
          Row(
            children: [
              _iconBtn(Icons.replay, widget.onReset,
                  color: const Color(0xFF8B949E)),
              const SizedBox(width: 6),
              _iconBtn(
                  Icons.skip_previous, canBack ? widget.onStepBack : null),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: widget.playing
                      ? widget.onPause
                      : widget.finished
                          ? widget.onReset
                          : widget.totalSteps > 0
                              ? widget.onPlay
                              : null,
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.playing
                          ? const Color(0xFFF59E0B)
                          : widget.finished
                              ? const Color(0xFF374151)
                              : const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.playing
                              ? Icons.pause
                              : widget.finished
                                  ? Icons.replay
                                  : Icons.play_arrow,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.playing
                              ? 'Pause'
                              : widget.finished
                                  ? 'Restart'
                                  : 'Play',
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
              ),
              const SizedBox(width: 6),
              _iconBtn(Icons.skip_next, canFwd ? widget.onStepForward : null),
              const SizedBox(width: 8),
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

          // ── Progress bar ───────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF21262D),
              valueColor: AlwaysStoppedAnimation<Color>(opColor),
              minHeight: 4,
            ),
          ),

          const SizedBox(height: 8),

          // ── Speed slider ───────────────────────────────────────────────
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
                    activeTrackColor: opColor,
                    inactiveTrackColor: const Color(0xFF21262D),
                    thumbColor: opColor,
                    overlayColor: opColor.withOpacity(0.2),
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
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
              const Text('🐇', style: TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 4),

          // ── Color legend ───────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _Dot(color: Color(0xFFA5D6A7), label: 'currNode / Active'),
                SizedBox(width: 8),
                _Dot(color: Color(0xFF81C784), label: 'Found'),
                SizedBox(width: 8),
                _Dot(color: Color(0xFFC8E6C9), label: 'Visited path'),
                SizedBox(width: 8),
                _Dot(color: Color(0xFFD4EDDA), label: 'Idle nodes'),
                SizedBox(width: 8),
                _Dot(color: Color(0xFF888888), label: 'Deleted'),
              ],
            ),
          ),
        ],
      ),
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
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF30363D), width: 0.5),
          ),
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