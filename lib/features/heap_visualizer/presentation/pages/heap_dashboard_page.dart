import 'package:flutter/material.dart';
import '../models/heap_step.dart';
import '../models/heap_operations.dart';
import '../widgets/heap_array_input_section.dart';
import '../widgets/heap_canvas.dart';
import '../widgets/heap_type_dropdown.dart';
import '../widgets/heap_operation_dropdown.dart';
import '../widgets/heap_controls.dart';
import '../widgets/heap_code_tab_section.dart';
import '../widgets/heap_complexity_card.dart';
import 'package:visualdsa/shared/widgets/ai_tutor_panel.dart';

class HeapDashboardPage extends StatefulWidget {
  const HeapDashboardPage({super.key});

  @override
  State<HeapDashboardPage> createState() => _HeapDashboardPageState();
}

class _HeapDashboardPageState extends State<HeapDashboardPage> {
  // ── State ──────────────────────────────────────────────────────────────────
  List<int> _inputArray = [35, 33, 42, 10, 14, 19, 27];
  List<int> _heap       = [];         // live heap array
  String    _heapType   = 'max';      // 'max' | 'min'
  String    _selectedOp = 'insert';
  int       _activeTab  = 0;
  String    _aiLanguage = 'Python';

  List<HeapStep> _steps       = [];
  int            _currentStep = 0;
  bool           _playing     = false;
  bool           _finished    = false;
  int            _speedMs     = 700;

  // ── Replay state — remembers the last executed operation so Restart works ──
  // _preOpHeap: heap snapshot BEFORE the last operation ran (for replay)
  // _lastOp:    which operation was run ('insert'|'delete'|'update'|'sort')
  // _lastOpVal, _lastOpIdx, _lastOpNewVal: inputs for that operation
  List<int> _preOpHeap    = [];
  String    _lastOp       = '';
  int       _lastOpVal    = 0;
  int       _lastOpIdx    = 0;
  int       _lastOpNewVal = 0;

  // ── Metadata ───────────────────────────────────────────────────────────────
  static const _opLabels = {
    'insert': 'Insert',
    'delete': 'Delete',
    'update': 'Update',
    'sort'  : 'Heap Sort',
  };

  static const _opQuestions = {
    'insert': [
      'How does insertion work in a Max-Heap?',
      'What is heapify-up and when is it used?',
      'What is the time complexity of heap insertion?',
      'How does Min-Heap insertion differ from Max-Heap?',
      'Show me heap insertion with a real example',
    ],
    'delete': [
      'How does deletion work in a Max-Heap?',
      'Why do we replace the deleted node with the last element?',
      'What is heapify-down and when is it used?',
      'What happens when we delete the root?',
      'What is the time complexity of heap deletion?',
    ],
    'update': [
      'How does update work in a heap?',
      'When do we heapify-up vs heapify-down after update?',
      'What is the time complexity of heap update?',
      'Show me an update example in Max-Heap',
      'How is heap update used in Dijkstra\'s algorithm?',
    ],
    'sort': [
      'How does Heap Sort work step by step?',
      'Why does Heap Sort use a Max-Heap for ascending sort?',
      'What is the time complexity of Heap Sort?',
      'Is Heap Sort stable? Why or why not?',
      'How does Heap Sort compare to Merge Sort?',
    ],
  };

