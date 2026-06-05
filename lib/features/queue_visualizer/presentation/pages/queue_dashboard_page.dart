import 'package:flutter/material.dart';
import '../models/queue_step.dart';
import '../models/queue_operations.dart';
import '../widgets/queue_array_input_section.dart';
import '../widgets/queue_canvas.dart';
import '../widgets/queue_operation_dropdown.dart';
import '../widgets/queue_controls.dart';
import '../widgets/queue_code_tab_section.dart';
import '../widgets/queue_complexity_card.dart';
import 'package:visualdsa/shared/widgets/ai_tutor_panel.dart';

class QueueDashboardPage extends StatefulWidget {
  const QueueDashboardPage({super.key});

  @override
  State<QueueDashboardPage> createState() => _QueueDashboardPageState();
}

class _QueueDashboardPageState extends State<QueueDashboardPage> {
  // ── State ──────────────────────────────────────────────────────────────────
  List<int> _inputArray = [10, 20, 30];
  List<int> _queue      = [10, 20, 30];

  String _selectedOp = 'enqueue';
  int    _activeTab  = 0;
  String _aiLanguage = 'Python';

  List<QueueStep> _steps       = [];
  int             _currentStep = 0;
  bool            _playing     = false;
  bool            _finished    = false;
  int             _speedMs     = 600;

  // ── Replay state — remembers last operation so Restart can replay it ───────
  List<int> _preOpQueue = []; // queue snapshot BEFORE the last op
  String    _lastOp     = ''; // 'enqueue'|'dequeue'|'peek'|'enqueueAll'
  int       _lastOpVal  = 0;  // value used for enqueue

  // ── Metadata ───────────────────────────────────────────────────────────────
  static const _opLabels = {
    'enqueue': 'Enqueue',
    'dequeue': 'Dequeue',
    'peek'   : 'Peek',
  };

  static const _opQuestions = {
    'enqueue': [
      'How does Enqueue work in a Queue?',
      'What is Queue Overflow?',
      'What is the time complexity of Enqueue?',
      'How is Queue different from Stack in Enqueue?',
      'Show me Enqueue using a circular array implementation',
    ],
    'dequeue': [
      'How does Dequeue work in a Queue?',
      'What is Queue Underflow?',
      'What is the time complexity of Dequeue?',
      'How does front pointer move after Dequeue?',
      'Show me Dequeue using a linked list implementation',
    ],
    'peek': [
      'What is the Peek operation in a Queue?',
      'How is Queue Peek different from Stack Peek?',
      'When would you use Peek in a Queue?',
      'What is the time complexity of Peek?',
      'Show me a real-world use case for Queue Peek',
    ],
  };

  static const Map<String, Map<String, String>> _codeSnippets = {
    'enqueue': {
      'Python': 'def enqueue(self, value):\n    if len(self.queue) >= self.max_size:\n        raise OverflowError("Queue is Full!")\n    self.queue.append(value)  # Insert at REAR',
      'Java'  : 'public void enqueue(int value) {\n    if (queue.size() >= MAX_SIZE)\n        throw new RuntimeException("Queue is Full!");\n    queue.offer(value); // Insert at REAR\n}',
      'C'     : 'void enqueue(int value) {\n    if (rear >= MAX - 1) { printf("Overflow!"); return; }\n    if (front == -1) front = 0;\n    queue[++rear] = value;\n}',
      'C++'   : 'void enqueue(int value) {\n    if ((int)q.size() >= MAX_SIZE)\n        throw overflow_error("Queue is Full!");\n    q.push(value); // Insert at REAR\n}',
    },
    'dequeue': {
      'Python': 'def dequeue(self):\n    if not self.queue:\n        raise IndexError("Queue is Empty!")\n    return self.queue.popleft()  # Remove from FRONT',
      'Java'  : 'public int dequeue() {\n    if (queue.isEmpty())\n        throw new RuntimeException("Queue is Empty!");\n    return queue.poll(); // Remove from FRONT\n}',
      'C'     : 'int dequeue() {\n    if (front == -1 || front > rear) { printf("Underflow!"); return -1; }\n    return queue[front++];\n}',
      'C++'   : 'int dequeue() {\n    if (q.empty())\n        throw underflow_error("Queue is Empty!");\n    int v = q.front(); q.pop(); return v;\n}',
    },
    'peek': {
      'Python': 'def peek(self):\n    if not self.queue:\n        raise IndexError("Queue is Empty!")\n    return self.queue[0]  # FRONT, no removal',
      'Java'  : 'public int peek() {\n    if (queue.isEmpty())\n        throw new RuntimeException("Queue is Empty!");\n    return queue.peek();  // FRONT, no removal\n}',
      'C'     : 'int peek() {\n    if (front == -1) { printf("Empty!"); return -1; }\n    return queue[front];  // FRONT, no removal\n}',
      'C++'   : 'int peek() {\n    if (q.empty())\n        throw runtime_error("Queue is Empty!");\n    return q.front();  // FRONT, no removal\n}',
    },
  };

