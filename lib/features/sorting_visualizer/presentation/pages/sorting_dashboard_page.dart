import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sort_algorithms.dart';
import '../models/sort_step.dart';
import '../../../array_visualizer/presentation/widgets/array_input_section.dart';
import '../widgets/sort_bar_canvas.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/sort_controls.dart';
import '../widgets/code_tab_section.dart';
import '../widgets/complexity_card.dart';
import 'package:visualdsa/shared/widgets/ai_tutor_panel.dart';

class SortingDashboardPage extends StatefulWidget {
  const SortingDashboardPage({super.key});

  @override
  State<SortingDashboardPage> createState() => _SortingDashboardPageState();
}

class _SortingDashboardPageState extends State<SortingDashboardPage> {
  List<int> _array = [31, 73, 73, 67, 27, 69, 78, 87];
  String _selectedAlgo = 'bubble_sort';
  int _activeTab = 0;

  // Animation state
  List<SortStep> _steps = [];
  int _currentStep = 0;
  bool _playing = false;
  bool _finished = false;
  int _speedMs = 300;

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

  void _reset() {
    _steps = [];
    _currentStep = 0;
    _playing = false;
    _finished = false;
  }

  List<SortStep> _generateSteps() {
    switch (_selectedAlgo) {
      case 'bubble_sort':
        return SortAlgorithms.bubbleSort(_array);
      case 'selection_sort':
        return SortAlgorithms.selectionSort(_array);
      case 'insertion_sort':
        return SortAlgorithms.insertionSort(_array);
      case 'merge_sort':
        return SortAlgorithms.mergeSort(_array);
      case 'quick_sort':
        return SortAlgorithms.quickSort(_array);
      default:
        return SortAlgorithms.bubbleSort(_array);
    }
  }

