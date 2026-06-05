import 'dart:math';
import 'package:flutter/material.dart';
import '../models/huffman_model.dart';
import '../widgets/huffman_canvas.dart';
import '../widgets/huffman_anim_controls.dart';
import '../widgets/huffman_code_tab.dart';
import '../widgets/huffman_complexity_card.dart';
// Adjust this import path to match your project structure
import '../../../../shared/widgets/ai_tutor_panel.dart';

class HuffmanDashboard extends StatefulWidget {
  const HuffmanDashboard({super.key});

  @override
  State<HuffmanDashboard> createState() => _HuffmanDashboardState();
}

class _HuffmanDashboardState extends State<HuffmanDashboard> {
  // ── Input state ──────────────────────────────────────────────────────────────
  final TextEditingController _inputCtrl = TextEditingController();
  String _appliedInput = '';

  // ── Frequency table ──────────────────────────────────────────────────────────
  List<CharFreq> _freqTable = [];

  // ── Animation state ──────────────────────────────────────────────────────────
  List<HuffStep> _steps = [];
  int _currentStep = 0;
  bool _playing = false;
  bool _finished = false;
  int _speedMs = 700;

  // ── Result table (shown after done) ─────────────────────────────────────────
  List<HuffResult> _results = [];

  // ── Tab state ────────────────────────────────────────────────────────────────
  int _activeTab = 0;
  String _aiLang = 'Python';

  // ── Random strings ───────────────────────────────────────────────────────────
  static const _randomStrings = [
    'aeiousaeiousaeiousaeiust',
    'mississippi',
    'abracadabra',
    'hello world',
    'banana',
    'huffman coding',
    'the quick brown fox',
    'aabbccddee',
    'programming',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  // ── Apply input ──────────────────────────────────────────────────────────────
  void _applyInput() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _processInput(text);
  }

  void _randomInput() {
    final rng = Random();
    final s = _randomStrings[rng.nextInt(_randomStrings.length)];
    _inputCtrl.text = s;
    _processInput(s);
  }

  void _processInput(String text) {
    final freqMap = HuffmanGenerator.buildFreqMap(text);
    final sorted = HuffmanGenerator.sortedFreqs(freqMap);
    final steps = HuffmanGenerator().generate(text);

    setState(() {
      _appliedInput = text;
      _freqTable = sorted;
      _steps = steps;
      _currentStep = 0;
      _playing = false;
      _finished = false;
      _results = [];
    });
  }

