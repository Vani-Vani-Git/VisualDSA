import 'package:flutter/material.dart';
import '../models/trav_graph_model.dart';
import '../widgets/trav_unified_canvas.dart';
import '../widgets/trav_anim_controls.dart';
import '../widgets/trav_code_tab.dart';
import '../widgets/trav_complexity_card.dart';
import '../widgets/trav_property_checkboxes.dart';
// Adjust this import path to match your project structure
import '../../../../shared/widgets/ai_tutor_panel.dart';

class GraphTraversalDashboard extends StatefulWidget {
  const GraphTraversalDashboard({super.key});

  @override
  State<GraphTraversalDashboard> createState() =>
      _GraphTraversalDashboardState();
}

class _GraphTraversalDashboardState extends State<GraphTraversalDashboard> {
  TravGraphProperties _props =
      TravGraphProperties(directed: false, connected: false);
  TravGraphModel? _graph;
  final GlobalKey<TravUnifiedCanvasState> _canvasKey =
      GlobalKey<TravUnifiedCanvasState>();

  String? _activeAlgo;
  int _srcNode = 0;

  List<TravAnimStep> _steps = [];
  int _currentStep = 0;
  bool _playing = false;
  bool _finished = false;
  int _speedMs = 600;

  TravGraphModel? _lastGraph;
  String? _lastAlgo;
  int? _lastSrc;

  int _activeTab = 0;
  String _aiLang = 'Python';

  void _onPropsChanged(TravGraphProperties p) {
    setState(() { _props = p; _resetAnim(); _activeAlgo = null; });
  }

  void _onGraphReady(TravGraphModel g) {
    setState(() {
      _graph = TravGraphModel(vertices: g.vertices, edges: g.edges, properties: _props);
      _resetAnim(); _activeAlgo = null;
      final ids = g.vertices.map((v) => v.id).toList()..sort();
      if (ids.isNotEmpty) _srcNode = ids.first;
    });
  }

  void _runAlgo(String algo) {
    TravGraphModel g = _graph ?? TravGraphModel.random(_props, const Size(300, 280));
    final ids = g.vertices.map((v) => v.id).toList()..sort();
    if (!ids.contains(_srcNode)) _srcNode = ids.isNotEmpty ? ids.first : 0;

    final steps = algo == 'bfs'
        ? BfsGenerator.generate(g, _srcNode)
        : DfsGenerator.generate(g, _srcNode);

    setState(() {
      _graph = g; _activeAlgo = algo;
      _lastAlgo = algo; _lastGraph = g; _lastSrc = _srcNode;
      _steps = steps; _currentStep = 0; _playing = false; _finished = false;
    });
  }

  void _resetAnim() {
    _steps = []; _currentStep = 0; _playing = false; _finished = false;
  }

