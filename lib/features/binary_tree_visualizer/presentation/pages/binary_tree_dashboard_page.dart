import 'package:flutter/material.dart';
import 'package:visualdsa/shared/widgets/ai_tutor_panel.dart';

import '../models/tree_node.dart';
import '../models/tree_algorithms.dart';
import '../widgets/tree_input_section.dart';
import '../widgets/tree_visualizer_canvas.dart';
import '../widgets/tree_operation_controls.dart';
import '../widgets/tree_status_banner.dart';
import '../widgets/traversal_order_strip.dart';
import '../widgets/tree_code_tab.dart';
import '../widgets/tree_complexity_card.dart';
import '../widgets/tree_draw_canvas.dart';   // ← NEW

class BinaryTreeDashboardPage extends StatefulWidget {
  const BinaryTreeDashboardPage({super.key});

  @override
  State<BinaryTreeDashboardPage> createState() =>
      _BinaryTreeDashboardPageState();
}

class _BinaryTreeDashboardPageState extends State<BinaryTreeDashboardPage> {
  // ── Tree state ─────────────────────────────────────────────────────────────
  TreeNode? _root;
  List<int> _inputValues = [1, 2, 3, 4, 5, 6, 7];

  // ── Operation state ────────────────────────────────────────────────────────
  String _selectedOp = 'inorder';
  String _aiLanguage = 'Python';
  int _activeTab = 0;

  // ── Animation state ────────────────────────────────────────────────────────
  List<TreeStep> _steps = [];
  int _currentStep = 0;
  bool _playing = false;
  bool _finished = false;
  int _speedMs = 600;

  // ── Last-op cache (for restart) ────────────────────────────────────────────
  List<int> _inputValuesBeforeOp = [];
  String? _lastOp;
  int? _lastOpValue;

  @override
  void initState() {
    super.initState();
    _root = TreeAlgorithms.buildFromList(_inputValues);
  }

  // ── Callbacks ──────────────────────────────────────────────────────────────

  void _onArrayChanged(List<int> values) {
    setState(() {
      _inputValues = values;
      _root = TreeAlgorithms.buildFromList(values);
      _reset();
    });
  }

