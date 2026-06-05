import 'package:flutter/material.dart';
import 'package:visualdsa/shared/widgets/ai_tutor_panel.dart';

import '../models/bst_node.dart';
import '../models/bst_algorithms.dart';
import '../widgets/bst_input_section.dart';   // ← modified (Draw button)
import '../widgets/bst_visualizer_canvas.dart';
import '../widgets/bst_step_header.dart';
import '../widgets/bst_operation_controls.dart';
import '../widgets/bst_code_tab.dart';
import '../widgets/bst_complexity_card.dart';

class BSTDashboardPage extends StatefulWidget {
  const BSTDashboardPage({super.key});

  @override
  State<BSTDashboardPage> createState() => _BSTDashboardPageState();
}

class _BSTDashboardPageState extends State<BSTDashboardPage> {
  // ── Tree state ─────────────────────────────────────────────────────────────
  BSTNode? _root;
  List<int> _inputValues = [50, 30, 70, 20, 40, 60];

  // ── Pre-operation snapshot (for restart) ───────────────────────────────────
  List<int> _valuesBeforeOp = [50, 30, 70, 20, 40, 60];
  String? _lastOp;
  int     _lastKey = 0;

  // ── UI state ───────────────────────────────────────────────────────────────
  String _selectedOp = 'insert';
  String _aiLanguage = 'Python';
  int    _activeTab  = 0;

  // ── Animation state ────────────────────────────────────────────────────────
  List<BSTStep> _steps       = [];
  int           _currentStep = 0;
  bool          _playing     = false;
  bool          _finished    = false;
  int           _speedMs     = 700;

  @override
  void initState() {
    super.initState();
    _root = BSTAlgorithms.buildFromList(_inputValues);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _onArrayChanged(List<int> values) {
    setState(() {
      _inputValues    = values;
      _valuesBeforeOp = List.from(values);
      _root           = BSTAlgorithms.buildFromList(values);
      _lastOp         = null;
      _clearAnim();
    });
  }

  void _onOpChanged(String op) => setState(() {
        _selectedOp = op;
        _clearAnim();
      });

  void _onExecute(int value) {
    if (_root == null && _selectedOp != 'insert') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BST is empty! Add nodes first.',
              style: TextStyle(fontFamily: 'monospace')),
          backgroundColor: Color(0xFF1C2128),
        ),
      );
      return;
    }

    // Save pre-op snapshot for restart
    _valuesBeforeOp = List.from(_inputValues);
    _lastOp  = _selectedOp;
    _lastKey = value;

    final newSteps = _buildSteps(_selectedOp, value, _root);

    setState(() {
      _steps       = newSteps;
      _currentStep = 0;
      _finished    = false;
    });
    _play();
  }

  /// Pure step builder — never mutates _root directly.
  List<BSTStep> _buildSteps(String op, int key, BSTNode? root) {
    final work = cloneBST(root);
    switch (op) {
      case 'insert': return BSTAlgorithms.insert(work, key);
      case 'delete': return BSTAlgorithms.delete(work, key);
      case 'search': return BSTAlgorithms.search(work, key);
      default:       return [];
    }
  }

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

  void _applyMutation() {
    if (_steps.isEmpty) return;
    final last = _steps.last;
    if (last.root != null) {
      _root        = last.root;
      _inputValues = _collectValues(_root);
    } else if (_selectedOp == 'delete') {
      _root        = null;
      _inputValues = [];
    }
  }

  List<int> _collectValues(BSTNode? node) {
    if (node == null) return [];
    final result = <int>[];
    final queue  = <BSTNode>[node];
    while (queue.isNotEmpty) {
      final n = queue.removeAt(0);
      result.add(n.value);
      if (n.left  != null) queue.add(n.left!);
      if (n.right != null) queue.add(n.right!);
    }
    return result;
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
      setState(() { _currentStep--; _finished = false; });
    }
  }

  /// Restart: rewind tree to pre-op state and re-generate steps.
  void _hardReset() {
    if (_lastOp == null) {
      setState(() => _clearAnim());
      return;
    }
    final restoredRoot   = BSTAlgorithms.buildFromList(_valuesBeforeOp);
    final freshSteps     = _buildSteps(_lastOp!, _lastKey, restoredRoot);
    setState(() {
      _inputValues = List.from(_valuesBeforeOp);
      _root        = restoredRoot;
      _steps       = freshSteps;
      _currentStep = 0;
      _playing     = false;
      _finished    = false;
    });
  }

  BSTStep? get _currentStepData =>
      (_steps.isNotEmpty && _currentStep > 0 && _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  // ── AI config ──────────────────────────────────────────────────────────────
  static const _opLabels = {
    'insert': 'BST Insertion',
    'delete': 'BST Deletion',
    'search': 'BST Searching',
  };
  static const _opQuestions = {
    'insert': ['How does BST insertion work?','Why is BST insert O(log n) on average?','What happens when inserting a duplicate?','How does BST differ from a regular binary tree insert?','Show a non-recursive BST insert.'],
    'delete': ['How does BST deletion work?','What are the 3 cases of BST deletion?','What is an inorder successor?','Why use the inorder successor for deletion?','Show a non-recursive BST delete.'],
    'search': ['How does BST search work?','Why is BST search faster than linear search?','What is the worst case for BST search?','What makes a BST degenerate?','Show an iterative BST search.'],
  };

  AiTutorTopicConfig _buildAiConfig() {
    final step = _currentStepData;
    final ctx  =
        'BST nodes (insertion order): [${_inputValues.join(', ')}]. '
        'BST property: left < node < right. '
        '${step != null ? '${step.stepTitle}. ${step.sideNote}' : 'No operation running.'}';
    return AiTutorTopicConfig(
      dashboardName: 'Binary Search Tree',
      topicKey:      _selectedOp,
      topicLabel:    _opLabels[_selectedOp] ?? _selectedOp,
      language:      _aiLanguage,
      systemContext: ctx,
      suggestedQuestions: _opQuestions[_selectedOp] ?? [],
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
          // ── Input bar (Apply | Random | Draw) ───────────────────────────
          BSTInputSection(
            initialValue:   _inputValues.join(','),
            onArrayChanged: _onArrayChanged,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: 10),

                // Step header
                BSTStepHeader(step: step),
                const SizedBox(height: 10),

                // Tree canvas
                BSTVisualizerCanvas(
                  root: _root,
                  step: step,
                  height: 270,
                ),
                const SizedBox(height: 12),

                // Operation controls
                BSTOperationControls(
                  selectedOp:     _selectedOp,
                  playing:        _playing,
                  finished:       _finished,
                  stepIndex:      _currentStep,
                  totalSteps:     _steps.length,
                  speedMs:        _speedMs,
                  onOpChanged:    _onOpChanged,
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
                            ? const Color(0xFF4CAF50) // BST green accent
                            : Colors.transparent,
                        width: 2),
                  ),
                ),
                child: Text(tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF8B949E),
                        fontFamily: 'monospace')),
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
        return BSTCodeTab(
            operation: _selectedOp,
            onLanguageChanged: (l) => setState(() => _aiLanguage = l));
      case 1:
        return BSTComplexityCard(operation: _selectedOp);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}