import 'package:flutter/material.dart';

class LLOperationControls extends StatefulWidget {
  final bool playing;
  final bool finished;
  final int stepIndex;
  final int totalSteps;
  final int speedMs;
  final void Function(String op, String subOp, String value, int index) onExecute;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBack;
  final VoidCallback onReset;
  final void Function(int ms) onSpeedChanged;

  const LLOperationControls({
    super.key,
    required this.playing,
    required this.finished,
    required this.stepIndex,
    required this.totalSteps,
    required this.speedMs,
    required this.onExecute,
    required this.onPlay,
    required this.onPause,
    required this.onStepForward,
    required this.onStepBack,
    required this.onReset,
    required this.onSpeedChanged,
  });

  @override
  State<LLOperationControls> createState() => _LLOperationControlsState();
}

class _LLOperationControlsState extends State<LLOperationControls> {
  String _op = 'insert';
  String _subOp = 'head';
  bool _opOpen = false;
  bool _subOpen = false;
  final _vCtrl = TextEditingController();
  final _iCtrl = TextEditingController();

  static const _ops = {'insert': 'Insertion', 'delete': 'Deletion', 'search': 'Searching'};
  static const _opColors = {
    'insert': Color(0xFF22C55E),
    'delete': Color(0xFFEF4444),
    'search': Color(0xFF3B82F6),
  };
  static const _opIcons = {
    'insert': Icons.add_circle_outline,
    'delete': Icons.remove_circle_outline,
    'search': Icons.search,
  };

  Map<String, String> get _subOps => _op == 'search' ? {} : {
    'head': 'At Head', 'tail': 'At Tail', 'position': 'At Position (i)',
  };

  bool get _needsValue => _op == 'insert' || _op == 'search';
  bool get _needsIndex => (_op == 'insert' || _op == 'delete') && _subOp == 'position';
  bool get _hasSubOp => _op != 'search';
  Color get _color => _opColors[_op] ?? const Color(0xFF3B82F6);

  @override
  void dispose() { _vCtrl.dispose(); _iCtrl.dispose(); super.dispose(); }

  void _run() {
    final val = _vCtrl.text.trim().isEmpty ? '?' : _vCtrl.text.trim();
    final idx = int.tryParse(_iCtrl.text.trim()) ?? 0;
    widget.onExecute(_op, _subOp, val, idx);
  }

