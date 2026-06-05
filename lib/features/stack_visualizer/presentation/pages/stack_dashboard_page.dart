import 'package:flutter/material.dart';
import '../models/stack_step.dart';
import '../models/stack_operations.dart';
import '../widgets/stack_array_input_section.dart';
import '../widgets/stack_canvas.dart';
import '../widgets/stack_operation_dropdown.dart';
import '../widgets/stack_controls.dart';
import '../widgets/stack_code_tab_section.dart';
import '../widgets/stack_complexity_card.dart';
import 'package:visualdsa/shared/widgets/ai_tutor_panel.dart';

class StackDashboardPage extends StatefulWidget {
  const StackDashboardPage({super.key});

  @override
  State<StackDashboardPage> createState() => _StackDashboardPageState();
}

class _StackDashboardPageState extends State<StackDashboardPage> {
  // ── State ──────────────────────────────────────────────────────────────────
  // _inputArray  = the user's typed / random values shown in the input bar.
  //                When Apply is pressed this becomes the live stack.
  // _stack       = the live stack being operated on (push/pop/peek mutate this).
  List<int> _inputArray = [10, 20, 30];
  List<int> _stack      = [10, 20, 30];

  String _selectedOp = 'push';
  int    _activeTab  = 0;
  String _aiLanguage = 'Python';

  List<StackStep> _steps       = [];
  int             _currentStep = 0;
  bool            _playing     = false;
  bool            _finished    = false;
  int             _speedMs     = 600;

  // ── Replay state — remembers last operation so Restart can replay it ───────
  List<int> _preOpStack = []; // stack snapshot BEFORE the last op ran
  String    _lastOp     = ''; // 'push'|'pop'|'peek'|'pushAll'
  int       _lastOpVal  = 0;  // value used for push

  // ── Metadata ───────────────────────────────────────────────────────────────

  static const _opLabels = {
    'push': 'Push',
    'pop' : 'Pop',
    'peek': 'Peek',
  };

  static const _opQuestions = {
    'push': [
      'How does Push work in a Stack?',
      'What is Stack Overflow?',
      'What is the time complexity of Push?',
      'How is Stack different from Queue in Push?',
      'Show me Push using an array implementation',
    ],
    'pop': [
      'How does Pop work in a Stack?',
      'What is Stack Underflow?',
      'What is the time complexity of Pop?',
      'What happens to the popped element in memory?',
      'Show me Pop using a linked list implementation',
    ],
    'peek': [
      'What is the Peek operation?',
      'How is Peek different from Pop?',
      'When would you use Peek?',
      'What is the time complexity of Peek?',
      'Show me a real-world use case for Peek',
    ],
  };

  static const Map<String, Map<String, String>> _codeSnippets = {
    'push': {
      'Python':
          'def push(self, value):\n    if len(self.stack) >= self.max_size:\n        raise OverflowError("Stack Overflow!")\n    self.stack.append(value)',
      'Java':
          'public void push(int value) {\n    if (stack.size() >= MAX_SIZE)\n        throw new RuntimeException("Stack Overflow!");\n    stack.push(value);\n}',
      'C':
          'void push(int value) {\n    if (top >= MAX - 1) { printf("Overflow!"); return; }\n    stack[++top] = value;\n}',
      'C++':
          'void push(int value) {\n    if ((int)st.size() >= MAX_SIZE)\n        throw overflow_error("Stack Overflow!");\n    st.push(value);\n}',
    },
    'pop': {
      'Python':
          'def pop(self):\n    if not self.stack:\n        raise IndexError("Stack Underflow!")\n    return self.stack.pop()',
      'Java':
          'public int pop() {\n    if (stack.isEmpty())\n        throw new RuntimeException("Stack Underflow!");\n    return stack.pop();\n}',
      'C':
          'int pop() {\n    if (top < 0) { printf("Underflow!"); return -1; }\n    return stack[top--];\n}',
      'C++':
          'int pop() {\n    if (st.empty())\n        throw underflow_error("Stack Underflow!");\n    int v = st.top(); st.pop(); return v;\n}',
    },
    'peek': {
      'Python':
          'def peek(self):\n    if not self.stack:\n        raise IndexError("Stack is empty!")\n    return self.stack[-1]  # No removal',
      'Java':
          'public int peek() {\n    if (stack.isEmpty())\n        throw new RuntimeException("Stack is empty!");\n    return stack.peek();  // No removal\n}',
      'C':
          'int peek() {\n    if (top < 0) { printf("Empty!"); return -1; }\n    return stack[top];  // No removal\n}',
      'C++':
          'int peek() {\n    if (st.empty())\n        throw runtime_error("Stack is empty!");\n    return st.top();  // No removal\n}',
    },
  };

