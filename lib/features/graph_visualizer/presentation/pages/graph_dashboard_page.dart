import 'package:flutter/material.dart';
import '../models/graph_model.dart';
import '../models/graph_anim_generator.dart';
import '../widgets/graph_property_checkboxes.dart';
import '../widgets/create_graph_panel.dart';
import '../widgets/adjacency_matrix_view.dart';
import '../widgets/adjacency_list_view.dart';
import '../widgets/graph_controls.dart';
import '../widgets/code_tab_section.dart';
import '../widgets/complexity_card.dart';
import '../../../../../../../../shared/widgets/ai_tutor_panel.dart';

class GraphDashboardPage extends StatefulWidget {
  const GraphDashboardPage({super.key});
  @override
  State<GraphDashboardPage> createState() => _GraphDashboardPageState();
}

class _GraphDashboardPageState extends State<GraphDashboardPage> {
  // ── Graph properties (Weighted / Directed / Connected checkboxes) ──────────
  // Single instance — no duplicate global variable
  GraphProperties _props = GraphProperties(directed: true);

  // ── Graph & viz state ──────────────────────────────────────────────────────
  String?     _vizMode;   // null | 'matrix' | 'list'
  GraphModel? _graph;
  int         _activeTab  = 0;
  String      _aiLanguage = 'Python';

  // ── Animation ──────────────────────────────────────────────────────────────
  List<GraphAnimStep> _steps       = [];
  int                 _currentStep = 0;
  bool                _playing     = false;
  bool                _finished    = false;
  int                 _speedMs     = 500;

  // ── Replay state (same fix as heap/queue/stack) ────────────────────────────
  String?    _lastVizMode;
  GraphModel? _lastGraph;

  // ─────────────────────────────────────────────────────────────────────────

  // Called when GraphPropertyCheckboxes changes —
  // update props AND rebuild graph with new properties if one exists
  void _onPropsChanged(GraphProperties p) {
    setState(() {
      _props  = p;
      // If a graph exists, rebuild it with updated properties
      // (directed/weighted flags affect how edges are interpreted)
      if (_graph != null) {
        _graph = GraphModel.fromInput(
          vertexIds:   _graph!.vertices.map((v) => v.id).toList(),
          adjacencies: _graph!.adjacencyList,
          props:       p,
          canvasSize:  const Size(300, 220),
        );
      }
      _vizMode = null;
      _resetAnim();
    });
  }

  // Called when user presses Done (draw) or Random in CreateGraphPanel ─────────
  // Now accepts GraphDrawResult which carries weights, directed, weighted flags
  void _onGraphReady(GraphDrawResult result) {
    // Sync props with what was actually drawn/generated
    final syncedProps = _props.copyWith(
      directed:  result.isDirected,
      weighted:  result.isWeighted,
      connected: result.isConnected,
    );

    // Build weights map in the format GraphModel.fromInput expects:
    // Map<int, Map<int, int>> — vertex → neighbour → weight
    final weightsForModel = result.isWeighted ? result.weights : <int, Map<int, int>>{};

    final g = GraphModel.fromInput(
      vertexIds:   result.vertices,
      adjacencies: result.adjacency,
      props:       syncedProps,
      canvasSize:  const Size(300, 220),
      weights:     weightsForModel,
    );

    setState(() {
      _props   = syncedProps;          // keep checkboxes in sync
      _graph   = g;
      _vizMode = null;
      _resetAnim();
    });
  }

  // ── Visualization buttons (Adjacency Matrix / Adjacency List) ──────────────
  void _startViz(String mode) {
    GraphModel g = _graph ?? GraphModel.random(_props, const Size(300, 220));
    final steps = mode == 'matrix'
        ? GraphAnimGenerator.matrixSteps(g)
        : GraphAnimGenerator.listSteps(g);
    setState(() {
      _graph        = g;
      _vizMode      = mode;
      _lastVizMode  = mode;   // store for Restart replay
      _lastGraph    = g;
      _steps        = steps;
      _currentStep  = 0;
      _playing      = false;
      _finished     = false;
    });
  }