  Widget _iconBtn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: onTap == null ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0), size: 16),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final canBack = widget.stepIndex > 0 && !widget.playing;
    final canFwd = !widget.playing && !widget.finished && widget.totalSteps > 0;
    final progress = widget.totalSteps > 0 ? (widget.stepIndex / widget.totalSteps).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Main op dropdown
        GestureDetector(
          onTap: () => setState(() { _opOpen = !_opOpen; _subOpen = false; }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFF161B22),
                border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(_opIcons[_op], color: _color, size: 17),
              const SizedBox(width: 10),
              Expanded(child: Text(_ops[_op]!, style: const TextStyle(color: Color(0xFFE2E8F0),
                  fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
              Icon(_opOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF8B949E), size: 18),
            ]),
          ),
        ),
        if (_opOpen) Container(
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: const Color(0xFF1C2128),
              border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
          child: Column(children: _ops.entries.map((e) {
            final sel = e.key == _op;
            final c = _opColors[e.key]!;
            return GestureDetector(
              onTap: () => setState(() { _op = e.key; _subOp = 'head'; _opOpen = false; }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                color: sel ? const Color(0xFF21262D) : Colors.transparent,
                child: Row(children: [
                  Icon(_opIcons[e.key], color: c, size: 15),
                  const SizedBox(width: 10),
                  Text(e.value, style: TextStyle(color: sel ? c : const Color(0xFFE2E8F0),
                      fontSize: 14, fontFamily: 'monospace', fontWeight: sel ? FontWeight.w700 : FontWeight.normal)),
                ]),
              ),
            );
          }).toList()),
        ),

        const SizedBox(height: 8),

        // Sub-op dropdown
        if (_hasSubOp) ...[
          GestureDetector(
            onTap: () => setState(() { _subOpen = !_subOpen; _opOpen = false; }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF1C2128),
                  border: Border.all(color: _color.withOpacity(0.4)), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text(_subOps[_subOp] ?? _subOp,
                    style: TextStyle(color: _color, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
                Icon(_subOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8B949E), size: 16),
              ]),
            ),
          ),
          if (_subOpen) Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: const Color(0xFF1C2128),
                border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
            child: Column(children: _subOps.entries.map((e) {
              final sel = e.key == _subOp;
              return GestureDetector(
                onTap: () => setState(() { _subOp = e.key; _subOpen = false; }),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: sel ? const Color(0xFF21262D) : Colors.transparent,
                  child: Text(e.value, style: TextStyle(
                      color: sel ? _color : const Color(0xFFE2E8F0),
                      fontSize: 13, fontFamily: 'monospace',
                      fontWeight: sel ? FontWeight.w700 : FontWeight.normal)),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 8),
        ],

        // Input row
        Row(children: [
          if (_needsValue) Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Text('v:', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12, fontFamily: 'monospace')),
                const SizedBox(width: 6),
                Expanded(child: TextField(
                  controller: _vCtrl,
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontFamily: 'monospace'),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true,
                      contentPadding: EdgeInsets.zero, hintText: 'node value',
                      hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 11)),
                  onSubmitted: (_) => _run(),
                )),
              ]),
            ),
          ),
          if (_needsIndex) ...[
            const SizedBox(width: 8),
            SizedBox(width: 88,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: const Color(0xFF161B22),
                    border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Text('i:', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12, fontFamily: 'monospace')),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(
                    controller: _iCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontFamily: 'monospace'),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true,
                        contentPadding: EdgeInsets.zero, hintText: 'idx',
                        hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 11)),
                    onSubmitted: (_) => _run(),
                  )),
                ]),
              ),
            ),
          ],
          if (!_needsValue && !_needsIndex) const Spacer(),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _run,
            child: Container(
              height: 38, padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(_ops[_op]!,
                  style: const TextStyle(color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
            ),
          ),
        ]),

        const SizedBox(height: 10),

        // Playback
        Row(children: [
          _iconBtn(Icons.replay, widget.onReset),
          const SizedBox(width: 6),
          _iconBtn(Icons.skip_previous, canBack ? widget.onStepBack : null),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: widget.playing ? widget.onPause
                  : widget.finished ? widget.onReset
                  : widget.totalSteps > 0 ? widget.onPlay : null,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: widget.playing ? const Color(0xFFF59E0B)
                      : widget.finished ? const Color(0xFF374151)
                      : const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(widget.playing ? Icons.pause : widget.finished ? Icons.replay : Icons.play_arrow,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(widget.playing ? 'Pause' : widget.finished ? 'Restart' : 'Play',
                      style: const TextStyle(color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _iconBtn(Icons.skip_next, canFwd ? widget.onStepForward : null),
          const SizedBox(width: 8),
          Text(widget.totalSteps > 0 ? '${widget.stepIndex}/${widget.totalSteps}' : '--',
              style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11, fontFamily: 'monospace')),
        ]),

        const SizedBox(height: 8),

        ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress,
                backgroundColor: const Color(0xFF21262D),
                valueColor: AlwaysStoppedAnimation<Color>(_color), minHeight: 4)),

        const SizedBox(height: 8),

        Row(children: [
          const Text('Speed: ', style: TextStyle(color: Color(0xFF8B949E), fontSize: 11, fontFamily: 'monospace')),
          const Text('🐢', style: TextStyle(fontSize: 12)),
          Expanded(child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _color, inactiveTrackColor: const Color(0xFF21262D),
              thumbColor: _color, overlayColor: _color.withOpacity(0.2),
              trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: (700 - widget.speedMs).toDouble(), min: 0, max: 650,
              onChanged: (v) => widget.onSpeedChanged((700 - v).round().clamp(50, 700)),
            ),
          )),
          const Text('🐇', style: TextStyle(fontSize: 12)),
        ]),

        const SizedBox(height: 4),
        SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(children: const [
            _Dot(color: Color(0xFFF57C00), label: 'Current (tmp)'),
            SizedBox(width: 8),
            _Dot(color: Color(0xFFF4A234), label: 'Visited'),
            SizedBox(width: 8),
            _Dot(color: Color(0xFF4CAF50), label: 'Inserted/Found'),
            SizedBox(width: 8),
            _Dot(color: Color(0xFFFFD600), label: 'pred'),
            SizedBox(width: 8),
            _Dot(color: Color(0xFFEF4444), label: 'Deleting ✕'),
          ]),
        ),
      ]),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10, fontFamily: 'monospace')),
  ]);
}