  static const Map<String, Map<String, Map<String, String>>> _codeSnippets = {
    'insert': {
      'max': {
        'Python': 'def insert(self, val):\n    self.heap.append(val)\n    self._heapify_up(len(self.heap) - 1)',
        'Java'  : 'public void insert(int val) {\n    heap.add(val);\n    heapifyUp(heap.size() - 1);\n}',
        'C'     : 'void insert(int val) {\n    heap[size++] = val;\n    heapifyUp(size - 1);\n}',
        'C++'   : 'void insert(int val) {\n    heap.push_back(val);\n    heapifyUp(heap.size() - 1);\n}',
      },
      'min': {
        'Python': 'def insert(self, val):\n    self.heap.append(val)\n    self._heapify_up(len(self.heap) - 1)',
        'Java'  : 'public void insert(int val) {\n    heap.add(val);\n    heapifyUp(heap.size() - 1);\n}',
        'C'     : 'void insert(int val) {\n    heap[size++] = val;\n    heapifyUp(size - 1);\n}',
        'C++'   : 'void insert(int val) {\n    heap.push_back(val);\n    heapifyUp(heap.size() - 1);\n}',
      },
    },
    'delete': {
      'max': {
        'Python': 'def delete(self, i):\n    self.heap[i] = self.heap[-1]\n    self.heap.pop()\n    self._heapify_up(i)\n    self._heapify_down(i)',
        'Java'  : 'public void delete(int i) {\n    heap.set(i, heap.get(heap.size()-1));\n    heap.remove(heap.size()-1);\n    heapifyUp(i); heapifyDown(i);\n}',
        'C'     : 'void deleteNode(int i) {\n    heap[i] = heap[--size];\n    heapifyUp(i); heapifyDown(i, size);\n}',
        'C++'   : 'void deleteNode(int i) {\n    heap[i] = heap.back(); heap.pop_back();\n    heapifyUp(i); heapifyDown(i, heap.size());\n}',
      },
      'min': {
        'Python': 'def delete(self, i):\n    self.heap[i] = self.heap[-1]\n    self.heap.pop()\n    self._heapify_up(i)\n    self._heapify_down(i)',
        'Java'  : 'public void delete(int i) {\n    heap.set(i, heap.get(heap.size()-1));\n    heap.remove(heap.size()-1);\n    heapifyUp(i); heapifyDown(i);\n}',
        'C'     : 'void deleteNode(int i) {\n    heap[i] = heap[--size];\n    heapifyUp(i); heapifyDown(i, size);\n}',
        'C++'   : 'void deleteNode(int i) {\n    heap[i] = heap.back(); heap.pop_back();\n    heapifyUp(i); heapifyDown(i, heap.size());\n}',
      },
    },
    'update': {
      'max': {
        'Python': 'def update(self, i, val):\n    self.heap[i] = val\n    self._heapify_up(i)\n    self._heapify_down(i)',
        'Java'  : 'public void update(int i, int val) {\n    heap.set(i, val);\n    heapifyUp(i); heapifyDown(i);\n}',
        'C'     : 'void update(int i, int val) {\n    heap[i] = val;\n    heapifyUp(i); heapifyDown(i, size);\n}',
        'C++'   : 'void update(int i, int val) {\n    heap[i] = val;\n    heapifyUp(i); heapifyDown(i, heap.size());\n}',
      },
      'min': {
        'Python': 'def update(self, i, val):\n    self.heap[i] = val\n    self._heapify_up(i)\n    self._heapify_down(i)',
        'Java'  : 'public void update(int i, int val) {\n    heap.set(i, val);\n    heapifyUp(i); heapifyDown(i);\n}',
        'C'     : 'void update(int i, int val) {\n    heap[i] = val;\n    heapifyUp(i); heapifyDown(i, size);\n}',
        'C++'   : 'void update(int i, int val) {\n    heap[i] = val;\n    heapifyUp(i); heapifyDown(i, heap.size());\n}',
      },
    },
    'sort': {
      'max': {
        'Python': 'def heap_sort(arr):\n    n = len(arr)\n    for i in range(n//2-1, -1, -1):\n        _heapify(arr, n, i)\n    for i in range(n-1, 0, -1):\n        arr[0], arr[i] = arr[i], arr[0]\n        _heapify(arr, i, 0)',
        'Java'  : 'void heapSort(int[] a) {\n    int n = a.length;\n    for(int i=n/2-1;i>=0;i--) heapify(a,n,i);\n    for(int i=n-1;i>0;i--){swap(a,0,i);heapify(a,i,0);}\n}',
        'C'     : 'void heapSort(int a[], int n) {\n    for(int i=n/2-1;i>=0;i--) heapify(a,n,i);\n    for(int i=n-1;i>0;i--){swap(&a[0],&a[i]);heapify(a,i,0);}\n}',
        'C++'   : 'void heapSort(vector<int>& a) {\n    int n=a.size();\n    for(int i=n/2-1;i>=0;i--) heapify(a,n,i);\n    for(int i=n-1;i>0;i--){swap(a[0],a[i]);heapify(a,i,0);}\n}',
      },
      'min': {
        'Python': 'def heap_sort_min(arr):\n    n = len(arr)\n    for i in range(n//2-1, -1, -1):\n        _heapify_min(arr, n, i)\n    for i in range(n-1, 0, -1):\n        arr[0], arr[i] = arr[i], arr[0]\n        _heapify_min(arr, i, 0)',
        'Java'  : 'void heapSortMin(int[] a) {\n    int n=a.length;\n    for(int i=n/2-1;i>=0;i--) heapifyMin(a,n,i);\n    for(int i=n-1;i>0;i--){swap(a,0,i);heapifyMin(a,i,0);}\n}',
        'C'     : 'void heapSortMin(int a[], int n) {\n    for(int i=n/2-1;i>=0;i--) heapifyMin(a,n,i);\n    for(int i=n-1;i>0;i--){swap(&a[0],&a[i]);heapifyMin(a,i,0);}\n}',
        'C++'   : 'void heapSortMin(vector<int>& a) {\n    int n=a.size();\n    for(int i=n/2-1;i>=0;i--) heapifyMin(a,n,i);\n    for(int i=n-1;i>0;i--){swap(a[0],a[i]);heapifyMin(a,i,0);}\n}',
      },
    },
  };

