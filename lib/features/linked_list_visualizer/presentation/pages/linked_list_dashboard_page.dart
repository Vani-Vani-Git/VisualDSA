import 'package:flutter/material.dart';
import 'package:visualdsa/shared/widgets/ai_tutor_panel.dart';

import '../models/ll_step.dart';
import '../models/ll_algorithms.dart';
import '../widgets/ll_input_section.dart';
import '../widgets/ll_visualizer_canvas.dart';
import '../widgets/ll_status_banner.dart';
import '../widgets/ll_operation_controls.dart';
import '../widgets/ll_code_tab.dart';
import '../widgets/ll_complexity_card.dart';

class LinkedListDashboardPage extends StatefulWidget {
  const LinkedListDashboardPage({super.key});
  @override
  State<LinkedListDashboardPage> createState() =>
      _LinkedListDashboardPageState();
}

class _LinkedListDashboardPageState extends State<LinkedListDashboardPage> {
  // ── List state ─────────────────────────────────────────────────────────────
  List<String> _list = ['10', '20', '30', '40', '50'];

  /// Snapshot of _list BEFORE the last operation ran — used by restart to
  /// rewind to the pre-operation state and re-generate steps for replay.
  List<String> _listBeforeOp = ['10', '20', '30', '40', '50'];

  // ── Last executed operation params (needed for restart replay) ─────────────
  String? _lastOp;
  String? _lastSubOp;
  String  _lastValue = '';
  int     _lastIndex = 0;

  // ── UI state ───────────────────────────────────────────────────────────────
  String _op        = 'insert';
  String _subOp     = 'head';
  String _aiLanguage = 'Python';
  int    _activeTab  = 0;

  // ── Animation state ────────────────────────────────────────────────────────
  List<LLStep> _steps       = [];
  int          _currentStep = 0;
  bool         _playing     = false;
  bool         _finished    = false;
  int          _speedMs     = 600;

  // ── Execute ────────────────────────────────────────────────────────────────
  void _onListChanged(List<String> vals) => setState(() {
        _list          = vals;
        _listBeforeOp  = List.from(vals);
        _lastOp        = null; // no previous op for the new list
        _clearAnim();
      });

  void _onExecute(String op, String subOp, String value, int index) {
    // Save state before mutation
    _listBeforeOp = List.from(_list);
    _lastOp       = op;
    _lastSubOp    = subOp;
    _lastValue    = value;
    _lastIndex    = index;

    setState(() {
      _op    = op;
      _subOp = subOp;
    });

    final newSteps = _buildSteps(op, subOp, value, index, _list);

    setState(() {
      _steps       = newSteps;
      _currentStep = 0;
      _finished    = false;
    });
    _play();
  }

  /// Pure step-builder — does NOT mutate _list.
  List<LLStep> _buildSteps(
      String op, String subOp, String value, int index, List<String> src) {
    final work = List<String>.from(src);
    switch (op) {
      case 'insert':
        switch (subOp) {
          case 'head':     return LLAlgorithms.insertHead(work, value);
          case 'tail':     return LLAlgorithms.insertTail(work, value);
          case 'position': return LLAlgorithms.insertAt(work, value, index);
          default:         return LLAlgorithms.insertHead(work, value);
        }
      case 'delete':
        switch (subOp) {
          case 'head':     return LLAlgorithms.deleteHead(work);
          case 'tail':     return LLAlgorithms.deleteTail(work);
          case 'position': return LLAlgorithms.deleteAt(work, index);
          default:         return LLAlgorithms.deleteHead(work);
        }
      case 'search':
        return LLAlgorithms.search(work, value);
      default:
        return [];
    }
  }

  // ── Playback ───────────────────────────────────────────────────────────────
  void _clearAnim() {
    _steps       = [];
    _currentStep = 0;
    _playing     = false;
    _finished    = false;
  }

