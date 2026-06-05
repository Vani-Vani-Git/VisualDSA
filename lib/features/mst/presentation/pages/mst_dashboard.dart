import 'package:flutter/material.dart';
import '../models/mst_graph_model.dart';
import '../widgets/mst_unified_canvas.dart';
import '../widgets/mst_anim_controls.dart';
import '../widgets/mst_code_tab.dart';
import '../widgets/mst_complexity_card.dart';
import '../widgets/mst_property_checkboxes.dart';
// Adjust this import path to match your project structure
import '../../../../shared/widgets/ai_tutor_panel.dart';

class MstDashboard extends StatefulWidget {
  const MstDashboard({super.key});

  @override
  State<MstDashboard> createState() => _MstDashboardState();
}

class _MstDashboardState extends State<MstDashboard> {
  // ── Graph state ─────────────────────────────────────────────────────────────
  MstGraphProperties _props = MstGraphProperties(weighted: true);
  MstGraphModel? _graph;

  final GlobalKey<MstUnifiedCanvasState> _canvasKey =
      GlobalKey<MstUnifiedCanvasState>();

  // ── Algorithm state ─────────────────────────────────────────────────────────
  String? _activeAlgo; // 'prims' | 'kruskals'

  // ── Animation state ─────────────────────────────────────────────────────────
  List<MstAnimStep> _steps = [];
  int _currentStep = 0;
  bool _playing = false;
  bool _finished = false;
  int _speedMs = 600;

  // For restart
  MstGraphModel? _lastGraph;
  String? _lastAlgo;

  // ── Tab state ────────────────────────────────────────────────────────────────
  int _activeTab = 0;
  String _aiLang = 'Python';

  // ─────────────────────────────────────────────────────────────────────────────

  void _onPropsChanged(MstGraphProperties p) {
    setState(() {
      _props = p;
      _resetAnim();
      _activeAlgo = null;
    });
  }

  void _onGraphReady(MstGraphModel g) {
    setState(() {
      _graph = MstGraphModel(
        vertices: g.vertices,
        edges: g.edges,
        properties: _props,
      );
      _resetAnim();
      _activeAlgo = null;
    });
  }

  // ── Algorithm execution ──────────────────────────────────────────────────────