  // ── DRAW button handler ────────────────────────────────────────────────────
  void _onDrawTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TreeDrawCanvas(
          onConfirm: (root, levelOrder) {
            setState(() {
              _root = root;
              _inputValues = levelOrder;
              _inputValuesBeforeOp = List.from(levelOrder);
              _lastOp = null;
              _reset();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ Drawn tree loaded! Nodes: [${levelOrder.join(', ')}]',
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12),
                ),
                backgroundColor: const Color(0xFF1C2128),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onOpChanged(String op) {
    setState(() {
      _selectedOp = op;
      _reset();
    });
  }

  void _onExecute(int value) {
    if (_root == null && _selectedOp != 'insert') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tree is empty! Add nodes first.',
              style: TextStyle(fontFamily: 'monospace')),
          backgroundColor: Color(0xFF1C2128),
        ),
      );
      return;
    }

    // Save state before any mutation
    _inputValuesBeforeOp = List.from(_inputValues);
    _lastOp = _selectedOp;
    _lastOpValue = value;

    List<TreeStep> newSteps;
    switch (_selectedOp) {
      case 'insert':
        final workRoot = cloneTree(_root);
        newSteps = TreeAlgorithms.insert(workRoot, value);
        // Pre-apply the insertion so the final tree state is available
        _root = TreeAlgorithms.buildFromList([..._inputValues, value]);
        _inputValues = [..._inputValues, value];
        break;
      case 'delete':
        final workRoot = cloneTree(_root);
        newSteps = TreeAlgorithms.delete(workRoot, value);
        break;
      case 'inorder':
        newSteps = TreeAlgorithms.inorder(_root);
        break;
      case 'preorder':
        newSteps = TreeAlgorithms.preorder(_root);
        break;
      case 'postorder':
        newSteps = TreeAlgorithms.postorder(_root);
        break;
      default:
        return;
    }

    setState(() {
      _steps = newSteps;
      _currentStep = 0;
      _finished = false;
    });
    _play();
  }

  void _reset() {
    _steps = [];
    _currentStep = 0;
    _playing = false;
    _finished = false;
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
          _playing = false;
          _finished = true;
          _applyMutation();
        }
      });
    }
  }

  void _applyMutation() {
    if (_steps.isEmpty) return;
    final lastRoot = _steps.last.root;
    if (lastRoot != null) {
      _root = lastRoot;
      _inputValues = _collectLevelOrder(_root);
    } else if (_selectedOp == 'delete') {
      _root = null;
      _inputValues = [];
    }
  }

  List<int> _collectLevelOrder(TreeNode? node) {
    if (node == null) return [];
    final result = <int>[];
    final queue = <TreeNode>[node];
    while (queue.isNotEmpty) {
      final n = queue.removeAt(0);
      result.add(n.value);
      if (n.left != null) queue.add(n.left!);
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
      setState(() {
        _currentStep--;
        _finished = false;
      });
    }
  }

  // ── Restart — rewind & replay ──────────────────────────────────────────────
  void _hardReset() {
    if (_lastOp == null) {
      setState(() {
        _root = TreeAlgorithms.buildFromList(_inputValues);
        _reset();
      });
      return;
    }

    // Rewind to pre-op tree
    final rewoundRoot =
        TreeAlgorithms.buildFromList(_inputValuesBeforeOp);

    List<TreeStep> freshSteps;
    switch (_lastOp!) {
      case 'insert':
        freshSteps = TreeAlgorithms.insert(
            cloneTree(rewoundRoot), _lastOpValue!);
        // Re-apply insertion so tree is correct after replay
        _root = TreeAlgorithms.buildFromList(
            [..._inputValuesBeforeOp, _lastOpValue!]);
        _inputValues = [..._inputValuesBeforeOp, _lastOpValue!];
        break;
      case 'delete':
        freshSteps =
            TreeAlgorithms.delete(cloneTree(rewoundRoot), _lastOpValue!);
        _root = rewoundRoot;
        _inputValues = List.from(_inputValuesBeforeOp);
        break;
      case 'inorder':
        freshSteps = TreeAlgorithms.inorder(rewoundRoot);
        _root = rewoundRoot;
        _inputValues = List.from(_inputValuesBeforeOp);
        break;
      case 'preorder':
        freshSteps = TreeAlgorithms.preorder(rewoundRoot);
        _root = rewoundRoot;
        _inputValues = List.from(_inputValuesBeforeOp);
        break;
      case 'postorder':
        freshSteps = TreeAlgorithms.postorder(rewoundRoot);
        _root = rewoundRoot;
        _inputValues = List.from(_inputValuesBeforeOp);
        break;
      default:
        setState(() => _reset());
        return;
    }

    setState(() {
      _steps = freshSteps;
      _currentStep = 0;
      _playing = false;
      _finished = false;
    });
  }

  TreeStep? get _currentStepData =>
      (_steps.isNotEmpty &&
              _currentStep > 0 &&
              _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  // ── AI config ──────────────────────────────────────────────────────────────
  static const _opLabels = {
    'insert':   'Insert Node',
    'delete':   'Delete Node',
    'inorder':  'Inorder Traversal',
    'preorder': 'Preorder Traversal',
    'postorder':'Postorder Traversal',
  };
  static const _opQuestions = {
    'insert':   ['How does level-order insertion work?','Why use BFS for binary tree insertion?','What is the time complexity of insertion?','How is BT insert different from BST insert?'],
    'delete':   ['How does binary tree deletion work?','Why replace with the deepest node?','What is the deepest rightmost node?','How is deletion different from BST deletion?'],
    'inorder':  ['What is inorder traversal?','When does inorder give sorted output?','What is the time complexity?','Can inorder be done iteratively?'],
    'preorder': ['What is preorder traversal?','What are real-world uses of preorder?','How does preorder differ from inorder?','Show an iterative version of preorder.'],
    'postorder':['What is postorder traversal?','Why is postorder used for tree deletion?','How does postorder differ from preorder?','What is the space complexity?'],
  };

  AiTutorTopicConfig _buildAiConfig() {
    final step = _currentStepData;
    final ctx =
        'Tree nodes (level-order): [${_inputValues.join(', ')}]. '
        '${step != null ? step.statusMsg : 'No operation running yet.'}';
    return AiTutorTopicConfig(
      dashboardName: 'Binary Tree Operations',
      topicKey: _selectedOp,
      topicLabel: _opLabels[_selectedOp] ?? _selectedOp,
      language: _aiLanguage,
      systemContext: ctx,
      suggestedQuestions: _opQuestions[_selectedOp] ?? [],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final step = _currentStepData;
    final displayRoot = step?.root ?? _root;
    final phase = step?.phase ?? TreePhase.idle;
    final statusMsg = step?.statusMsg ?? '';
    final visitedOrder = step?.visitedOrder ?? [];
    final highlightPath = step?.highlightPath ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(children: [
          // ── Input section (with Draw button) ──────────────────────────
          TreeInputSection(
            initialValue: _inputValues.join(','),
            onArrayChanged: _onArrayChanged,
            onDrawTap: _onDrawTap,          // ← Draw button wired here
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: 10),

                TreeStatusBanner(message: statusMsg, phase: phase),
                const SizedBox(height: 8),

                TreeVisualizerCanvas(
                  root: displayRoot,
                  highlightNode: step?.highlightNode,
                  secondaryNode: step?.secondaryNode,
                  visitedOrder: visitedOrder,
                  highlightPath: highlightPath,
                  phase: phase,
                  height: 260,
                ),
                const SizedBox(height: 8),

                if (visitedOrder.isNotEmpty)
                  TraversalOrderStrip(
                      visitedOrder: visitedOrder,
                      operation: _selectedOp),
                if (visitedOrder.isNotEmpty) const SizedBox(height: 8),

                TreeOperationControls(
                  selectedOp: _selectedOp,
                  playing: _playing,
                  finished: _finished,
                  stepIndex: _currentStep,
                  totalSteps: _steps.length,
                  speedMs: _speedMs,
                  onOpChanged: _onOpChanged,
                  onExecute: _onExecute,
                  onPlay: _play,
                  onPause: _pause,
                  onStepForward: _stepForward,
                  onStepBack: _stepBack,
                  onReset: _hardReset,
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
                child: Text(tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF8B949E),
                        fontFamily: 'monospace')),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return TreeCodeTabSection(
            operation: _selectedOp,
            onLanguageChanged: (l) => setState(() => _aiLanguage = l));
      case 1:
        return TreeComplexityCard(operation: _selectedOp);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}