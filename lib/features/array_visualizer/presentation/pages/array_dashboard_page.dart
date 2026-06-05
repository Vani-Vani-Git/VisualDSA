import 'package:flutter/material.dart';
import '../widgets/array_input_section.dart';
import '../widgets/array_visualizer_canvas.dart';
import '../widgets/operation_dropdown.dart';
import '../widgets/operation_input_panel.dart';
import '../widgets/code_tab_section.dart';
import '../widgets/complexity_card.dart';
import '../animations/insert_animation.dart';
import '../animations/update_animation.dart';
import '../animations/delete_animation.dart';
// Shared AI tutor — place ai_tutor_panel.dart in lib/shared/widgets/
import '../../../../../../../../shared/widgets/ai_tutor_panel.dart';

class ArrayDashboardPage extends StatefulWidget {
  const ArrayDashboardPage({super.key});

  @override
  State<ArrayDashboardPage> createState() => _ArrayDashboardPageState();
}

class _ArrayDashboardPageState extends State<ArrayDashboardPage> {
  List<int> _array = [57, 38, 23, 27, 70, 19, 69, 30];
  String _selectedOperation = 'sort';
  int _activeTab = 0;

  // Bubble sort states
  Set<int> _compareIndices = {};
  Set<int> _swapIndices = {};
  Set<int> _sortedIndices = {};

  // New animation states
  InsertAnimState _insertState = InsertAnimState.idle;
  UpdateAnimState _updateState = UpdateAnimState.idle;
  DeleteAnimState _deleteState = DeleteAnimState.idle;

  bool _animating = false;
  String _aiLanguage = 'Python';

  // ── Operation metadata ─────────────────────────────────────────────────────

  static const _opLabels = {
    'sort': 'Sort',
    'insert': 'Array Insert',
    'update': 'Array Update',
    'delete': 'Array Delete',
  };

  static const _opQuestions = {
    'sort': [
      'How does  Sort work on an array?',
      'What is the time complexity of Sort?',
      'How many swaps happen in the worst case?',
      'Can you show an optimised version?',
    ],
    'insert': [
      'How does array insertion work?',
      'What happens to existing elements when we insert?',
      'What is the time complexity of inserting at index i?',
      'How is inserting at the start different from the end?',
      'Show me insert using a linked list instead',
    ],
    'update': [
      'How does array update (index access) work?',
      'Why is array update O(1)?',
      'What is random access and why is it fast?',
      'How does this differ from updating in a linked list?',
      'What happens if I update an out-of-bounds index?',
    ],
    'delete': [
      'How does array deletion work?',
      'What is the time complexity of deleting at index i?',
      'Why do we need to shift elements after deletion?',
      'How is deletion different in a linked list?',
      'What is the best case for array deletion?',
    ],
  };

  static const _codeSnippets = {
    'sort': {
      'Python':
          'def sort(arr):\n    n = len(arr)\n    for i in range(n-1):\n        for j in range(n-i-1):\n            if arr[j] > arr[j+1]:\n                arr[j], arr[j+1] = arr[j+1], arr[j]\n    return arr',
      'Java':
          'void Sort(int[] arr) {\n    int n = arr.length;\n    for (int i=0; i<n-1; i++)\n        for (int j=0; j<n-i-1; j++)\n            if (arr[j] > arr[j+1]) {\n                int t=arr[j]; arr[j]=arr[j+1]; arr[j+1]=t;\n            }\n}',
      'C':
          'void Sort(int arr[], int n) {\n    for (int i=0; i<n-1; i++)\n        for (int j=0; j<n-i-1; j++)\n            if (arr[j] > arr[j+1]) {\n                int t=arr[j]; arr[j]=arr[j+1]; arr[j+1]=t;\n            }\n}',
      'C++':
          'void Sort(vector<int>& arr) {\n    int n = arr.size();\n    for (int i=0; i<n-1; i++)\n        for (int j=0; j<n-i-1; j++)\n            if (arr[j] > arr[j+1])\n                swap(arr[j], arr[j+1]);\n}',
    },
    'insert': {
      'Python': 'def insert(arr, val, i):\n    arr.insert(i, val)\n    return arr',
      'Java':
          'void insert(int[] arr, int val, int i) {\n    for (int k=arr.length-1; k>i; k--)\n        arr[k] = arr[k-1];\n    arr[i] = val;\n}',
      'C':
          'void insert(int arr[], int *n, int val, int i) {\n    for (int k=*n; k>i; k--)\n        arr[k] = arr[k-1];\n    arr[i] = val;\n    (*n)++;\n}',
      'C++':
          'void insert(vector<int>& arr, int val, int i) {\n    arr.insert(arr.begin()+i, val);\n}',
    },
    'update': {
      'Python': 'def update(arr, val, i):\n    arr[i] = val\n    return arr',
      'Java': 'void update(int[] arr, int val, int i) {\n    arr[i] = val;\n}',
      'C': 'void update(int arr[], int val, int i) {\n    arr[i] = val;\n}',
      'C++':
          'void update(vector<int>& arr, int val, int i) {\n    arr[i] = val;\n}',
    },
    'delete': {
      'Python': 'def delete(arr, i):\n    arr.pop(i)\n    return arr',
      'Java':
          'int[] delete(int[] arr, int i) {\n    for (int k=i; k<arr.length-1; k++)\n        arr[k] = arr[k+1];\n    return arr;\n}',
      'C':
          'void delete(int arr[], int *n, int i) {\n    for (int k=i; k<*n-1; k++)\n        arr[k] = arr[k+1];\n    (*n)--;\n}',
      'C++':
          'void deleteAt(vector<int>& arr, int i) {\n    arr.erase(arr.begin()+i);\n}',
    },
  };