  void _resetAnim() {
    _steps       = [];
    _currentStep = 0;
    _playing     = false;
    _finished    = false;
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
        }
      });
    }
  }

  void _pause() => setState(() => _playing = false);

  void _stepForward() {
    if (_currentStep < _steps.length) {
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) _finished = true;
      });
    }
  }

  void _stepBack() {
    if (_currentStep > 0) {
      setState(() { _currentStep--; _finished = false; });
    }
  }

  // ── Smart Restart — replays the last viz from step 0 (same fix as heap) ────
  void _hardReset() {
    if (_lastVizMode != null && _lastGraph != null) {
      // Re-generate steps from the stored graph + mode so Play works immediately
      final steps = _lastVizMode == 'matrix'
          ? GraphAnimGenerator.matrixSteps(_lastGraph!)
          : GraphAnimGenerator.listSteps(_lastGraph!);
      setState(() {
        _graph       = _lastGraph;
        _vizMode     = _lastVizMode;
        _steps       = steps;
        _currentStep = 0;
        _playing     = false;
        _finished    = false;
      });
    } else {
      setState(() {
        _currentStep = 0;
        _playing     = false;
        _finished    = false;
      });
    }
  }

  GraphAnimStep? get _curStep =>
      (_steps.isNotEmpty && _currentStep > 0 && _currentStep <= _steps.length)
          ? _steps[_currentStep - 1]
          : null;

  // ── AI config ──────────────────────────────────────────────────────────────

  static const _modeQuestions = {
    'create_graph': [
      'What is a graph in data structures?',
      'Difference between directed and undirected graphs?',
      'What is a weighted graph?',
      'What is a self-loop in a graph?',
      'How do you represent a cyclic graph?',
    ],
    'adjacency_matrix': [
      'How does an adjacency matrix work?',
      'What is the space complexity of an adjacency matrix?',
      'When should I use adjacency matrix over adjacency list?',
      'How to check if an edge exists in O(1)?',
      'Show me adjacency matrix for a directed weighted graph',
    ],
    'adjacency_list': [
      'How does an adjacency list work?',
      'Why is adjacency list better for sparse graphs?',
      'What is the time complexity to find all neighbours?',
      'How is adjacency list implemented in Python?',
      'Compare adjacency list vs adjacency matrix',
    ],
  };

  static const _codeSnippets = {
    'create_graph': {
      'Python': 'class Graph:\n    def __init__(self, V):\n        self.adj = {v: [] for v in range(V)}\n    def add_edge(self, u, v):\n        self.adj[u].append(v)',
      'Java'  : 'class Graph {\n    int V;\n    List<List<Integer>> adj;\n    void addEdge(int u, int v) {\n        adj.get(u).add(v);\n    }\n}',
      'C'     : 'int adj[V][V]={0};\nvoid addEdge(int u,int v){adj[u][v]=1;}',
      'C++'   : 'class Graph{\n    vector<vector<int>> adj;\npublic:\n    void addEdge(int u,int v){adj[u].push_back(v);}\n};',
    },
    'adjacency_matrix': {
      'Python': 'V=5\ngraph=[[0]*V for _ in range(V)]\ndef add_edge(u,v,w=1):\n    graph[u][v]=w\n    graph[v][u]=w',
      'Java'  : 'int[][] graph=new int[V][V];\nvoid addEdge(int u,int v,int w){\n    graph[u][v]=w;\n    graph[v][u]=w;\n}',
      'C'     : 'int graph[V][V]={0};\nvoid addEdge(int u,int v){\n    graph[u][v]=1;\n    graph[v][u]=1;\n}',
      'C++'   : 'int graph[V][V]={0};\nvoid addEdge(int u,int v){\n    graph[u][v]=1;\n    graph[v][u]=1;\n}',
    },
    'adjacency_list': {
      'Python': 'from collections import defaultdict\nadj=defaultdict(list)\ndef add_edge(u,v,w=1):\n    adj[u].append((v,w))\n    adj[v].append((u,w))',
      'Java'  : 'LinkedList<int[]>[] adj=new LinkedList[V];\nvoid addEdge(int u,int v,int w){\n    adj[u].add(new int[]{v,w});\n    adj[v].add(new int[]{u,w});\n}',
      'C'     : 'struct Node{int dest,w;struct Node*next;};\nstruct Node* adj[V];\nvoid addEdge(int u,int v,int w){...}',
      'C++'   : 'vector<vector<pair<int,int>>> adj(V);\nvoid addEdge(int u,int v,int w){\n    adj[u].push_back({v,w});\n    adj[v].push_back({u,w});\n}',
    },
  };

  String get _aiTopicKey => _vizMode == 'matrix'
      ? 'adjacency_matrix'
      : _vizMode == 'list'
          ? 'adjacency_list'
          : 'create_graph';

  AiTutorTopicConfig _buildAiConfig() {
    final g   = _graph;
    final ctx = g != null
        ? 'Graph has ${g.n} vertices and ${g.edges.length} edges. '
          'Properties: ${_props.directed ? "directed" : "undirected"}, '
          '${_props.weighted ? "weighted" : "unweighted"}.'
        : 'No graph created yet.';
    return AiTutorTopicConfig(
      dashboardName:     'Graph Data Structures',
      topicKey:          _aiTopicKey,
      topicLabel:        _vizMode == 'matrix'
          ? 'Adjacency Matrix'
          : _vizMode == 'list'
              ? 'Adjacency List'
              : 'Create Graph',
      language:          _aiLanguage,
      codeSnippet:       _codeSnippets[_aiTopicKey]?[_aiLanguage] ?? '',
      systemContext:     ctx,
      suggestedQuestions: _modeQuestions[_aiTopicKey] ?? [],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final step = _curStep;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ────────────────────────────────────────────────────
              Container(
                color: const Color(0xFF161B22),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.hub_outlined,
                        color: Color(0xFF3B82F6), size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Graph Visualizer',
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    // Graph info badge
                    if (_graph != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF21262D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_graph!.n}V  ${_graph!.edges.length}E'
                          '${_props.directed ? "  →" : "  —"}'
                          '${_props.weighted ? "  W" : ""}',
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                          ),
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
                    // ── Property checkboxes: Weighted / Directed / Connected ──
                    GraphPropertyCheckboxes(
                      props:     _props,
                      onChanged: _onPropsChanged,
                    ),

                    const SizedBox(height: 10),

                    // ── Create graph panel: Draw + Random ──────────────────
                    // Passes checkbox flags so Draw respects them,
                    // and Random generates the right type of graph.
                    CreateGraphPanel(
                      isWeighted:   _props.weighted,
                      isDirected:   _props.directed,
                      isConnected:  _props.connected,
                      onGraphReady: _onGraphReady,  // unified callback
                    ),

                    // ── Two visualization buttons ──────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _vizBtn(
                            label:  'Adjacency Matrix',
                            icon:   Icons.grid_on,
                            active: _vizMode == 'matrix',
                            onTap:  () => _startViz('matrix'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _vizBtn(
                            label:  'Adjacency List',
                            icon:   Icons.format_list_bulleted,
                            active: _vizMode == 'list',
                            onTap:  () => _startViz('list'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Matrix visualization ───────────────────────────────
                    if (_vizMode == 'matrix' && _graph != null) ...[
                      const Text(
                        'Adjacency Matrix',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      AdjacencyMatrixView(
                        graph:        _graph!,
                        highlightRow: step?.highlightRow,
                        highlightCol: step?.highlightCol,
                        revealedUpTo: _currentStep,
                      ),
                      const SizedBox(height: 12),
                      GraphAnimControls(
                        playing:     _playing,
                        finished:    _finished,
                        stepIndex:   _currentStep,
                        totalSteps:  _steps.length,
                        speedMs:     _speedMs,
                        statusMsg:   step?.statusMsg ??
                            'Press Play to start filling the matrix step by step.',
                        onPlay:          _play,
                        onPause:         _pause,
                        onStepForward:   _stepForward,
                        onStepBack:      _stepBack,
                        onReset:         _hardReset,
                        onSpeedChanged:  (v) => setState(() => _speedMs = v),
                      ),
                    ],

                    // ── List visualization ─────────────────────────────────
                    if (_vizMode == 'list' && _graph != null) ...[
                      const Text(
                        'Adjacency List',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      AdjacencyListView(
                        graph:              _graph!,
                        activeVertex:       step?.activeVertex,
                        activeNeighbour:    step?.activeNeighbour,
                        revealedStepIndex:  _currentStep,
                      ),
                      const SizedBox(height: 12),
                      GraphAnimControls(
                        playing:    _playing,
                        finished:   _finished,
                        stepIndex:  _currentStep,
                        totalSteps: _steps.length,
                        speedMs:    _speedMs,
                        statusMsg:  step?.statusMsg ??
                            'Press Play to build the adjacency list step by step.',
                        onPlay:          _play,
                        onPause:         _pause,
                        onStepForward:   _stepForward,
                        onStepBack:      _stepBack,
                        onReset:         _hardReset,
                        onSpeedChanged:  (v) => setState(() => _speedMs = v),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // ── Tabs ───────────────────────────────────────────────
                    _buildTabBar(),
                    _buildTabContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────────────

  Widget _vizBtn({
    required String   label,
    required IconData icon,
    required bool     active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : const Color(0xFF161B22),
          border: Border.all(
            color: active ? const Color(0xFF3B82F6) : const Color(0xFF30363D),
            width: active ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: active ? Colors.white : const Color(0xFF8B949E),
                size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFFE2E8F0),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
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
                    fontSize:   13,
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

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return CodeTabSection(
          mode:             _aiTopicKey,
          onLanguageChanged: (l) => setState(() => _aiLanguage = l),
        );
      case 1:
        return ComplexityCard(mode: _aiTopicKey);
      case 2:
        return AiTutorPanel(config: _buildAiConfig());
      default:
        return const SizedBox();
    }
  }
}