  // ── Array input ────────────────────────────────────────────────────────────
  void _onArrayChanged(List<int> arr) {
    setState(() {
      _preOpHeap   = [];       // no pre-state for initial build
      _lastOp      = 'build';
      _inputArray  = List.from(arr);
      _heap        = [];
      _playing     = false;
      _finished    = false;
      _steps       = HeapOperations.buildHeap(arr, _heapType);
      _currentStep = 0;
    });
    // Store the input so Restart can rebuild from scratch
    _preOpHeap = List.from(arr);
    _play();
  }

  // ── Heap type change ───────────────────────────────────────────────────────
  void _onHeapTypeChanged(String type) {
    setState(() {
      _heapType    = type;
      _lastOp      = 'build';
      _heap        = [];
      _playing     = false;
      _finished    = false;
      _steps       = HeapOperations.buildHeap(_inputArray, type);
      _currentStep = 0;
    });
    _preOpHeap = List.from(_inputArray);
    _play();
  }

  // ── Operation helpers ──────────────────────────────────────────────────────
  void _onOpChanged(String op) => setState(() {
        _selectedOp = op;
        // Clear animation steps but keep _heap so canvas stays visible.
        _steps       = [];
        _currentStep = 0;
        _playing     = false;
        _finished    = false;
      });

  void _reset() {
    _steps       = [];
    _currentStep = 0;
    _playing     = false;
    _finished    = false;
  }

  void _onInsert(int value) {
    setState(() {
      _preOpHeap = List.from(_heap); // snapshot before op for Restart
      _lastOp    = 'insert';
      _lastOpVal = value;
      _reset();
      _steps       = HeapOperations.insert(List.from(_heap), value, _heapType);
      _currentStep = 0;
    });
    _play();
  }

  void _onDelete(int index) {
    setState(() {
      _preOpHeap = List.from(_heap);
      _lastOp    = 'delete';
      _lastOpIdx = index;
      _reset();
      _steps       = HeapOperations.delete(List.from(_heap), index, _heapType);
      _currentStep = 0;
    });
    _play();
  }

  void _onUpdate(int index, int newVal) {
    setState(() {
      _preOpHeap    = List.from(_heap);
      _lastOp       = 'update';
      _lastOpIdx    = index;
      _lastOpNewVal = newVal;
      _reset();
      _steps = HeapOperations.update(List.from(_heap), index, newVal, _heapType);
      _currentStep = 0;
    });
    _play();
  }

