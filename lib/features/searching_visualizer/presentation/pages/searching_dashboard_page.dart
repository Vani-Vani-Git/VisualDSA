import 'package:flutter/material.dart';
import '../models/search_algorithms.dart';
import '../models/search_step.dart';
import '../widgets/array_input_section.dart';
import '../widgets/search_bar_canvas.dart';
import '../widgets/search_dropdown.dart';
import '../widgets/search_controls.dart';
import '../widgets/code_tab_section.dart';
import '../widgets/complexity_card.dart';
import 'package:visualdsa/shared/widgets/ai_tutor_panel.dart';

class SearchingDashboardPage extends StatefulWidget {
  const SearchingDashboardPage({super.key});

  @override
  State<SearchingDashboardPage> createState() =>
      _SearchingDashboardPageState();
}

class _SearchingDashboardPageState extends State<SearchingDashboardPage> {
  // ── State ──────────────────────────────────────────────────────────────────
  List<int> _array = [10, 50, 30, 70, 80, 60, 20, 90, 40];
  String _selectedAlgo = 'linear_search';
  int _target = 30;
  int _activeTab = 0;

  List<SearchStep> _steps = [];
  int _currentStep = 0;
  bool _playing = false;
  bool _finished = false;
  int _speedMs = 600;
  String _aiLanguage = 'Python';

  // ── Algorithm metadata ─────────────────────────────────────────────────────

  static const _algoLabels = {
    'linear_search': 'Linear Search',
    'binary_search': 'Binary Search',
    'jump_search': 'Jump Search',
  };

  static const _algoQuestions = {
    'linear_search': [
      'How does Linear Search work?',
      'What is its time complexity?',
      'When would you use Linear Search over Binary Search?',
      'Does Linear Search work on unsorted arrays?',
      'Show me an optimised version with early exit',
    ],
    'binary_search': [
      'How does Binary Search work?',
      'Why must the array be sorted?',
      'How does it achieve O(log n)?',
      'What happens when the target is not found?',
      'Show me a recursive version of Binary Search',
    ],
    'jump_search': [
      'How does Jump Search work?',
      'Why is the jump size √n?',
      'How does Jump Search compare to Binary Search?',
      'What is the linear back-scan phase?',
      'Does Jump Search require a sorted array?',
    ],
  };

  static const _codeSnippets = {
    'linear_search': {
      'Python':
          'def linear_search(arr, target):\n    for i in range(len(arr)):\n        if arr[i] == target:\n            return i\n    return -1',
      'Java':
          'int linearSearch(int[] arr, int target) {\n    for (int i=0; i<arr.length; i++)\n        if (arr[i] == target) return i;\n    return -1;\n}',
      'C':
          'int linearSearch(int arr[], int n, int target) {\n    for (int i=0; i<n; i++)\n        if (arr[i] == target) return i;\n    return -1;\n}',
      'C++':
          'int linearSearch(vector<int>& arr, int target) {\n    for (int i=0; i<arr.size(); i++)\n        if (arr[i] == target) return i;\n    return -1;\n}',
    },
    'binary_search': {
      'Python':
          'def binary_search(arr, target):\n    low, high = 0, len(arr)-1\n    while low <= high:\n        mid = (low+high)//2\n        if arr[mid]==target: return mid\n        elif arr[mid]<target: low=mid+1\n        else: high=mid-1\n    return -1',
      'Java':
          'int binarySearch(int[] arr, int target) {\n    int low=0, high=arr.length-1;\n    while (low<=high) {\n        int mid=(low+high)/2;\n        if(arr[mid]==target) return mid;\n        else if(arr[mid]<target) low=mid+1;\n        else high=mid-1;\n    }\n    return -1;\n}',
      'C':
          'int binarySearch(int arr[], int n, int target) {\n    int low=0, high=n-1;\n    while(low<=high) {\n        int mid=(low+high)/2;\n        if(arr[mid]==target) return mid;\n        else if(arr[mid]<target) low=mid+1;\n        else high=mid-1;\n    }\n    return -1;\n}',
      'C++':
          'int binarySearch(vector<int>& arr, int target) {\n    int low=0, high=arr.size()-1;\n    while(low<=high) {\n        int mid=(low+high)/2;\n        if(arr[mid]==target) return mid;\n        else if(arr[mid]<target) low=mid+1;\n        else high=mid-1;\n    }\n    return -1;\n}',
    },
    'jump_search': {
      'Python':
          'import math\ndef jump_search(arr, target):\n    n=len(arr); step=int(math.sqrt(n)); prev=0\n    while arr[min(step,n)-1]<target:\n        prev=step; step+=int(math.sqrt(n))\n        if prev>=n: return -1\n    while arr[prev]<target:\n        prev+=1\n        if prev==min(step,n): return -1\n    return prev if arr[prev]==target else -1',
      'Java':
          'int jumpSearch(int[] arr, int target) {\n    int n=arr.length, step=(int)Math.sqrt(n), prev=0;\n    while(arr[Math.min(step,n)-1]<target) {\n        prev=step; step+=(int)Math.sqrt(n);\n        if(prev>=n) return -1;\n    }\n    while(arr[prev]<target) {\n        prev++;\n        if(prev==Math.min(step,n)) return -1;\n    }\n    return arr[prev]==target ? prev : -1;\n}',
      'C':
          'int jumpSearch(int arr[], int n, int target) {\n    int step=(int)sqrt(n), prev=0;\n    while(arr[(int)fmin(step,n)-1]<target) {\n        prev=step; step+=(int)sqrt(n);\n        if(prev>=n) return -1;\n    }\n    while(arr[prev]<target) {\n        if(++prev==(int)fmin(step,n)) return -1;\n    }\n    return arr[prev]==target ? prev : -1;\n}',
      'C++':
          'int jumpSearch(vector<int>& arr, int target) {\n    int n=arr.size(), step=(int)sqrt(n), prev=0;\n    while(arr[min(step,n)-1]<target) {\n        prev=step; step+=(int)sqrt(n);\n        if(prev>=n) return -1;\n    }\n    while(arr[prev]<target)\n        if(++prev==min(step,n)) return -1;\n    return arr[prev]==target ? prev : -1;\n}',
    },
  };

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _onArrayChanged(List<int> arr) {
    setState(() {
      _array = arr;
      _reset();
    });
  }