  // ── Array input ────────────────────────────────────────────────────────────

  void _onArrayChanged(List<int> newArray) {
    setState(() {
      _preOpQueue  = [];                    // no pre-state for fresh build
      _lastOp      = 'enqueueAll';
      _lastOpVal   = 0;
      _inputArray  = List.from(newArray);
      _queue       = [];
      _playing     = false;
      _finished    = false;
      _steps       = QueueOperations.enqueueAll(newArray);
      _currentStep = 0;
    });
    // Store input so Restart can rebuild from scratch
    _preOpQueue = List.from(newArray);
    _play();
  }

  // ── Operation helpers ──────────────────────────────────────────────────────

  // FIX: Only clears animation state — does NOT touch _queue so canvas stays
  void _onOpChanged(String op) {
    setState(() {
      _selectedOp  = op;
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
      _preOpQueue = List.from(_queue);
      _lastOp     = _selectedOp;
      _lastOpVal  = value;
      _reset();
      switch (_selectedOp) {
        case 'enqueue':
          _steps = QueueOperations.enqueue(List.from(_queue), value);
          break;
        case 'dequeue':
          _steps = QueueOperations.dequeue(List.from(_queue));
          break;
        case 'peek':
          _steps = QueueOperations.peek(List.from(_queue));
          break;
      }
      _currentStep = 0;
    });
    _play();
  }