  void _runAlgo(String algo) {
    MstGraphModel g =
        _graph ?? MstGraphModel.random(_props, const Size(300, 280));

    final steps = algo == 'prims'
        ? PrimGenerator.generate(g, g.vertices.first.id)
        : KruskalGenerator.generate(g);

    setState(() {
      _graph = g;
      _activeAlgo = algo;
      _lastAlgo = algo;
      _lastGraph = g;
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
      final steps = _lastAlgo == 'prims'
          ? PrimGenerator.generate(
              _lastGraph!, _lastGraph!.vertices.first.id)
          : KruskalGenerator.generate(_lastGraph!);
      setState(() {
        _graph = _lastGraph;
        _activeAlgo = _lastAlgo;
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

  MstAnimStep? get _curStep =>
      (_steps.isNotEmpty &&
              _currentStep > 0 &&
              _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

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
            color: isActive
                ? accent.withOpacity(0.15)
                : const Color(0xFF161B22),
            border: Border.all(
              color: isActive ? accent : const Color(0xFF30363D),
              width: isActive ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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

  // ── MST edge table ───────────────────────────────────────────────────────────

  Widget _mstEdgeTable(MstAnimStep step) {
    final mstEdgeKeys = step.mstEdges.toList();
    if (mstEdgeKeys.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF21262D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No MST edges yet.',
            style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 11,
                fontFamily: 'monospace')),
      );
    }

    // Build edge info from graph
    final edgeInfo = <Map<String, dynamic>>[];
    for (final key in mstEdgeKeys) {
      final parts = key.split('-');
      if (parts.length != 2) continue;
      final u = int.tryParse(parts[0]);
      final v = int.tryParse(parts[1]);
      if (u == null || v == null) continue;
      // Find weight
      int w = 0;
      for (final e in (_graph?.edges ?? [])) {
        if ((e.from == u && e.to == v) || (e.from == v && e.to == u)) {
          w = e.weight;
          break;
        }
      }
      edgeInfo.add({'u': u, 'v': v, 'w': w});
    }

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
                    width: 40,
                    child: Text('From',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace'))),
                SizedBox(
                    width: 40,
                    child: Text('To',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace'))),
                Spacer(),
                SizedBox(
                    width: 50,
                    child: Text('Weight',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace'))),
              ],
            ),
          ),
          ...edgeInfo.map((e) {
            final isLatest = mstEdgeKeys.last ==
                _edgeKey(e['u'] as int, e['v'] as int);
            return Container(
              color: isLatest
                  ? const Color(0xFF22C55E).withOpacity(0.10)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: _nodeCircle(
                        '${e['u']}',
                        isLatest
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF3B82F6)),
                  ),
                  SizedBox(
                    width: 40,
                    child: _nodeCircle(
                        '${e['v']}',
                        isLatest
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF3B82F6)),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${e['w']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isLatest
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Total row
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.08),
              border: const Border(
                  top: BorderSide(color: Color(0xFF21262D))),
            ),
            child: Row(
              children: [
                const Text('Total MST Weight',
                    style: TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                        fontFamily: 'monospace')),
                const Spacer(),
                Text(
                  '${step.totalWeight}',
                  style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _edgeKey(int a, int b) => a < b ? '$a-$b' : '$b-$a';

  Widget _nodeCircle(String label, Color color) => Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ),
        ),
      );

  // ── Tab bar / content ────────────────────────────────────────────────────────

  Widget _tabBar() {
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
                        ? const Color(0xFF22C55E)
                        : Colors.transparent,
                    width: 2,
                  )),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? const Color(0xFF22C55E)
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
    final algo = _activeAlgo ?? 'prims';
    switch (_activeTab) {
      case 0:
        return MstCodeTabSection(
            algorithm: algo,
            onLanguageChanged: (l) => setState(() => _aiLang = l));
      case 1:
        return MstComplexityCard(algorithm: algo);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }

  // ── AI config ────────────────────────────────────────────────────────────────

  static const _algoQuestions = {
    'prims': [
      "How does Prim's algorithm work?",
      "What is the cut property in Prim's?",
      'Why does Prim use a priority queue?',
      'Time complexity of Prim with a binary heap?',
      "Prim's vs Kruskal's — when to use which?",
    ],
    'kruskals': [
      "How does Kruskal's algorithm work?",
      'What is Union-Find and why is it used?',
      'How does Kruskal detect cycles?',
      "Time complexity of Kruskal's?",
      'What is path compression in Union-Find?',
    ],
    'none': [
      'What is a Minimum Spanning Tree?',
      'Compare Prim vs Kruskal',
      'What is a spanning tree?',
      'What graph properties does MST require?',
    ],
  };

  static const _codeSnippets = {
    'prims': {
      'Python':
          'import heapq\ndef prims(graph, n, src=0):\n    visited=[False]*n\n    pq=[(0,src,-1)]\n    cost=0\n    while pq:\n        w,u,p=heapq.heappop(pq)\n        if visited[u]: continue\n        visited[u]=True; cost+=w\n        for wt,v in graph[u]:\n            if not visited[v]:\n                heapq.heappush(pq,(wt,v,u))\n    return cost',
      'Java':
          'int prims(List<int[]>[] g, int n){...}',
      'C': 'void prims(int graph[V][V]){...}',
      'C++':
          'int prims(vector<vector<pair<int,int>>>& g, int n){...}',
    },
    'kruskals': {
      'Python':
          'def kruskals(edges, n):\n    edges.sort()\n    uf=UnionFind(n)\n    cost=0\n    for w,u,v in edges:\n        if uf.union(u,v):\n            cost+=w\n    return cost',
      'Java': 'int kruskals(int[][] edges, int n){...}',
      'C': 'int kruskals(struct Edge*, int E, int n){...}',
      'C++': 'int kruskals(vector<Edge>& edges, int n){...}',
    },
  };

  AiTutorTopicConfig _buildAiConfig() {
    final algo = _activeAlgo ?? 'none';
    final g = _graph;
    final step = _curStep;
    final ctx = g != null
        ? 'Graph: ${g.n} vertices, ${g.edges.length} edges, '
            'undirected, ${_props.weighted ? "weighted" : "unweighted"}. '
            'Algorithm: ${algo == 'prims' ? "Prim\'s" : algo == 'kruskals' ? "Kruskal\'s" : "none"}. '
            '${step != null ? "Current MST weight: ${step.totalWeight}. ${step.mstEdges.length} edges in MST. Step $_currentStep/${_steps.length}." : ""}'
        : 'No graph created yet.';

    return AiTutorTopicConfig(
      dashboardName: 'Minimum Spanning Tree',
      topicKey: algo,
      topicLabel: algo == 'prims'
          ? "Prim's Algorithm"
          : algo == 'kruskals'
              ? "Kruskal's Algorithm"
              : 'MST Algorithms',
      language: _aiLang,
      codeSnippet: _codeSnippets[algo]?[_aiLang] ?? '',
      systemContext: ctx,
      suggestedQuestions:
          _algoQuestions[algo] ?? _algoQuestions['none']!,
    );
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
              // ── Top bar ────────────────────────────────────────────────────
              Container(
                color: const Color(0xFF161B22),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    const Icon(Icons.account_tree_outlined,
                        color: Color(0xFF22C55E), size: 18),
                    const SizedBox(width: 8),
                    const Text('Minimum Spanning Tree',
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
                          color: const Color(0xFF22C55E).withOpacity(0.12),
                          border: Border.all(
                              color:
                                  const Color(0xFF22C55E).withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _activeAlgo == 'prims'
                              ? "Prim's"
                              : "Kruskal's",
                          style: const TextStyle(
                              color: Color(0xFF4ADE80),
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
                              color: Color(0xFF22C55E),
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
                    // ── Properties ─────────────────────────────────────────
                    MstPropertyCheckboxes(
                        props: _props, onChanged: _onPropsChanged),

                    const SizedBox(height: 10),

                    // ── Unified canvas ─────────────────────────────────────
                    MstUnifiedCanvas(
                      key: _canvasKey,
                      props: _props,
                      onGraphReady: _onGraphReady,
                      animStep: hasAlgo ? step : null,
                    ),

                    const SizedBox(height: 14),

                    // ── Algorithm buttons ──────────────────────────────────
                    Row(
                      children: [
                        _algoBtn(
                          algo: 'prims',
                          label: "Prim's\nAlgorithm",
                          icon: Icons.hub_outlined,
                          accent: const Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 10),
                        _algoBtn(
                          algo: 'kruskals',
                          label: "Kruskal's\nAlgorithm",
                          icon: Icons.sort,
                          accent: const Color(0xFF9333EA),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Animation controls ─────────────────────────────────
                    if (hasAlgo) ...[
                      MstAnimControls(
                        playing: _playing,
                        finished: _finished,
                        stepIndex: _currentStep,
                        totalSteps: _steps.length,
                        speedMs: _speedMs,
                        statusMsg: step?.statusMsg ??
                            'Press ▶ Play to start the visualization.',
                        currentWeight: step?.totalWeight ?? 0,
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

                    // ── MST edge table ─────────────────────────────────────
                    if (hasAlgo && step != null) ...[
                      Row(
                        children: [
                          const Text('MST Edges',
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
                              color: const Color(0xFF22C55E).withOpacity(0.12),
                              border: Border.all(
                                  color:
                                      const Color(0xFF22C55E).withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${step.mstEdges.length} / ${(_graph?.n ?? 1) - 1}',
                              style: const TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _mstEdgeTable(step),
                      const SizedBox(height: 10),
                    ],

                    // ── MST complete banner ────────────────────────────────
                    if (hasAlgo &&
                        step != null &&
                        step.type == MstStepType.mstComplete) ...[
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

                    // ── Tabs ───────────────────────────────────────────────
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