  Future<void> _play() async {
    if (_steps.isEmpty) return;
    setState(() => _playing = true);
    while (_currentStep < _steps.length && _playing) {
      await Future.delayed(Duration(milliseconds: _speedMs));
      if (!mounted || !_playing) break;
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) { _playing = false; _finished = true; }
      });
    }
  }

  void _pause() => setState(() => _playing = false);

  void _stepFwd() {
    if (_currentStep < _steps.length) {
      setState(() { _currentStep++; if (_currentStep >= _steps.length) _finished = true; });
    }
  }

  void _stepBack() {
    if (_currentStep > 0) setState(() { _currentStep--; _finished = false; });
  }

  void _hardReset() {
    if (_lastAlgo != null && _lastGraph != null) {
      final steps = _lastAlgo == 'bfs'
          ? BfsGenerator.generate(_lastGraph!, _lastSrc!)
          : DfsGenerator.generate(_lastGraph!, _lastSrc!);
      setState(() {
        _graph = _lastGraph; _activeAlgo = _lastAlgo; _srcNode = _lastSrc!;
        _steps = steps; _currentStep = 0; _playing = false; _finished = false;
      });
    } else {
      setState(() { _currentStep = 0; _playing = false; _finished = false; });
    }
  }

  TravAnimStep? get _curStep =>
      (_steps.isNotEmpty && _currentStep > 0 && _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  Color get _accent => _activeAlgo == 'dfs' ? const Color(0xFF9333EA) : const Color(0xFF3B82F6);
  Color get _accentLight => _activeAlgo == 'dfs' ? const Color(0xFFC084FC) : const Color(0xFF93C5FD);

  Widget _srcPicker() {
    final ids = _graph?.vertices.map((v) => v.id).toList() ?? [];
    if (ids.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF59E0B).withOpacity(0.15),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.6)),
          ),
          child: const Center(child: Text('S',
              style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11,
                  fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
        ),
        const SizedBox(width: 10),
        const Text('Source Node',
            style: TextStyle(color: Color(0xFF8B949E), fontSize: 11, fontFamily: 'monospace')),
        const Spacer(),
        DropdownButton<int>(
          value: ids.contains(_srcNode) ? _srcNode : ids.first,
          isDense: true, underline: const SizedBox(),
          dropdownColor: const Color(0xFF1C2128),
          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontFamily: 'monospace'),
          items: ids.map((id) => DropdownMenuItem(
            value: id,
            child: Text('Node $id',
                style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontFamily: 'monospace')),
          )).toList(),
          onChanged: (v) {
            if (v != null) setState(() { _srcNode = v; _resetAnim(); _activeAlgo = null; });
          },
        ),
      ]),
    );
  }

  Widget _algoBtn({required String algo, required String label,
      required IconData icon, required Color accent}) {
    final isActive = _activeAlgo == algo;
    return Expanded(
      child: GestureDetector(
        onTap: () => _runAlgo(algo),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? accent.withOpacity(0.15) : const Color(0xFF161B22),
            border: Border.all(color: isActive ? accent : const Color(0xFF30363D),
                width: isActive ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: isActive ? accent : const Color(0xFF8B949E), size: 16),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center,
                style: TextStyle(color: isActive ? accent : const Color(0xFFE2E8F0),
                    fontSize: 11, fontWeight: FontWeight.w700,
                    fontFamily: 'monospace', height: 1.3)),
          ]),
        ),
      ),
    );
  }

  Widget _visitPanel(TravAnimStep step) {
    final isBfs = _activeAlgo == 'bfs';
    final qLabel = isBfs ? 'Queue' : 'Stack';
    final qItems = isBfs ? step.queue : step.queue.reversed.toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (step.visitOrder.isNotEmpty) ...[
        Row(children: [
          const Text('Visit Order',
              style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12,
                  fontWeight: FontWeight.w700, fontFamily: 'monospace')),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('${step.visitOrder.length} visited',
                style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 9,
                    fontFamily: 'monospace', fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: List.generate(step.visitOrder.length, (i) {
            final nodeId = step.visitOrder[i];
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF22C55E).withOpacity(0.20),
                  border: Border.all(color: const Color(0xFF22C55E)),
                ),
                child: Stack(children: [
                  Center(child: Text('$nodeId',
                      style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12,
                          fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
                  Positioned(top: 0, right: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                      child: Center(child: Text('${i+1}',
                          style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w700))),
                    ),
                  ),
                ]),
              ),
              if (i < step.visitOrder.length - 1)
                const Padding(padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(Icons.arrow_forward, color: Color(0xFF374151), size: 12)),
            ]);
          })),
        ),
        const SizedBox(height: 10),
      ],

      if (qItems.isNotEmpty) ...[
        Text('$qLabel State',
            style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12,
                fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            border: Border.all(color: _accent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: List.generate(qItems.length, (i) {
              final nodeId = qItems[i];
              final isFirst = i == 0;
              return Row(mainAxisSize: MainAxisSize.min, children: [
                if (isFirst)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(isBfs ? 'front' : 'top',
                        style: TextStyle(color: _accentLight, fontSize: 8, fontFamily: 'monospace')),
                  ),
                Container(
                  width: 32, height: 32,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withOpacity(0.18),
                    border: Border.all(color: _accent),
                  ),
                  child: Center(child: Text('$nodeId',
                      style: TextStyle(color: _accentLight, fontSize: 11,
                          fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
                ),
              ]);
            })),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ]);
  }

  String? _queueLabel(TravAnimStep? step) {
    if (step == null || step.queue.isEmpty) return null;
    final isBfs = _activeAlgo == 'bfs';
    final items = isBfs ? step.queue.join(', ') : step.queue.reversed.join(', ');
    return '${isBfs ? "Queue" : "Stack"}: [$items]';
  }

  Widget _tabBar() {
    const tabs = ['Code', 'Complexity', 'AI Tutor'];
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF21262D)))),
      child: Row(children: List.generate(tabs.length, (i) {
        final active = _activeTab == i;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _activeTab = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(
                  color: active ? _accent : Colors.transparent, width: 2)),
            ),
            child: Text(tabs[i], textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: active ? _accent : const Color(0xFF8B949E),
                    fontFamily: 'monospace')),
          ),
        ));
      })),
    );
  }

  Widget _tabContent() {
    final algo = _activeAlgo ?? 'bfs';
    switch (_activeTab) {
      case 0: return TravCodeTab(algorithm: algo,
          onLanguageChanged: (l) => setState(() => _aiLang = l));
      case 1: return TravComplexityCard(algorithm: algo);
      case 2: return AiTutorPanel(config: _buildAiConfig());
      default: return const SizedBox();
    }
  }

  static const _questions = {
    'bfs': ['How does BFS work step by step?',
      'Why does BFS find shortest paths in unweighted graphs?',
      'What data structure does BFS use and why?',
      'Time and space complexity of BFS?', 'BFS vs DFS — when to use which?'],
    'dfs': ['How does DFS work step by step?',
      'Difference between iterative and recursive DFS?',
      'What are back edges in DFS?',
      'How does DFS detect cycles?', 'Time and space complexity of DFS?'],
    'none': ['What is graph traversal?', 'Compare BFS and DFS',
      'What is an adjacency list?', 'What are tree edges vs cross edges?'],
  };

  static const _snippets = {
    'bfs': {'Python': 'def bfs(graph,src):\n    visited=set([src]); q=[src]; order=[]\n    while q:\n        node=q.pop(0); order.append(node)\n        for nb in graph[node]:\n            if nb not in visited: visited.add(nb); q.append(nb)\n    return order',
      'Java':'void bfs(Map g,int src){...}','C':'void bfs(int adj[][],int src){...}','C++':'vector<int> bfs(vector<vector<int>>& g,int src){...}'},
    'dfs': {'Python': 'def dfs(graph,src):\n    visited=set(); stack=[src]; order=[]\n    while stack:\n        node=stack.pop()\n        if node in visited: continue\n        visited.add(node); order.append(node)\n        for nb in reversed(graph[node]):\n            if nb not in visited: stack.append(nb)\n    return order',
      'Java':'void dfs(Map g,int src){...}','C':'void dfs(int adj[][],int src){...}','C++':'vector<int> dfs(vector<vector<int>>& g,int src){...}'},
  };

  AiTutorTopicConfig _buildAiConfig() {
    final algo = _activeAlgo ?? 'none';
    final g = _graph;
    final step = _curStep;
    final ctx = g != null
        ? 'Graph: ${g.n}V, ${g.edges.length}E, ${_props.directed ? "directed" : "undirected"}. '
          'Algorithm: ${algo.toUpperCase()}. Source: $_srcNode. '
          '${step != null ? "Visited: ${step.visitOrder.join(", ")}." : ""}'
        : 'No graph yet.';
    return AiTutorTopicConfig(
      dashboardName: 'Graph Traversal',
      topicKey: algo,
      topicLabel: algo == 'bfs' ? 'Breadth-First Search (BFS)'
          : algo == 'dfs' ? 'Depth-First Search (DFS)' : 'Graph Traversal',
      language: _aiLang,
      codeSnippet: _snippets[algo]?[_aiLang] ?? '',
      systemContext: ctx,
      suggestedQuestions: _questions[algo] ?? _questions['none']!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _curStep;
    final hasGraph = _graph != null;
    final hasAlgo = _activeAlgo != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Top bar
            Container(
              color: const Color(0xFF161B22),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(children: [
                const Icon(Icons.account_tree_outlined, color: Color(0xFF3B82F6), size: 18),
                const SizedBox(width: 8),
                const Text('Graph Traversal',
                    style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 15,
                        fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                const Spacer(),
                if (hasAlgo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      border: Border.all(color: _accent.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_activeAlgo == 'bfs' ? 'BFS' : 'DFS',
                        style: TextStyle(color: _accentLight, fontSize: 10,
                            fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                  )
                else if (hasGraph)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('${_graph!.n}V · ${_graph!.edges.length}E',
                        style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 10,
                            fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                  ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TravPropertyCheckboxes(props: _props, onChanged: _onPropsChanged),
                const SizedBox(height: 10),

                TravUnifiedCanvas(
                  key: _canvasKey, props: _props,
                  onGraphReady: _onGraphReady,
                  animStep: hasAlgo ? step : null,
                  activeAlgo: _activeAlgo,
                ),
                const SizedBox(height: 14),

                if (hasGraph) ...[_srcPicker(), const SizedBox(height: 14)],

                Row(children: [
                  _algoBtn(algo: 'bfs', label: 'BFS\nBreadth First',
                      icon: Icons.waves, accent: const Color(0xFF3B82F6)),
                  const SizedBox(width: 10),
                  _algoBtn(algo: 'dfs', label: 'DFS\nDepth First',
                      icon: Icons.linear_scale, accent: const Color(0xFF9333EA)),
                ]),
                const SizedBox(height: 14),

                if (hasAlgo) ...[
                  TravAnimControls(
                    playing: _playing, finished: _finished,
                    stepIndex: _currentStep, totalSteps: _steps.length,
                    speedMs: _speedMs,
                    statusMsg: step?.statusMsg ?? 'Press ▶ Play to start.',
                    queueLabel: _queueLabel(step),
                    onPlay: _play, onPause: _pause,
                    onStepForward: _stepFwd, onStepBack: _stepBack,
                    onReset: _hardReset,
                    onSpeedChanged: (v) => setState(() => _speedMs = v),
                    accentColor: _accent,
                  ),
                  const SizedBox(height: 14),
                ],

                if (hasAlgo && step != null) _visitPanel(step),

                if (hasAlgo && step != null && step.type == TravStepType.done) ...[
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.10),
                      border: Border.all(color: _accent.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Icon(Icons.check_circle_outline, color: _accent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(step.statusMsg,
                          style: TextStyle(color: _accentLight, fontSize: 11,
                              fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
                    ]),
                  ),
                  const SizedBox(height: 14),
                ],

                _tabBar(),
                _tabContent(),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}