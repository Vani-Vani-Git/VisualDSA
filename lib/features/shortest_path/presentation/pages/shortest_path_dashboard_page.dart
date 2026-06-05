import 'package:flutter/material.dart';
import '../models/sp_graph_model.dart';
import '../widgets/sp_draw_panel.dart';
import '../widgets/sp_anim_controls.dart';
import '../widgets/sp_code_tab.dart';
import '../widgets/sp_complexity_card.dart';
import '../widgets/sp_property_checkboxes.dart';
// Adjust this import to match your project structure
import '../../../../shared/widgets/ai_tutor_panel.dart';

class ShortestPathDashboard extends StatefulWidget {
  const ShortestPathDashboard({super.key});

  @override
  State<ShortestPathDashboard> createState() =>
      _ShortestPathDashboardState();
}

class _ShortestPathDashboardState extends State<ShortestPathDashboard> {
  // ── Graph state ─────────────────────────────────────────────────────────────
  SpGraphProperties _props = SpGraphProperties(
    weighted: true,
    directed: false,
    connected: false,
  );
  SpGraphModel? _graph;

  // Key to access the canvas state (for future use / reset)
  final GlobalKey<SpUnifiedCanvasState> _canvasKey =
      GlobalKey<SpUnifiedCanvasState>();

  // ── Algorithm state ─────────────────────────────────────────────────────────
  String? _activeAlgo; // 'dijkstra' | 'bellman_ford'
  int _srcNode = 0;

  // ── Animation state ─────────────────────────────────────────────────────────
  List<SpAnimStep> _steps = [];
  int _currentStep = 0;
  bool _playing = false;
  bool _finished = false;
  int _speedMs = 600;

  // For restart
  SpGraphModel? _lastGraph;
  String? _lastAlgo;
  int? _lastSrc;

  // ── Tab state ────────────────────────────────────────────────────────────────
  int _activeTab = 0;
  String _aiLang = 'Python';

  // ─────────────────────────────────────────────────────────────────────────────

  void _onPropsChanged(SpGraphProperties p) {
    setState(() {
      _props = p;
      _resetAnim();
      _activeAlgo = null;
    });
  }

  void _onGraphReady(SpGraphModel g) {
    setState(() {
      _graph = SpGraphModel(
        vertices: g.vertices,
        edges: g.edges,
        properties: _props,
      );
      _resetAnim();
      _activeAlgo = null;
      final ids = g.vertices.map((v) => v.id).toList()..sort();
      if (ids.isNotEmpty) _srcNode = ids.first;
    });
  }

  // ── Algorithm execution ──────────────────────────────────────────────────────

  void _runAlgo(String algo) {
    SpGraphModel g = _graph ??
        SpGraphModel.random(_props, const Size(300, 280));

    // Clamp srcNode
    final ids = g.vertices.map((v) => v.id).toList()..sort();
    if (!ids.contains(_srcNode)) _srcNode = ids.first;

    final steps = algo == 'dijkstra'
        ? DijkstraGenerator.generate(g, _srcNode)
        : BellmanFordGenerator.generate(g, _srcNode);

    setState(() {
      _graph = g;
      _activeAlgo = algo;
      _lastAlgo = algo;
      _lastGraph = g;
      _lastSrc = _srcNode;
      _steps = steps;
      _currentStep = 0;
      _playing = false;
      _finished = false;
    });
  }