  Future<void> _play() async {
    if (_steps.isEmpty) return;
    setState(() => _playing = true);

    while (_currentStep < _steps.length && _playing) {
      await Future.delayed(Duration(milliseconds: _speedMs));
      if (!mounted || !_playing) break;
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) {
          _playing  = false;
          _finished = true;
          _applyMutation();
        }
      });
    }
  }

  /// Commit the structural change to _list when animation finishes.
  void _applyMutation() {
    if (_steps.isEmpty) return;
    final last = _steps.last;
    if (last.nodes.isNotEmpty) {
      _list = last.nodes.map((n) => n.value).toList();
    } else if (last.phase == LLPhase.done) {
      _list = [];
    }
  }

  void _pause() => setState(() => _playing = false);

  void _stepForward() {
    if (_currentStep < _steps.length) {
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) {
          _finished = true;
          _applyMutation();
        }
      });
    }
  }

  void _stepBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _finished = false;
      });
    }
  }

  /// ── RESTART FIX ──────────────────────────────────────────────────────────
  /// 1. Rewind _list to the pre-operation snapshot.
  /// 2. Re-generate steps from that snapshot.
  /// 3. Reset animation cursors so Play works immediately.
  void _hardReset() {
    if (_lastOp == null) {
      // No operation has run yet — just clear animation.
      setState(() => _clearAnim());
      return;
    }

    // Restore list to pre-op state
    final restoredList = List<String>.from(_listBeforeOp);

    // Re-generate steps from the restored list
    final freshSteps = _buildSteps(
      _lastOp!, _lastSubOp!, _lastValue, _lastIndex, restoredList,
    );

    setState(() {
      _list        = restoredList;
      _steps       = freshSteps;
      _currentStep = 0;
      _playing     = false;
      _finished    = false;
    });
  }

  LLStep? get _currentStepData =>
      (_steps.isNotEmpty && _currentStep > 0 && _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  // ── AI config ──────────────────────────────────────────────────────────────
  static const _opLabels = {
    'insert': 'Insertion',
    'delete': 'Deletion',
    'search': 'Searching',
  };
  static const _subLabels = {
    'head':     'At Head',
    'tail':     'At Tail',
    'position': 'At Position',
  };
  static const _opQuestions = {
    'insert': [
      'How does linked list insertion work?',
      'What is the time complexity of insertion at head?',
      'How do you insert at a specific position?',
      'What is the pred pointer used for?',
      'Compare array insertion vs linked list insertion.',
    ],
    'delete': [
      'How does linked list deletion work?',
      'What is the time complexity of deleting head?',
      'How do you delete a node at a specific index?',
      'What are temp and pred pointers?',
      'Why is deleting tail O(n)?',
    ],
    'search': [
      'How does linked list search work?',
      'What is the time complexity of searching?',
      'Why is LL search O(n) and not O(log n)?',
      'What is the tmp pointer in searching?',
      'How does searching compare with arrays?',
    ],
  };

  AiTutorTopicConfig _buildAiConfig() {
    final step  = _currentStepData;
    final label =
        '${_opLabels[_op]} ${_op != 'search' ? _subLabels[_subOp] ?? '' : ''}'
            .trim();
    final ctx =
        'Linked List: [${_list.join(' → ')}]. Operation: $label. '
        '${step != null ? step.statusMsg : 'Not started.'}';
    return AiTutorTopicConfig(
      dashboardName: 'Linked List',
      topicKey: '${_op}_$_subOp',
      topicLabel: label,
      language: _aiLanguage,
      systemContext: ctx,
      suggestedQuestions: _opQuestions[_op] ?? [],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final step = _currentStepData;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(children: [
          // Input bar
          LLInputSection(
            initialValue: _list.join(', '),
            onChanged: _onListChanged,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: 10),

                // Status banner
                LLStatusBanner(step: step),
                const SizedBox(height: 8),

                // Canvas
                LLVisualizerCanvas(
                  step: step,
                  defaultList: _list,
                  height: 190,
                ),
                const SizedBox(height: 12),

                // Controls
                LLOperationControls(
                  playing:    _playing,
                  finished:   _finished,
                  stepIndex:  _currentStep,
                  totalSteps: _steps.length,
                  speedMs:    _speedMs,
                  onExecute:      _onExecute,
                  onPlay:         _play,
                  onPause:        _pause,
                  onStepForward:  _stepForward,
                  onStepBack:     _stepBack,
                  onReset:        _hardReset,
                  onSpeedChanged: (v) => setState(() => _speedMs = v),
                ),

                const SizedBox(height: 14),

                _buildTabBar(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildTabContent(),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = ['Code', 'Complexity', 'AI Tutor'];
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF21262D)))),
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
                          ? const Color(0xFF3B82F6)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF8B949E),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Tab content ────────────────────────────────────────────────────────────
  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return LLCodeTab(
          operation:    _op,
          subOperation: _subOp,
          onLanguageChanged: (l) => setState(() => _aiLanguage = l),
        );
      case 1:
        return LLComplexityCard(operation: _op, subOperation: _subOp);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}