  // ── Array input callbacks ──────────────────────────────────────────────────

  /// Called when user presses Apply or Random.
  /// Clears the live stack to empty, then animates each element being pushed
  /// one-by-one using the pushAll sequence — so the user sees every element
  /// fly into the stack in order.
  void _onArrayChanged(List<int> newArray) {
    setState(() {
      _preOpStack  = [];                   // no pre-state for fresh build
      _lastOp      = 'pushAll';
      _lastOpVal   = 0;
      _inputArray  = List.from(newArray);
      _stack       = [];
      _playing     = false;
      _finished    = false;
      _steps       = StackOperations.pushAll(newArray);
      _currentStep = 0;
    });
    // Store input so Restart can rebuild from scratch
    _preOpStack = List.from(newArray);
    _play();
  }

  // ── Operation helpers ──────────────────────────────────────────────────────

  void _onOpChanged(String op) {
    setState(() {
      _selectedOp  = op;
      // Clear animation only — _stack stays so canvas keeps showing the tree
      _steps       = [];
      _currentStep = 0;
      _playing     = false;
      _finished    = false;
    });
  }

  void _reset() {
    _steps       = [];
    _currentStep = 0;
    _playing     = false;
    _finished    = false;
  }

  void _onExecute(int value) {
    setState(() {
      // Capture pre-op snapshot so Restart can replay this exact operation
      _preOpStack = List.from(_stack);
      _lastOp     = _selectedOp;
      _lastOpVal  = value;
      _reset();
      switch (_selectedOp) {
        case 'push':
          _steps = StackOperations.push(List.from(_stack), value);
          break;
        case 'pop':
          _steps = StackOperations.pop(List.from(_stack));
          break;
        case 'peek':
          _steps = StackOperations.peek(List.from(_stack));
          break;
      }
      _currentStep = 0;
    });
    _play();
  }