  void _resetAnim() {
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
        }
      });
    }
  }

  void _pause() => setState(() => _playing = false);

  void _stepFwd() {
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

  void _hardReset() {
    if (_lastAlgo != null && _lastGraph != null) {
      final steps = _lastAlgo == 'dijkstra'
          ? DijkstraGenerator.generate(_lastGraph!, _lastSrc!)
          : BellmanFordGenerator.generate(_lastGraph!, _lastSrc!);
      setState(() {
        _graph = _lastGraph;
        _activeAlgo = _lastAlgo;
        _srcNode = _lastSrc!;
        _steps = steps;
        _currentStep = 0;
        _playing = false;
        _finished = false;
      });
    } else {
      setState(() {
        _currentStep = 0;
        _playing = false;
        _finished = false;
      });
    }
  }

  SpAnimStep? get _curStep =>
      (_steps.isNotEmpty &&
              _currentStep > 0 &&
              _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  // ── Source node picker ───────────────────────────────────────────────────────

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
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF59E0B).withOpacity(0.15),
              border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.6)),
            ),
            child: const Center(
              child: Text('S',
                  style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace')),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Source Node',
              style: TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 11,
                  fontFamily: 'monospace')),
          const Spacer(),
          DropdownButton<int>(
            value: ids.contains(_srcNode) ? _srcNode : ids.first,
            isDense: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1C2128),
            style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                fontFamily: 'monospace'),
            items: ids
                .map((id) => DropdownMenuItem(
                      value: id,
                      child: Text('Node $id',
                          style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontFamily: 'monospace')),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _srcNode = v;
                  _resetAnim();
                  _activeAlgo = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Algorithm button ─────────────────────────────────────────────────────────

  Widget _algoBtn({
    required String algo,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    final isActive = _activeAlgo == algo;
    return Expanded(
      child: GestureDetector(
        onTap: () => _runAlgo(algo),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:
                isActive ? accent.withOpacity(0.15) : const Color(0xFF161B22),
            border: Border.all(
              color: isActive ? accent : const Color(0xFF30363D),
              width: isActive ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isActive ? accent : const Color(0xFF8B949E),
                  size: 16),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? accent : const Color(0xFFE2E8F0),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Distance table ───────────────────────────────────────────────────────────

  Widget _distTable(SpAnimStep step) {
    final vertices = _graph!.vertices;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFF21262D)))),
            child: Row(
              children: const [
                SizedBox(
                    width: 36,
                    child: Text('Node',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace'))),
                Spacer(),
                SizedBox(
                    width: 50,
                    child: Text('Dist',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace'))),
                SizedBox(
                    width: 40,
                    child: Text('Via',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace'))),
              ],
            ),
          ),
          ...vertices.map((v) {
            final d = step.dist[v.id] ?? 999999;
            final isPath = step.inPath.contains(v.id);
            final isCurrent = v.id == step.currentNode ||
                v.id == step.fromNode ||
                v.id == step.toNode;
            final isFinalized = step.visited.contains(v.id);
            final prev = step.prev[v.id];
            final isSrc = v.id == _srcNode;

            Color rowBg = Colors.transparent;
            Color textCol = const Color(0xFFE2E8F0);

            if (isPath && step.type == SpStepType.pathFound) {
              rowBg = const Color(0xFF22C55E).withOpacity(0.10);
              textCol = const Color(0xFF22C55E);
            } else if (isCurrent) {
              rowBg = const Color(0xFFF59E0B).withOpacity(0.08);
              textCol = const Color(0xFFFBBF24);
            } else if (isFinalized) {
              rowBg = const Color(0xFF3B82F6).withOpacity(0.06);
              textCol = const Color(0xFF60A5FA);
            }

            return Container(
              color: rowBg,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: textCol.withOpacity(0.15),
                            border: Border.all(
                                color: textCol.withOpacity(0.5)),
                          ),
                          child: Center(
                            child: Text(v.label,
                                style: TextStyle(
                                    color: textCol,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace')),
                          ),
                        ),
                        if (isSrc)
                          const Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Text('S',
                                style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 8,
                                    fontFamily: 'monospace')),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 50,
                    child: Text(
                      d >= 999999 ? '∞' : '$d',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textCol,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      isSrc ? 'src' : (prev != null ? '$prev' : '-'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textCol.withOpacity(0.7),
                          fontSize: 11,
                          fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Tabs ─────────────────────────────────────────────────────────────────────

  Widget _tabBar() {
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
                    fontSize: 12,
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

  Widget _tabContent() {
    final algo = _activeAlgo ?? 'dijkstra';
    switch (_activeTab) {
      case 0:
        return SpCodeTabSection(
            algorithm: algo,
            onLanguageChanged: (l) => setState(() => _aiLang = l));
      case 1:
        return SpComplexityCard(algorithm: algo);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }

  // ── AI Tutor config ──────────────────────────────────────────────────────────

  static const _algoQuestions = {
    'dijkstra': [
      "How does Dijkstra's algorithm work?",
      "Why can't Dijkstra handle negative weights?",
      'What data structure does Dijkstra use?',
      'Time complexity with a priority queue?',
      'How does greedy choice guarantee optimality?',
    ],
    'bellman_ford': [
      'How does Bellman-Ford differ from Dijkstra?',
      'Why relax edges V-1 times?',
      'How does it detect negative cycles?',
      'Time complexity of Bellman-Ford?',
      'When to use Bellman-Ford over Dijkstra?',
    ],
    'none': [
      'What is the shortest path problem?',
      'Compare Dijkstra vs Bellman-Ford',
      'What is edge relaxation?',
      'What is a weighted directed graph?',
    ],
  };

  static const _codeSnippets = {
    'dijkstra': {
      'Python':
          'import heapq\ndef dijkstra(graph, src, n):\n    dist=[float("inf")]*n; dist[src]=0\n    pq=[(0,src)]\n    while pq:\n        d,u=heapq.heappop(pq)\n        if d>dist[u]: continue\n        for v,w in graph[u]:\n            if dist[u]+w<dist[v]:\n                dist[v]=dist[u]+w\n                heapq.heappush(pq,(dist[v],v))\n    return dist',
      'Java':
          'void dijkstra(List<int[]>[] g, int src, int n){...}',
      'C': 'void dijkstra(int graph[V][V], int src){...}',
      'C++':
          'vector<int> dijkstra(vector<vector<pair<int,int>>>& g,int src,int n){...}',
    },
    'bellman_ford': {
      'Python':
          'def bellman_ford(edges, n, src):\n    dist=[float("inf")]*n; dist[src]=0\n    for _ in range(n-1):\n        for u,v,w in edges:\n            if dist[u]+w<dist[v]:\n                dist[v]=dist[u]+w\n    return dist',
      'Java': 'void bellmanFord(int[][] edges,int n,int src){...}',
      'C': 'void bellmanFord(struct Edge[],int V,int E,int src){...}',
      'C++': 'vector<int> bellmanFord(vector<Edge>&,int n,int src){...}',
    },
  };

  AiTutorTopicConfig _buildAiConfig() {
    final algo = _activeAlgo ?? 'none';
    final g = _graph;
    final ctx = g != null
        ? 'Graph: ${g.n} vertices, ${g.edges.length} edges, '
            '${_props.directed ? "directed" : "undirected"}, '
            '${_props.weighted ? "weighted" : "unweighted"}. '
            'Source node: $_srcNode. '
            '${_steps.isNotEmpty ? "Animation step $_currentStep / ${_steps.length}." : ""}'
        : 'No graph created yet.';

    return AiTutorTopicConfig(
      dashboardName: 'Shortest Path Algorithms',
      topicKey: algo,
      topicLabel: algo == 'dijkstra'
          ? "Dijkstra's Algorithm"
          : algo == 'bellman_ford'
              ? 'Bellman-Ford Algorithm'
              : 'Shortest Path Algorithms',
      language: _aiLang,
      codeSnippet: _codeSnippets[algo]?[_aiLang] ?? '',
      systemContext: ctx,
      suggestedQuestions:
          _algoQuestions[algo] ?? _algoQuestions['none']!,
    );
  }

  // ── Bellman-Ford iteration label ─────────────────────────────────────────────
  String? get _iterLabel {
    final step = _curStep;
    if (step == null || _activeAlgo != 'bellman_ford') return null;
    if (step.iteration == null) return null;
    final total = _graph != null ? _graph!.n - 1 : '?';
    return 'Iteration ${step.iteration} / $total';
  }

  // ─────────────────────────────────────────────────────────────────────────────

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Container(
                color: const Color(0xFF161B22),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    const Icon(Icons.route_outlined,
                        color: Color(0xFF3B82F6), size: 18),
                    const SizedBox(width: 8),
                    const Text('Shortest Path',
                        style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace')),
                    const Spacer(),
                    if (hasAlgo)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (_activeAlgo == 'dijkstra'
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF9333EA))
                              .withOpacity(0.12),
                          border: Border.all(
                              color: (_activeAlgo == 'dijkstra'
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFF9333EA))
                                  .withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _activeAlgo == 'dijkstra'
                              ? "Dijkstra's"
                              : 'Bellman-Ford',
                          style: TextStyle(
                              color: _activeAlgo == 'dijkstra'
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFC084FC),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace'),
                        ),
                      )
                    else if (hasGraph)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF21262D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_graph!.n}V · ${_graph!.edges.length}E',
                          style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Property checkboxes ──────────────────────────────
                    SpPropertyCheckboxes(
                        props: _props, onChanged: _onPropsChanged),

                    const SizedBox(height: 10),

                    // ── UNIFIED CANVAS (draw + random + algo vis) ────────
                    SpUnifiedCanvas(
                      key: _canvasKey,
                      props: _props,
                      onGraphReady: _onGraphReady,
                      // Pass algo step to the same canvas for visualization
                      animStep: hasAlgo ? step : null,
                      srcNode: hasAlgo ? _srcNode : null,
                    ),

                    const SizedBox(height: 14),

                    // ── Source node picker (shown once graph exists) ──────
                    if (hasGraph) ...[
                      _srcPicker(),
                      const SizedBox(height: 14),
                    ],

                    // ── Algorithm buttons ────────────────────────────────
                    Row(
                      children: [
                        _algoBtn(
                          algo: 'dijkstra',
                          label: "Dijkstra's\nAlgorithm",
                          icon: Icons.alt_route,
                          accent: const Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 10),
                        _algoBtn(
                          algo: 'bellman_ford',
                          label: 'Bellman-Ford\nAlgorithm',
                          icon: Icons.repeat_rounded,
                          accent: const Color(0xFF9333EA),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Animation controls (shown once algo is chosen) ────
                    if (hasAlgo) ...[
                      SpAnimControls(
                        playing: _playing,
                        finished: _finished,
                        stepIndex: _currentStep,
                        totalSteps: _steps.length,
                        speedMs: _speedMs,
                        statusMsg: step?.statusMsg ??
                            'Press ▶ Play to start the visualization.',
                        iterationLabel: _iterLabel,
                        onPlay: _play,
                        onPause: _pause,
                        onStepForward: _stepFwd,
                        onStepBack: _stepBack,
                        onReset: _hardReset,
                        onSpeedChanged: (v) =>
                            setState(() => _speedMs = v),
                      ),

                      const SizedBox(height: 14),
                    ],

                    // ── Distance table ────────────────────────────────────
                    if (hasAlgo && step != null) ...[
                      Row(
                        children: [
                          const Text('Distance Table',
                              style: TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace')),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF21262D),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('src = $_srcNode',
                                style: const TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 9,
                                    fontFamily: 'monospace')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _distTable(step),
                      const SizedBox(height: 10),
                    ],

                    // ── Path found / no path banner ───────────────────────
                    if (hasAlgo &&
                        step != null &&
                        step.type == SpStepType.pathFound) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.10),
                          border: Border.all(
                              color:
                                  const Color(0xFF22C55E).withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Color(0xFF22C55E), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(step.statusMsg,
                                  style: const TextStyle(
                                      color: Color(0xFF4ADE80),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (hasAlgo &&
                        step != null &&
                        step.type == SpStepType.noPath) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.10),
                          border: Border.all(
                              color:
                                  const Color(0xFFEF4444).withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFEF4444), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(step.statusMsg,
                                  style: const TextStyle(
                                      color: Color(0xFFF87171),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Code / Complexity / AI Tutor tabs ─────────────────
                    _tabBar(),
                    _tabContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}