  Future<void> _play() async {
    // FIX: Guard — do nothing if no steps are ready
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
          _commitFinalQueue();
        }
      });
    }
  }

  void _commitFinalQueue() {
    if (_steps.isNotEmpty) {
      final last = _steps.last;
      final isError = (last.phase == 'underflow') ||
          (last.phase == 'overflow' && last.queue.isEmpty);
      if (!isError) {
        _queue = List.from(last.queue);
        if (last.phase == 'idle' || last.phase == 'overflow') {
          _inputArray = List.from(last.queue);
        }
      }
    }
  }

  void _pause() => setState(() => _playing = false);

  /// Restart: restore the pre-op queue and regenerate the same steps so
  /// Play works immediately after pressing Restart.
  void _hardReset() {
    if (_lastOp.isNotEmpty && _preOpQueue.isNotEmpty) {
      // Restore queue to the state it had before the operation
      setState(() {
        _queue       = List.from(_preOpQueue);
        _playing     = false;
        _finished    = false;
        _currentStep = 0;
      });
      // Regenerate the exact same steps
      switch (_lastOp) {
        case 'enqueue':
          setState(() {
            _steps = QueueOperations.enqueue(
                List.from(_preOpQueue), _lastOpVal);
            _currentStep = 0;
          });
          break;
        case 'dequeue':
          setState(() {
            _steps = QueueOperations.dequeue(List.from(_preOpQueue));
            _currentStep = 0;
          });
          break;
        case 'peek':
          setState(() {
            _steps = QueueOperations.peek(List.from(_preOpQueue));
            _currentStep = 0;
          });
          break;
        case 'enqueueAll':
          setState(() {
            _queue = [];
            _steps = QueueOperations.enqueueAll(_preOpQueue);
            _currentStep = 0;
          });
          break;
      }
    } else {
      // No previous op — just clear animation, queue stays visible
      setState(() {
        _steps       = [];
        _currentStep = 0;
        _playing     = false;
        _finished    = false;
      });
    }
  }

  void _stepForward() {
    if (_currentStep < _steps.length) {
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) {
          _finished = true;
          _commitFinalQueue();
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

  QueueStep? get _currentStepData =>
      (_steps.isNotEmpty &&
          _currentStep > 0 &&
          _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  /// FIX: Always return a valid step for the canvas.
  /// When no animation is running, synthesise an idle QueueStep from _queue
  /// so the canvas always shows the current queue state.
  QueueStep get _displayStep =>
      _currentStepData ??
      QueueStep(
        queue    : List.from(_queue),
        phase    : 'idle',
        statusMsg: _queue.isEmpty
            ? 'Queue is empty. Apply an array or select an operation to begin.'
            : _steps.isEmpty
                ? 'Queue ready (size ${_queue.length}/${QueueOperations.maxSize}). '
                  'Select an operation and press its button to start.'
                : 'Ready. Press the operation button above to begin.',
        operation: 'none',
      );

  // ── AI config ──────────────────────────────────────────────────────────────

  AiTutorTopicConfig _buildAiConfig() {
    final q   = _queue;
    final ctx = 'Queue: [${q.join(' ← ')}] '
        '(front=${q.isNotEmpty ? q.first : '–'}  rear=${q.isNotEmpty ? q.last : '–'}). '
        'Operation: ${_opLabels[_selectedOp]}. '
        '${_currentStepData != null ? _currentStepData!.statusMsg : 'Not started yet.'}';

    return AiTutorTopicConfig(
      dashboardName     : 'Queue Data Structure',
      topicKey          : _selectedOp,
      topicLabel        : '${_opLabels[_selectedOp]} Operation',
      language          : _aiLanguage,
      codeSnippet       : _codeSnippets[_selectedOp]?[_aiLanguage] ?? '',
      systemContext     : ctx,
      suggestedQuestions: _opQuestions[_selectedOp] ?? [],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // FIX: Use _displayStep (never null) instead of _currentStepData (nullable)
    final step = _displayStep;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Pinned array input bar
            QueueArrayInputSection(
              initialArray  : _inputArray,
              maxSize       : QueueOperations.maxSize,
              onArrayChanged: _onArrayChanged,
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Queue canvas — always receives a valid step
                    QueueCanvas(
                      step   : step,
                      maxSize: QueueOperations.maxSize,
                    ),

                    const SizedBox(height: 8),

                    // Operation dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: QueueOperationDropdown(
                        selected : _selectedOp,
                        onChanged: _onOpChanged,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: QueueControls(
                        operation     : _selectedOp,
                        playing       : _playing,
                        finished      : _finished,
                        stepIndex     : _currentStep,
                        totalSteps    : _steps.isEmpty ? 0 : _steps.length,
                        speedMs       : _speedMs,
                        // FIX: Pass null when no steps ready → Play is disabled
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
                      color: active ? const Color(0xFF22C55E) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize  : 13,
                    fontWeight: FontWeight.w700,
                    color     : active ? const Color(0xFF22C55E) : const Color(0xFF8B949E),
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

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return QueueCodeTabSection(
          operation        : _selectedOp,
          onLanguageChanged: (l) => setState(() => _aiLanguage = l),
        );
      case 1:
        return QueueComplexityCard(operation: _selectedOp);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}