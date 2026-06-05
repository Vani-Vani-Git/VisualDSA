import 'package:flutter/material.dart';

class HeapControls extends StatefulWidget {
  final String operation;  // 'insert'|'delete'|'update'|'sort'
  final String heapType;   // 'max'|'min'
  final bool playing;
  final bool finished;
  final int stepIndex;
  final int totalSteps;
  final int speedMs;
  final int heapSize;
  final VoidCallback? onPlay;   // null when no steps are ready yet
  final VoidCallback onPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBack;
  final VoidCallback onReset;
  final void Function(int ms) onSpeedChanged;
  // Execute callbacks per operation
  final void Function(int value) onInsert;
  final void Function(int index) onDelete;
  final void Function(int index, int newVal) onUpdate;
  final VoidCallback onSort;

  const HeapControls({
    super.key,
    required this.operation,
    required this.heapType,
    required this.playing,
    required this.finished,
    required this.stepIndex,
    required this.totalSteps,
    required this.speedMs,
    required this.heapSize,
    this.onPlay,               // optional — null disables Play button
    required this.onPause,
    required this.onStepForward,
    required this.onStepBack,
    required this.onReset,
    required this.onSpeedChanged,
    required this.onInsert,
    required this.onDelete,
    required this.onUpdate,
    required this.onSort,
  });

  @override
  State<HeapControls> createState() => _HeapControlsState();
}

class _HeapControlsState extends State<HeapControls> {
  final _valCtrl = TextEditingController();
  final _idxCtrl = TextEditingController();

  @override
  void dispose() {
    _valCtrl.dispose();
    _idxCtrl.dispose();
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

  Widget _inputField(TextEditingController ctrl, String hint,
      {String? label}) {
    return Expanded(
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
            if (label != null) ...[
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 12,
                      fontFamily: 'monospace')),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 13,
                    fontFamily: 'monospace'),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: hint,
                  hintStyle: const TextStyle(
                      color: Color(0xFF4B5563), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onExecute() {
    switch (widget.operation) {
      case 'insert':
        final v = int.tryParse(_valCtrl.text.trim());
        if (v != null) widget.onInsert(v);
        break;
      case 'delete':
        final i = int.tryParse(_idxCtrl.text.trim());
        if (i != null) widget.onDelete(i);
        break;
      case 'update':
        final i   = int.tryParse(_idxCtrl.text.trim());
        final nv  = int.tryParse(_valCtrl.text.trim());
        if (i != null && nv != null) widget.onUpdate(i, nv);
        break;
      case 'sort':
        widget.onSort();
        break;
    }
  }

  Color get _execColor {
    switch (widget.operation) {
      case 'insert': return const Color(0xFF16A34A);
      case 'delete': return const Color(0xFFDC2626);
      case 'update': return const Color(0xFF2563EB);
      case 'sort':   return const Color(0xFFD97706);
      default:       return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canBack = widget.stepIndex > 0 && !widget.playing;
    final canFwd  = !widget.playing && !widget.finished;
    final progress = widget.totalSteps > 0
        ? widget.stepIndex / widget.totalSteps
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Dynamic input row per operation ──────────────────────────────
        _buildInputRow(),

        const SizedBox(height: 10),

        // ── Playback buttons ─────────────────────────────────────────────
        Row(
          children: [
            _iconBtn(Icons.replay, widget.onReset,
                color: const Color(0xFF8B949E)),
            const SizedBox(width: 8),
            _iconBtn(Icons.skip_previous,
                canBack ? widget.onStepBack : null),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.playing
                  ? widget.onPause
                  : widget.finished
                      ? widget.onReset
                      : widget.onPlay, // null when no steps ready → no-op
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
                              : const Color(0xFF21262D), // greyed out = no steps
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
                      color: widget.onPlay != null || widget.playing || widget.finished
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
                          color: widget.onPlay != null || widget.playing || widget.finished
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

        // ── Hint when no steps are ready ─────────────────────────────────
        if (widget.onPlay == null && !widget.playing && !widget.finished)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 12, color: Color(0xFF4B5563)),
                const SizedBox(width: 6),
                Text(
                  widget.operation == 'sort'
                      ? 'Press "Run Heap Sort" above to start the animation.'
                      : 'Fill the input and press the operation button above to start.',
                  style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 10,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),

        // ── Progress bar ─────────────────────────────────────────────────
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

        // ── Speed slider ─────────────────────────────────────────────────
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
                  onChanged: (v) => widget
                      .onSpeedChanged((700 - v).round().clamp(50, 700)),
                ),
              ),
            ),
            const Text('🐇', style: TextStyle(fontSize: 13)),
          ],
        ),

        const SizedBox(height: 4),

        // ── Colour legend ────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _Dot(color: Color(0xFF22C55E), label: 'Settled / Sorted'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFFEF4444), label: 'Swap violation'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFF3B82F6), label: 'Comparing'),
              SizedBox(width: 10),
              _Dot(color: Color(0xFFF59E0B), label: 'Extracting (sort)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow() {
    switch (widget.operation) {
      case 'insert':
        return Row(children: [
          _inputField(_valCtrl, 'value to insert', label: 'Value:'),
          const SizedBox(width: 8),
          _execButton('Insert'),
        ]);

      case 'delete':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _inputField(_idxCtrl,
                  'index 0–${widget.heapSize - 1}',
                  label: 'Index i:'),
              const SizedBox(width: 8),
              _execButton('Delete'),
            ]),
            if (widget.heapSize > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      size: 11, color: Color(0xFF8B949E)),
                  const SizedBox(width: 4),
                  Text(
                    'Valid index: 0 – ${widget.heapSize - 1}',
                    style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                        fontFamily: 'monospace'),
                  ),
                ]),
              ),
          ],
        );

      case 'update':
        return Column(
          children: [
            Row(children: [
              _inputField(_idxCtrl,
                  'index 0–${widget.heapSize - 1}',
                  label: 'Index i:'),
              const SizedBox(width: 6),
              _inputField(_valCtrl, 'new value', label: 'Val:'),
              const SizedBox(width: 8),
              _execButton('Update'),
            ]),
            if (widget.heapSize > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      size: 11, color: Color(0xFF8B949E)),
                  const SizedBox(width: 4),
                  Text(
                    'Valid index: 0 – ${widget.heapSize - 1}',
                    style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                        fontFamily: 'monospace'),
                  ),
                ]),
              ),
          ],
        );

      case 'sort':
        return GestureDetector(
          onTap: _onExecute,
          child: Container(
            height: 38,
            width: double.infinity,
            decoration: BoxDecoration(
                color: _execColor,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.sort, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Run Heap Sort',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _execButton(String label) {
    return GestureDetector(
      onTap: _onExecute,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
            color: _execColor, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace')),
        ),
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
                color: color, borderRadius: BorderRadius.circular(2))),
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