  Future<void> _play() async {
    // Guard: do nothing if no steps are ready yet
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
          _commitFinalStack();
        }
      });
    }
  }

  /// After animation completes, persist the final stack state.
  /// For pushAll: commits whichever elements made it in (respects overflow cap).
  /// For push/pop/peek: commits only on success.
  void _commitFinalStack() {
    if (_steps.isNotEmpty) {
      final last = _steps.last;
      final isError = last.phase == 'overflow' && last.stack.isEmpty ||
          last.phase == 'underflow';
      if (!isError) {
        _stack = List.from(last.stack);
        // Mirror back into input bar only for pushAll (idle final frame)
        // so the bar always reflects the true live stack after loading.
        if (last.phase == 'idle' || last.phase == 'overflow') {
          _inputArray = List.from(last.stack);
        }
      }
    }
  }

  void _pause() => setState(() => _playing = false);

  void _stepForward() {
    if (_currentStep < _steps.length) {
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) {
          _finished = true;
          _commitFinalStack();
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

  /// Restart: restore the pre-op stack and regenerate the same steps so
  /// Play works immediately after pressing Restart.
  void _hardReset() {
    if (_lastOp.isNotEmpty && _preOpStack.isNotEmpty) {
      // Restore stack to the state it had before the operation
      setState(() {
        _stack       = List.from(_preOpStack);
        _playing     = false;
        _finished    = false;
        _currentStep = 0;
      });
      // Regenerate the exact same steps
      switch (_lastOp) {
        case 'push':
          setState(() {
            _steps = StackOperations.push(
                List.from(_preOpStack), _lastOpVal);
            _currentStep = 0;
          });
          break;
        case 'pop':
          setState(() {
            _steps = StackOperations.pop(List.from(_preOpStack));
            _currentStep = 0;
          });
          break;
        case 'peek':
          setState(() {
            _steps = StackOperations.peek(List.from(_preOpStack));
            _currentStep = 0;
          });
          break;
        case 'pushAll':
          setState(() {
            _stack = [];
            _steps = StackOperations.pushAll(_preOpStack);
            _currentStep = 0;
          });
          break;
      }
    } else {
      // No previous op — just clear animation, stack stays visible
      setState(() {
        _steps       = [];
        _currentStep = 0;
        _playing     = false;
        _finished    = false;
      });
    }
  }

  StackStep? get _currentStepData =>
      (_steps.isNotEmpty && _currentStep > 0 && _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  /// When no animation is running, synthesise an idle StackStep from the
  /// live _stack so the canvas always shows the current stack state.
  StackStep get _displayStep =>
      _currentStepData ??
      StackStep(
        stack    : List.from(_stack),
        phase    : 'idle',
        statusMsg: _stack.isEmpty
            ? 'Stack is empty. Apply an array or select an operation to begin.'
            : _steps.isEmpty
                ? 'Stack ready (size ${_stack.length}/${StackOperations.maxSize}). '
                  'Select an operation and press its button to start.'
                : 'Ready.',
        operation: 'none',
      );

  // ── AI Tutor config ────────────────────────────────────────────────────────

  AiTutorTopicConfig _buildAiConfig() {
    final ctx = 'Stack: [${_stack.join(', ')}] (bottom→top). '
        'Operation: ${_opLabels[_selectedOp]}. '
        '${_currentStepData != null ? _currentStepData!.statusMsg : 'Not started yet.'}';

    return AiTutorTopicConfig(
      dashboardName    : 'Stack Data Structure',
      topicKey         : _selectedOp,
      topicLabel       : '${_opLabels[_selectedOp]} Operation',
      language         : _aiLanguage,
      codeSnippet      : _codeSnippets[_selectedOp]?[_aiLanguage] ?? '',
      systemContext    : ctx,
      suggestedQuestions: _opQuestions[_selectedOp] ?? [],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // FIX: use _displayStep (never null) so canvas always shows the stack
    final step = _displayStep;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // ── Array input bar (pinned at top, outside scroll) ─────────
            StackArrayInputSection(
              initialArray : _inputArray,
              maxSize      : StackOperations.maxSize,
              onArrayChanged: _onArrayChanged,
            ),

            // ── Scrollable body ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stack visualization canvas
                    StackCanvas(
                      step   : step,
                      maxSize: StackOperations.maxSize,
                    ),

                    const SizedBox(height: 8),

                    // Operation dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: StackOperationDropdown(
                        selected : _selectedOp,
                        onChanged: _onOpChanged,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Controls (value input + play/step/speed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: StackControls(
                        operation     : _selectedOp,
                        playing       : _playing,
                        finished      : _finished,
                        stepIndex     : _currentStep,
                        totalSteps    : _steps.isEmpty ? 0 : _steps.length,
                        speedMs       : _speedMs,
                        onPlay        : _steps.isNotEmpty ? _play : null,
                        onPause       : _pause,
                        onStepForward : _stepForward,
                        onStepBack    : _stepBack,
                        onReset       : _hardReset,
                        onSpeedChanged: (v) => setState(() => _speedMs = v),
                        onExecute     : _onExecute,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tab bar
                    _buildTabBar(),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildTabContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = ['Code', 'Complexity', 'AI Tutor'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
      ),
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
                      color: active ? const Color(0xFF3B82F6) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize    : 13,
                    fontWeight  : FontWeight.w700,
                    color       : active
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF8B949E),
                    fontFamily  : 'monospace',
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
        return StackCodeTabSection(
          operation         : _selectedOp,
          onLanguageChanged : (l) => setState(() => _aiLanguage = l),
        );
      case 1:
        return StackComplexityCard(operation: _selectedOp);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}