  void _onAlgoChanged(String algo) {
    setState(() {
      _selectedAlgo = algo;
      _reset();
    });
  }

  void _onTargetChanged(int t) {
    setState(() {
      _target = t;
      _reset();
      // Auto-start play when target is set
    });
    _play();
  }

  void _reset() {
    _steps = [];
    _currentStep = 0;
    _playing = false;
    _finished = false;
  }

  List<SearchStep> _generateSteps() {
    switch (_selectedAlgo) {
      case 'linear_search':
        return SearchAlgorithms.linearSearch(_array, _target);
      case 'binary_search':
        return SearchAlgorithms.binarySearch(_array, _target);
      case 'jump_search':
        return SearchAlgorithms.jumpSearch(_array, _target);
      default:
        return SearchAlgorithms.linearSearch(_array, _target);
    }
  }

  Future<void> _play() async {
    if (_steps.isEmpty) {
      setState(() {
        _steps = _generateSteps();
        _currentStep = 0;
      });
    }
    setState(() => _playing = true);

    while (_currentStep < _steps.length && _playing) {
      await Future.delayed(Duration(milliseconds: _speedMs));
      if (!mounted || !_playing) break;
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) {
          _playing = false;
          _finished = true;
        }
      });
    }
  }

  void _pause() => setState(() => _playing = false);

  void _stepForward() {
    if (_steps.isEmpty) {
      setState(() {
        _steps = _generateSteps();
        _currentStep = 0;
      });
    }
    if (_currentStep < _steps.length) {
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) _finished = true;
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

  void _hardReset() => setState(() => _reset());

  SearchStep? get _currentStepData =>
      (_steps.isNotEmpty && _currentStep > 0 && _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  // ── AI config ──────────────────────────────────────────────────────────────

  AiTutorTopicConfig _buildAiConfig() {
    final ctx =
        'Array: [${_array.join(', ')}]. Target: $_target. '
        '${_currentStepData != null ? _currentStepData!.statusMsg : 'Not started yet.'}';

    return AiTutorTopicConfig(
      dashboardName: 'Searching Algorithms',
      topicKey: _selectedAlgo,
      topicLabel: _algoLabels[_selectedAlgo] ?? _selectedAlgo,
      language: _aiLanguage,
      codeSnippet: _codeSnippets[_selectedAlgo]?[_aiLanguage] ?? '',
      systemContext: ctx,
      suggestedQuestions: _algoQuestions[_selectedAlgo] ?? [],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final step = _currentStepData;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Array input bar
            ArrayInputSection(
              initialValue: _array.join(','),
              onArrayChanged: _onArrayChanged,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visualization
                    SearchBarCanvas(
                      array: _array,
                      algorithm: _selectedAlgo,
                      target: _target,
                      step: step,
                    ),

                    const SizedBox(height: 8),

                    // Algorithm dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SearchDropdown(
                        selected: _selectedAlgo,
                        onChanged: _onAlgoChanged,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Search controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SearchControls(
                        playing: _playing,
                        finished: _finished,
                        stepIndex: _currentStep,
                        totalSteps: _steps.isEmpty ? 0 : _steps.length,
                        speedMs: _speedMs,
                        target: _target,
                        algorithm: _selectedAlgo,
                        onPlay: _play,
                        onPause: _pause,
                        onStepForward: _stepForward,
                        onStepBack: _stepBack,
                        onReset: _hardReset,
                        onSpeedChanged: (v) =>
                            setState(() => _speedMs = v),
                        onTargetChanged: _onTargetChanged,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tabs
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
          algorithm: _selectedAlgo,
          onLanguageChanged: (l) => setState(() => _aiLanguage = l),
        );
      case 1:
        return ComplexityCard(algorithm: _selectedAlgo);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}