  // ── Animation controls ───────────────────────────────────────────────────────
  Future<void> _play() async {
    if (_steps.isEmpty) return;
    setState(() => _playing = true);
    while (_currentStep < _steps.length && _playing) {
      await Future.delayed(Duration(milliseconds: _speedMs));
      if (!mounted || !_playing) break;
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) {
          _playing = false;
          _finished = true;
          _buildResults();
        }
      });
    }
  }

  void _pause() => setState(() => _playing = false);

  void _stepFwd() {
    if (_currentStep < _steps.length) {
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) {
          _finished = true;
          _buildResults();
        }
      });
    }
  }

  void _stepBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _finished = false;
        _results = [];
      });
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _playing = false;
      _finished = false;
      _results = [];
    });
  }

  void _buildResults() {
    final step = _curStep;
    if (step == null || step.root == null) return;
    final freqMap = HuffmanGenerator.buildFreqMap(_appliedInput);
    setState(() {
      _results = HuffmanGenerator.buildResults(freqMap, step.codes);
    });
  }

  HuffStep? get _curStep =>
      (_steps.isNotEmpty &&
              _currentStep > 0 &&
              _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  // ── Frequency table widget ───────────────────────────────────────────────────
  Widget _buildFreqTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFF21262D)))),
            child: Row(
              children: const [
                Expanded(
                  child: Text('Characters',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace')),
                ),
                Expanded(
                  child: Text('Frequencies',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace')),
                ),
              ],
            ),
          ),
          // Rows
          ..._freqTable.map((cf) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xFF21262D)))),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              const Color(0xFF9333EA).withOpacity(0.15),
                          border: Border.all(
                              color: const Color(0xFF9333EA)
                                  .withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            cf.char == ' ' ? '␣' : cf.char,
                            style: const TextStyle(
                                color: Color(0xFFD8B4FE),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${cf.freq}',
                        style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Result encoding table ─────────────────────────────────────────────────────
  Widget _buildResultTable() {
    if (_results.isEmpty) return const SizedBox();

    final totalChars = _results.length;
    final totalFreq = _results.fold(0, (s, r) => s + r.freq);
    final totalBits = _results.fold(0, (s, r) => s + r.bits);
    final fixedBits = totalChars * 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Encoding Table',
                style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.12),
                border: Border.all(
                    color: const Color(0xFF22C55E).withOpacity(0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Saved ${fixedBits - totalBits} bits',
                style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 9,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            border: Border.all(color: const Color(0xFF21262D)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xFF21262D)))),
                child: Row(
                  children: const [
                    SizedBox(
                        width: 32,
                        child: Text('Char',
                            style: TextStyle(
                                color: Color(0xFF8B949E),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace'))),
                    SizedBox(
                        width: 36,
                        child: Text('Freq',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF8B949E),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace'))),
                    Expanded(
                      child: Text('Code',
                          style: TextStyle(
                              color: Color(0xFF8B949E),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace')),
                    ),
                    SizedBox(
                        width: 72,
                        child: Text('Size (bits)',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Color(0xFF8B949E),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace'))),
                  ],
                ),
              ),

              // Data rows
              ..._results.map((r) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xFF21262D)))),
                  child: Row(
                    children: [
                      // Char
                      SizedBox(
                        width: 32,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF9333EA)
                                .withOpacity(0.15),
                            border: Border.all(
                                color: const Color(0xFF9333EA)
                                    .withOpacity(0.5)),
                          ),
                          child: Center(
                            child: Text(
                              r.char == ' ' ? '␣' : r.char,
                              style: const TextStyle(
                                  color: Color(0xFFD8B4FE),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ),
                      // Freq
                      SizedBox(
                        width: 36,
                        child: Text('${r.freq}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 12,
                                fontFamily: 'monospace')),
                      ),
                      // Code
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withOpacity(0.10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(r.code,
                              style: const TextStyle(
                                  color: Color(0xFFFBBF24),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace')),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Size
                      SizedBox(
                        width: 72,
                        child: Text(
                          '${r.freq}×${r.code.length}=${r.bits}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 10,
                              fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Totals row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.07),
                  border: const Border(
                      top: BorderSide(color: Color(0xFF21262D))),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$totalChars × 8 = $fixedBits bits (fixed)',
                        style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 9,
                            fontFamily: 'monospace'),
                      ),
                    ),
                    Text(
                      '$totalFreq chars',
                      style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 9,
                          fontFamily: 'monospace'),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$totalBits bits',
                      style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab bar / content ────────────────────────────────────────────────────────
  Widget _tabBar() {
    const tabs = ['Code', 'Complexity', 'AI Tutor'];
    return Container(
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Color(0xFF21262D)))),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _activeTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color: active
                        ? const Color(0xFF9333EA)
                        : Colors.transparent,
                    width: 2,
                  )),
                ),
                child: Text(tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? const Color(0xFF9333EA)
                            : const Color(0xFF8B949E),
                        fontFamily: 'monospace')),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _tabContent() {
    switch (_activeTab) {
      case 0:
        return HuffmanCodeTab(
            onLanguageChanged: (l) => setState(() => _aiLang = l));
      case 1:
        return const HuffmanComplexityCard();
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }

  // ── AI config ────────────────────────────────────────────────────────────────
  static const _aiQuestions = [
    'How does Huffman coding work?',
    'Why is Huffman coding optimal?',
    'What is a prefix-free code?',
    'How do you decode a Huffman-encoded string?',
    'Time complexity of building the Huffman tree?',
    'How does Huffman compare to fixed-length encoding?',
  ];

  AiTutorTopicConfig _buildAiConfig() {
    final step = _curStep;
    final ctx = _appliedInput.isNotEmpty
        ? 'Input string: "$_appliedInput" '
            '(${_appliedInput.length} chars, '
            '${_freqTable.length} unique). '
            '${step != null ? "Current step: ${step.statusMsg}" : ""}'
            '${_results.isNotEmpty ? " Encoding complete. Total Huffman bits: ${_results.fold(0, (s, r) => s + r.bits)}." : ""}'
        : 'No input yet.';

    final codeSnippet = _appliedInput.isNotEmpty && _results.isNotEmpty
        ? _results
            .map((r) => "${r.char}: freq=${r.freq} code=${r.code} bits=${r.bits}")
            .join('\n')
        : '';

    return AiTutorTopicConfig(
      dashboardName: 'Huffman Coding',
      topicKey: 'huffman',
      topicLabel: 'Huffman Coding Algorithm',
      language: _aiLang,
      codeSnippet: codeSnippet,
      systemContext: ctx,
      suggestedQuestions: _aiQuestions,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final step = _curStep;
    final hasInput = _appliedInput.isNotEmpty;
    final hasSteps = _steps.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Container(
                color: const Color(0xFF161B22),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    const Icon(Icons.compress,
                        color: Color(0xFF9333EA), size: 18),
                    const SizedBox(width: 8),
                    const Text('Huffman Coding',
                        style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace')),
                    const Spacer(),
                    if (hasInput)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF9333EA).withOpacity(0.12),
                          border: Border.all(
                              color: const Color(0xFF9333EA)
                                  .withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_appliedInput.length} chars · ${_freqTable.length} unique',
                          style: const TextStyle(
                              color: Color(0xFFC084FC),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace'),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Input row ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              border: Border.all(
                                  color: const Color(0xFF30363D)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _inputCtrl,
                              style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 13,
                                  fontFamily: 'monospace'),
                              decoration: const InputDecoration(
                                hintText:
                                    'Enter string (e.g. mississippi)',
                                hintStyle: TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 12,
                                    fontFamily: 'monospace'),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _applyInput(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Apply button
                        GestureDetector(
                          onTap: _applyInput,
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9333EA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('Apply',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace')),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Random button
                        GestureDetector(
                          onTap: _randomInput,
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              border: Border.all(
                                  color: const Color(0xFF30363D)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.shuffle,
                                  color: Color(0xFF8B949E), size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Frequency table ───────────────────────────────────
                    if (hasInput) ...[
                      const Text('Frequency Table',
                          style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace')),
                      const SizedBox(height: 6),
                      _buildFreqTable(),
                      const SizedBox(height: 14),
                    ],

                    // ── Visualization canvas ──────────────────────────────
                    if (hasSteps) ...[
                      Row(
                        children: [
                          const Text('Huffman Tree',
                              style: TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace')),
                          const SizedBox(width: 8),
                          if (step != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9333EA)
                                    .withOpacity(0.12),
                                border: Border.all(
                                    color: const Color(0xFF9333EA)
                                        .withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _stepTypeLabel(step.type),
                                style: const TextStyle(
                                    color: Color(0xFFC084FC),
                                    fontSize: 9,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Queue row (during build phase)
                      if (step != null &&
                          step.queue.isNotEmpty) ...[
                        HuffQueueRow(step: step),
                        const SizedBox(height: 8),
                      ],

                      // Tree canvas
                      HuffmanTreeCanvas(
                        step: step,
                        height: 300,
                      ),

                      const SizedBox(height: 10),

                      // Animation controls
                      HuffmanAnimControls(
                        playing: _playing,
                        finished: _finished,
                        stepIndex: _currentStep,
                        totalSteps: _steps.length,
                        speedMs: _speedMs,
                        statusMsg: step?.statusMsg ??
                            'Press ▶ Play to visualize Huffman coding.',
                        onPlay: _play,
                        onPause: _pause,
                        onStepForward: _stepFwd,
                        onStepBack: _stepBack,
                        onReset: _reset,
                        onSpeedChanged: (v) =>
                            setState(() => _speedMs = v),
                      ),

                      const SizedBox(height: 14),
                    ] else if (!hasInput) ...[
                      // Empty canvas placeholder
                      HuffmanTreeCanvas(step: null, height: 220),
                      const SizedBox(height: 14),
                    ],

                    // ── Result encoding table (after done) ────────────────
                    if (_results.isNotEmpty) ...[
                      _buildResultTable(),
                      const SizedBox(height: 14),
                    ],

                    // ── Complete banner ────────────────────────────────────
                    if (_finished &&
                        step != null &&
                        step.type == HuffStepType.done) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF22C55E).withOpacity(0.10),
                          border: Border.all(
                              color: const Color(0xFF22C55E)
                                  .withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Color(0xFF22C55E), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(step.statusMsg,
                                  style: const TextStyle(
                                      color: Color(0xFF4ADE80),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Tabs ──────────────────────────────────────────────
                    _tabBar(),
                    _tabContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stepTypeLabel(HuffStepType t) {
    switch (t) {
      case HuffStepType.init:
        return 'Initializing';
      case HuffStepType.pickTwo:
        return 'Pick Two Min';
      case HuffStepType.merge:
        return 'Merging';
      case HuffStepType.addBack:
        return 'Re-queue';
      case HuffStepType.buildComplete:
        return 'Tree Built';
      case HuffStepType.assignCodes:
        return 'Assigning Codes';
      case HuffStepType.done:
        return 'Complete ✓';
    }
  }
}