  Future<void> _play() async {
    if (_steps.isEmpty) {
      _steps = _generateSteps();
      _currentStep = 0;
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
    if (_steps.isEmpty) { _steps = _generateSteps(); _currentStep = 0; }
    if (_currentStep < _steps.length) {
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) _finished = true;
      });
    }
  }

  void _stepBack() {
    if (_currentStep > 0) setState(() { _currentStep--; _finished = false; });
  }

  void _hardReset() {
    setState(() => _reset());
  }

  SortStep? get _currentStepData =>
      (_steps.isNotEmpty && _currentStep > 0 && _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  List<int> get _displayArray =>
      _currentStepData?.array ?? _array;

  @override
  Widget build(BuildContext context) {
    final step = _currentStepData;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // ── Array input bar ──────────────────────────────────────────────
            ArrayInputSection(
              initialValue: _array.join(','),
              onArrayChanged: _onArrayChanged,
            ),
            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visualization canvas
                    SortBarCanvas(
                      array: _displayArray,
                      algorithm: _selectedAlgo,
                      comparing: step?.comparing ?? {},
                      swapping: step?.swapping ?? {},
                      sorted: step?.sorted ?? {},
                      pivot: step?.pivot,
                      merging: step?.merging ?? {},
                      statusMsg: step?.statusMsg ?? '',
                      minIndex: step?.minIndex,
                      scanIndex: step?.scanIndex,
                      keyValue: step?.keyValue,
                      keyIndex: step?.keyIndex,
                      emptyIndex: step?.emptyIndex,
                      sortedFromRight: step?.sortedFromRight ?? 0,
                      sortedFromLeft: step?.sortedFromLeft ?? 0,
                    ),
                    const SizedBox(height: 8),

                    // Algorithm dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SortDropdown(
                        selected: _selectedAlgo,
                        onChanged: _onAlgoChanged,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Playback controls + speed
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SortControls(
                        playing: _playing,
                        finished: _finished,
                        stepIndex: _currentStep,
                        totalSteps: _steps.isEmpty ? 0 : _steps.length,
                        speedMs: _speedMs,
                        onPlay: _play,
                        onPause: _pause,
                        onStepForward: _stepForward,
                        onStepBack: _stepBack,
                        onReset: _hardReset,
                        onSpeedChanged: (v) => setState(() => _speedMs = v),
                      ),
                    ),
                    const SizedBox(height: 14),

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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? const Color(0xFF3B82F6) : const Color(0xFF8B949E),
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

  static const _algoLabels = {
    'bubble_sort': 'Bubble Sort',
    'selection_sort': 'Selection Sort',
    'insertion_sort': 'Insertion Sort',
    'merge_sort': 'Merge Sort',
    'quick_sort': 'Quick Sort',
  };

  static const _algoQuestions = {
    'bubble_sort': [
      'How does Bubble Sort work?',
      'What is its time complexity?',
      'Can you rewrite it in Java?',
      'How is it different from Selection Sort?',
      'Show me an optimised version',
    ],
    'selection_sort': [
      'How does Selection Sort work?',
      'Why is it always O(n²)?',
      'Is Selection Sort stable?',
      'When would you use Selection Sort?',
      'Show me Selection Sort in C++',
    ],
    'insertion_sort': [
      'How does Insertion Sort work?',
      'Why is it good for nearly sorted data?',
      'What is its best case complexity?',
      'Compare Insertion Sort vs Bubble Sort',
      'Rewrite Insertion Sort in Python',
    ],
    'merge_sort': [
      'How does Merge Sort work?',
      'Why does it need O(n) extra space?',
      'How does the merge step work?',
      'Why is Merge Sort stable?',
      'Show me Merge Sort without recursion',
    ],
    'quick_sort': [
      'How does Quick Sort work?',
      'How is the pivot chosen?',
      'Why is the worst case O(n²)?',
      'What is the partition step?',
      'How can I avoid the worst case?',
    ],
  };

  static const _codeSnippets = {
    'bubble_sort': {
      'Python': 'def bubble_sort(arr):\n    n=len(arr)\n    for i in range(n-1):\n        for j in range(n-i-1):\n            if arr[j]>arr[j+1]:\n                arr[j],arr[j+1]=arr[j+1],arr[j]\n    return arr',
      'Java': 'void bubbleSort(int[] arr){\n    int n=arr.length;\n    for(int i=0;i<n-1;i++)\n        for(int j=0;j<n-i-1;j++)\n            if(arr[j]>arr[j+1]){\n                int t=arr[j];arr[j]=arr[j+1];arr[j+1]=t;}}',
      'C': 'void bubbleSort(int a[],int n){\n    for(int i=0;i<n-1;i++)\n        for(int j=0;j<n-i-1;j++)\n            if(a[j]>a[j+1]){int t=a[j];a[j]=a[j+1];a[j+1]=t;}}',
      'C++': 'void bubbleSort(vector<int>& a){\n    int n=a.size();\n    for(int i=0;i<n-1;i++)\n        for(int j=0;j<n-i-1;j++)\n            if(a[j]>a[j+1]) swap(a[j],a[j+1]);}',
    },
    'selection_sort': {
      'Python': 'def selection_sort(arr):\n    n=len(arr)\n    for i in range(n-1):\n        m=i\n        for j in range(i+1,n):\n            if arr[j]<arr[m]: m=j\n        arr[i],arr[m]=arr[m],arr[i]\n    return arr',
      'Java': 'void selectionSort(int[] a){\n    int n=a.length;\n    for(int i=0;i<n-1;i++){\n        int m=i;\n        for(int j=i+1;j<n;j++) if(a[j]<a[m]) m=j;\n        int t=a[i];a[i]=a[m];a[m]=t;}}',
      'C': 'void selectionSort(int a[],int n){\n    for(int i=0;i<n-1;i++){\n        int m=i;\n        for(int j=i+1;j<n;j++) if(a[j]<a[m]) m=j;\n        int t=a[i];a[i]=a[m];a[m]=t;}}',
      'C++': 'void selectionSort(vector<int>& a){\n    int n=a.size();\n    for(int i=0;i<n-1;i++){\n        int m=i;\n        for(int j=i+1;j<n;j++) if(a[j]<a[m]) m=j;\n        swap(a[i],a[m]);}}',
    },
    'insertion_sort': {
      'Python': 'def insertion_sort(arr):\n    for i in range(1,len(arr)):\n        key=arr[i]; j=i-1\n        while j>=0 and arr[j]>key:\n            arr[j+1]=arr[j]; j-=1\n        arr[j+1]=key\n    return arr',
      'Java': 'void insertionSort(int[] a){\n    for(int i=1;i<a.length;i++){\n        int k=a[i],j=i-1;\n        while(j>=0&&a[j]>k){a[j+1]=a[j];j--;}\n        a[j+1]=k;}}',
      'C': 'void insertionSort(int a[],int n){\n    for(int i=1;i<n;i++){\n        int k=a[i],j=i-1;\n        while(j>=0&&a[j]>k){a[j+1]=a[j];j--;}\n        a[j+1]=k;}}',
      'C++': 'void insertionSort(vector<int>& a){\n    for(int i=1;i<(int)a.size();i++){\n        int k=a[i],j=i-1;\n        while(j>=0&&a[j]>k){a[j+1]=a[j];j--;}\n        a[j+1]=k;}}',
    },
    'merge_sort': {
      'Python': 'def merge_sort(arr):\n    if len(arr)<=1: return arr\n    m=len(arr)//2\n    L=merge_sort(arr[:m]); R=merge_sort(arr[m:])\n    i=j=k=0\n    while i<len(L) and j<len(R):\n        if L[i]<=R[j]: arr[k]=L[i];i+=1\n        else: arr[k]=R[j];j+=1\n        k+=1\n    arr[k:]=L[i:]or R[j:]\n    return arr',
      'Java': 'void mergeSort(int[] a,int l,int r){\n    if(l>=r)return;\n    int m=(l+r)/2;\n    mergeSort(a,l,m);mergeSort(a,m+1,r);\n    merge(a,l,m,r);}',
      'C': 'void mergeSort(int a[],int l,int r){\n    if(l<r){int m=(l+r)/2;\n        mergeSort(a,l,m);mergeSort(a,m+1,r);\n        merge(a,l,m,r);}}',
      'C++': 'void mergeSort(vector<int>& a,int l,int r){\n    if(l>=r)return;\n    int m=(l+r)/2;\n    mergeSort(a,l,m);mergeSort(a,m+1,r);\n    // merge step\n}',
    },
    'quick_sort': {
      'Python': 'def quick_sort(arr,lo,hi):\n    if lo<hi:\n        pi=partition(arr,lo,hi)\n        quick_sort(arr,lo,pi-1)\n        quick_sort(arr,pi+1,hi)',
      'Java': 'void quickSort(int[] a,int l,int h){\n    if(l<h){int pi=partition(a,l,h);\n        quickSort(a,l,pi-1);quickSort(a,pi+1,h);}}',
      'C': 'void quickSort(int a[],int l,int h){\n    if(l<h){int pi=partition(a,l,h);\n        quickSort(a,l,pi-1);quickSort(a,pi+1,h);}}',
      'C++': 'void quickSort(vector<int>& a,int l,int h){\n    if(l<h){int pi=partition(a,l,h);\n        quickSort(a,l,pi-1);quickSort(a,pi+1,h);}}',
    },
  };

  // current language is tracked in CodeTabSection internally,
  // so we expose a default here for the AI tutor context
  String _aiLanguage = 'Java';

  AiTutorTopicConfig _buildAiConfig() {
    return AiTutorTopicConfig(
      dashboardName: 'Sorting Algorithms',
      topicKey: _selectedAlgo,
      topicLabel: _algoLabels[_selectedAlgo] ?? _selectedAlgo,
      language: _aiLanguage,
      codeSnippet: _codeSnippets[_selectedAlgo]?[_aiLanguage] ?? '',
      systemContext: _steps.isNotEmpty
          ? 'The animation is at step $_currentStep of ${_steps.length}.'
          : 'The user has not started the animation yet.',
      suggestedQuestions:
          _algoQuestions[_selectedAlgo] ?? [],
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return CodeTabSection(algorithm: _selectedAlgo);
      case 1:
        return ComplexityCard(algorithm: _selectedAlgo);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}