  void _onSort() {
    setState(() {
      _preOpHeap = List.from(_heap);
      _lastOp    = 'sort';
      _reset();
      _steps       = HeapOperations.sort(List.from(_heap), _heapType);
      _currentStep = 0;
    });
    _play();
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
          _commitFinalHeap();
        }
      });
    }
  }

  void _commitFinalHeap() {
    if (_steps.isNotEmpty) {
      final last = _steps.last;
      if (last.phase != 'overflow' && last.phase != 'underflow') {
        _heap = List.from(last.heap);
        // After sort, keep the sorted array representation but heap is exhausted
        if (last.phase == 'idle') {
          _inputArray = List.from(last.heap);
        }
      }
    }
  }

  void _pause() => setState(() => _playing = false);

  /// Restart: if a previous operation exists, restore the pre-op heap and
  /// re-run the exact same operation so Play immediately works again.
  /// If no previous op exists, just reset animation state (keep heap visible).
  void _hardReset() {
    if (_lastOp.isNotEmpty && _preOpHeap.isNotEmpty) {
      // Restore heap to pre-op state so the replay is identical
      setState(() {
        _heap        = List.from(_preOpHeap);
        _playing     = false;
        _finished    = false;
        _currentStep = 0;
      });
      // Regenerate the exact same steps
      switch (_lastOp) {
        case 'insert':
          setState(() {
            _steps = HeapOperations.insert(
                List.from(_preOpHeap), _lastOpVal, _heapType);
            _currentStep = 0;
          });
          break;
        case 'delete':
          setState(() {
            _steps = HeapOperations.delete(
                List.from(_preOpHeap), _lastOpIdx, _heapType);
            _currentStep = 0;
          });
          break;
        case 'update':
          setState(() {
            _steps = HeapOperations.update(
                List.from(_preOpHeap), _lastOpIdx, _lastOpNewVal, _heapType);
            _currentStep = 0;
          });
          break;
        case 'sort':
          setState(() {
            _steps = HeapOperations.sort(List.from(_preOpHeap), _heapType);
            _currentStep = 0;
          });
          break;
        case 'build':
          setState(() {
            _steps = HeapOperations.buildHeap(List.from(_preOpHeap), _heapType);
            _currentStep = 0;
          });
          break;
      }
    } else {
      // No previous op — just clear animation, heap stays visible
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
          _commitFinalHeap();
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

  HeapStep? get _currentStepData =>
      (_steps.isNotEmpty &&
          _currentStep > 0 &&
          _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  /// When no animation is running, synthesise an idle HeapStep from the
  /// live _heap so the canvas always shows the current tree.
  HeapStep get _displayStep =>
      _currentStepData ??
      HeapStep(
        heap:       List.from(_heap),
        heapType:   _heapType,
        phase:      'idle',
        statusMsg:  _heap.isEmpty
            ? 'Apply an array or select an operation to begin.'
            : _steps.isEmpty
                ? '${_heapType == 'max' ? 'Max' : 'Min'}-Heap ready '
                  '(root = ${_heap[0]}). Select an operation and press its button to start.'
                : 'Select an operation and press its button to start.',
        operation:  'none',
      );

  // ── AI config ──────────────────────────────────────────────────────────────
  AiTutorTopicConfig _buildAiConfig() {
    final typeLabel = _heapType == 'max' ? 'Max-Heap' : 'Min-Heap';
    final ctx = '$typeLabel: [${_heap.join(', ')}] '
        '(root=${_heap.isNotEmpty ? _heap[0] : '–'}). '
        'Operation: ${_opLabels[_selectedOp]}. '
        '${_currentStepData != null ? _currentStepData!.statusMsg : 'Not started yet.'}';

    return AiTutorTopicConfig(
      dashboardName     : 'Heap Data Structure',
      topicKey          : '${_heapType}_$_selectedOp',
      topicLabel        : '$typeLabel — ${_opLabels[_selectedOp]}',
      language          : _aiLanguage,
      codeSnippet       : _codeSnippets[_selectedOp]?[_heapType]?[_aiLanguage] ?? '',
      systemContext     : ctx,
      suggestedQuestions: _opQuestions[_selectedOp] ?? [],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final step      = _displayStep;
    final typeColor = _heapType == 'max'
        ? const Color(0xFFEF4444)
        : const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // ── Pinned array input bar ──────────────────────────────────
            HeapArrayInputSection(
              initialArray  : _inputArray,
              maxSize       : HeapOperations.maxSize,
              onArrayChanged: _onArrayChanged,
            ),

            // ── Heap type selector (pinned below input bar) ─────────────
            Container(
              color: const Color(0xFF0F1117),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: HeapTypeDropdown(
                selected : _heapType,
                onChanged: _onHeapTypeChanged,
              ),
            ),

            // ── Scrollable body ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heap info bar
                    _buildHeapInfoBar(typeColor),

                    // Canvas
                    HeapCanvas(step: step),

                    const SizedBox(height: 8),

                    // Operation dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: HeapOperationDropdown(
                        selected : _selectedOp,
                        onChanged: _onOpChanged,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: HeapControls(
                        operation     : _selectedOp,
                        heapType      : _heapType,
                        playing       : _playing,
                        finished      : _finished,
                        stepIndex     : _currentStep,
                        totalSteps    : _steps.isEmpty ? 0 : _steps.length,
                        speedMs       : _speedMs,
                        heapSize      : _heap.length,
                        onPlay        : _steps.isNotEmpty ? _play : null,
                        onPause       : _pause,
                        onStepForward : _stepForward,
                        onStepBack    : _stepBack,
                        onReset       : _hardReset,
                        onSpeedChanged: (v) => setState(() => _speedMs = v),
                        onInsert      : _onInsert,
                        onDelete      : _onDelete,
                        onUpdate      : _onUpdate,
                        onSort        : _onSort,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tab bar
                    _buildTabBar(typeColor),

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

  // ── Heap info bar ──────────────────────────────────────────────────────────
  Widget _buildHeapInfoBar(Color typeColor) {
    final liveHeap = _currentStepData?.heap ?? _heap;
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            _heapType == 'max'
                ? Icons.keyboard_double_arrow_up
                : Icons.keyboard_double_arrow_down,
            color: typeColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            _heapType == 'max' ? 'Max-Heap' : 'Min-Heap',
            style: TextStyle(
              color: typeColor,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                liveHeap.isEmpty
                    ? '[ empty ]'
                    : '[${liveHeap.join(', ')}]'
                        '  root=${liveHeap[0]}',
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'n=${liveHeap.length}/${HeapOperations.maxSize}',
              style: TextStyle(
                color: typeColor,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar(Color activeColor) {
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
                      color: active ? activeColor : Colors.transparent,
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
                    color     : active
                        ? activeColor
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
        return HeapCodeTabSection(
          operation        : _selectedOp,
          heapType         : _heapType,
          onLanguageChanged: (l) => setState(() => _aiLanguage = l),
        );
      case 1:
        return HeapComplexityCard(
          operation: _selectedOp,
          heapType : _heapType,
        );
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}