  // ── Callbacks ──────────────────────────────────────────────────────────────

  void _onArrayChanged(List<int> newArray) {
    setState(() {
      _array = newArray;
      _resetHighlights();
    });
  }

  void _onOperationChanged(String op) {
    setState(() {
      _selectedOperation = op;
      _resetHighlights();
    });
  }

  void _resetHighlights() {
    _compareIndices = {};
    _swapIndices = {};
    _sortedIndices = {};
    _insertState = InsertAnimState.idle;
    _updateState = UpdateAnimState.idle;
    _deleteState = DeleteAnimState.idle;
  }

  // ── Bubble Sort ────────────────────────────────────────────────────────────

  Future<void> _runSort() async {
    if (_animating) return;
    setState(() => _animating = true);
    List<int> arr = List.from(_array);
    int n = arr.length;
    List<int> sorted = [];

    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        if (!mounted) return;
        setState(() => _compareIndices = {j, j + 1});
        await Future.delayed(const Duration(milliseconds: 400));

        if (arr[j] > arr[j + 1]) {
          setState(() => _swapIndices = {j, j + 1});
          await Future.delayed(const Duration(milliseconds: 300));
          int tmp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = tmp;
          setState(() {
            _array = List.from(arr);
            _swapIndices = {};
          });
          await Future.delayed(const Duration(milliseconds: 200));
        }
        setState(() => _compareIndices = {});
      }
      sorted.add(n - 1 - i);
      setState(() => _sortedIndices = Set.from(sorted));
    }

    setState(() {
      _sortedIndices = Set.from(List.generate(n, (i) => i));
      _compareIndices = {};
      _animating = false;
    });
  }

  // ── INSERT — step-by-step rightward shift ──────────────────────────────────

  Future<void> _runInsert(int value, int index) async {
    if (_animating || index < 0 || index > _array.length) return;
    setState(() => _animating = true);

    await runInsertAnimation(
      array: _array,
      value: value,
      index: index,
      onState: (s) {
        if (mounted) setState(() => _insertState = s);
      },
      onArrayChanged: (arr) {
        if (mounted) setState(() => _array = arr);
      },
      stepDelay: const Duration(milliseconds: 350),
    );

    if (mounted) setState(() => _animating = false);
  }

  // ── UPDATE — blank then green pop ─────────────────────────────────────────

  Future<void> _runUpdate(int value, int index) async {
    if (_animating || index < 0 || index >= _array.length) return;
    setState(() => _animating = true);

    await runUpdateAnimation(
      array: _array,
      value: value,
      index: index,
      onState: (s) {
        if (mounted) setState(() => _updateState = s);
      },
      onArrayChanged: (arr) {
        if (mounted) setState(() => _array = arr);
      },
      stepDelay: const Duration(milliseconds: 380),
    );

    if (mounted) setState(() => _animating = false);
  }

  // ── DELETE — gap then leftward shift ──────────────────────────────────────

  Future<void> _runDelete(int index) async {
    if (_animating || index < 0 || index >= _array.length) return;
    setState(() => _animating = true);

    await runDeleteAnimation(
      array: _array,
      index: index,
      onState: (s) {
        if (mounted) setState(() => _deleteState = s);
      },
      onArrayChanged: (arr) {
        if (mounted) setState(() => _array = arr);
      },
      stepDelay: const Duration(milliseconds: 350),
    );

    if (mounted) setState(() => _animating = false);
  }

  // ── AI config ──────────────────────────────────────────────────────────────

  AiTutorTopicConfig _buildAiConfig() {
    final arrayContext =
        'Current array: [${_array.join(', ')}] (${_array.length} elements). '
        '${_animating ? 'An animation is currently running.' : 'No animation running.'}';

    return AiTutorTopicConfig(
      dashboardName: 'Array Operations',
      topicKey: _selectedOperation,
      topicLabel: _opLabels[_selectedOperation] ?? _selectedOperation,
      language: _aiLanguage,
      codeSnippet: _codeSnippets[_selectedOperation]?[_aiLanguage] ?? '',
      systemContext: arrayContext,
      suggestedQuestions: _opQuestions[_selectedOperation] ?? [],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Array Input
            ArrayInputSection(
              initialValue: _array.join(','),
              onArrayChanged: _onArrayChanged,
            ),
            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visualization canvas
                    ArrayVisualizerCanvas(
                      array: _array,
                      compareIndices: _compareIndices,
                      swapIndices: _swapIndices,
                      sortedIndices: _sortedIndices,
                      insertState: _insertState,
                      updateState: _updateState,
                      deleteState: _deleteState,
                    ),

                    const SizedBox(height: 8),

                    // Operation dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: OperationDropdown(
                        selected: _selectedOperation,
                        onChanged: _onOperationChanged,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Operation input panel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: OperationInputPanel(
                        operation: _selectedOperation,
                        animating: _animating,
                        Sort: _runSort,
                        onInsert: _runInsert,
                        onUpdate: _runUpdate,
                        onDelete: _runDelete,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tab bar
                    _buildTabBar(),

                    // Tab content
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
        return CodeTabSection(
          operation: _selectedOperation,
          onLanguageChanged: (lang) => setState(() => _aiLanguage = lang),
        );
      case 1:
        return ComplexityCard(operation: _selectedOperation);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}