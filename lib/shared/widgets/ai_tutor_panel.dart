import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
enum MessageRole { user, assistant }

class ChatMessage {
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ─────────────────────────────────────────────────────────────────────────────
// TOPIC CONFIG  — pass one of these into AiTutorPanel for any dashboard
// ─────────────────────────────────────────────────────────────────────────────

/// Defines everything the AI tutor needs to know about the current topic.
///
/// Example — Sorting dashboard:
/// ```dart
/// AiTutorTopicConfig(
///   dashboardName: 'Sorting Algorithms',
///   topicKey: 'bubble_sort',
///   topicLabel: 'Bubble Sort',
///   language: 'Python',
///   codeSnippet: 'def bubble_sort(arr): ...',
///   systemContext: 'The user is viewing a sorting algorithm visualizer.',
/// )
/// ```
class AiTutorTopicConfig {
  /// Human-readable name of the dashboard (e.g. "Sorting Algorithms")
  final String dashboardName;

  /// Internal key for the current topic (e.g. "bubble_sort")
  final String topicKey;

  /// Human-readable topic label (e.g. "Bubble Sort")
  final String topicLabel;

  /// Currently selected language (e.g. "Python")
  final String language;

  /// The code snippet for the current topic + language (may be empty)
  final String codeSnippet;

  /// Extra context injected into the system prompt
  /// (e.g. "The user is on step 3 of 12 in the animation.")
  final String systemContext;
  /// Suggested starter questions shown as quick-tap chips
  final List<String> suggestedQuestions;

  const AiTutorTopicConfig({
    required this.dashboardName,
    required this.topicKey,
    required this.topicLabel,
    required this.language,
    this.codeSnippet = '',
    this.systemContext = '',
    this.suggestedQuestions = const [],
  });

  /// Build the full system prompt from this config
  String get systemPrompt => '''
You are an expert, friendly CS tutor inside a "$dashboardName" learning app.
Current topic: $topicLabel (shown in $language).
${systemContext.isNotEmpty ? 'Context: $systemContext' : ''}
${codeSnippet.isNotEmpty ? 'Current code being viewed:\n```$language\n$codeSnippet\n```' : ''}

Your role:
- Answer any question the student asks about the topic, code, or related concepts.
- Explain step by step when asked.
- If asked to modify/rewrite code, provide clean $language code in a fenced code block.
- Keep answers concise (under 250 words) unless a longer answer is clearly needed.
- Use simple language suitable for students.
- If the question is unrelated to CS/programming, gently redirect to the topic.
''';
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// A fully interactive, reusable AI tutor chat panel.
///
/// Drop this into ANY dashboard by providing an [AiTutorTopicConfig].
/// The chat history is preserved within the session; switching topics
/// (i.e. a new config) automatically resets the conversation.
///
/// Usage:
/// ```dart
/// AiTutorPanel(
///   config: AiTutorTopicConfig(
///     dashboardName: 'Sorting Algorithms',
///     topicKey: 'bubble_sort',
///     topicLabel: 'Bubble Sort',
///     language: 'Python',
///     codeSnippet: myCode,
///     suggestedQuestions: [
///       'How does Bubble Sort work?',
///       'What is its time complexity?',
///       'Can you rewrite it in Java?',
///     ],
///   ),
/// )
/// ```
class AiTutorPanel extends StatefulWidget {
  final AiTutorTopicConfig config;

  const AiTutorPanel({super.key, required this.config});

  @override
  State<AiTutorPanel> createState() => _AiTutorPanelState();
}

class _AiTutorPanelState extends State<AiTutorPanel> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _loading = false;
  String? _lastTopicKey; // tracks when topic changes to reset chat

  @override
  void initState() {
    super.initState();
    _maybeResetForNewTopic();
  }

  @override
  void didUpdateWidget(AiTutorPanel old) {
    super.didUpdateWidget(old);
    _maybeResetForNewTopic();
  }

  void _maybeResetForNewTopic() {
    final newKey = '${widget.config.topicKey}_${widget.config.language}';
    if (_lastTopicKey != null && _lastTopicKey != newKey) {
      setState(() => _messages.clear());
    }
    _lastTopicKey = newKey;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Send a message ────────────────────────────────────────────────────────

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _loading) return;

    final userMsg = ChatMessage(role: MessageRole.user, content: trimmed);
    setState(() {
      _messages.add(userMsg);
      _loading = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    // Build history for the API (exclude system prompt — it's sent separately)
    final history = _messages
        .map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    try {
      final res = await http.post(
        Uri.parse(
          'https://api.groq.com/openai/v1/chat/completions',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          "messages": [
            {
              'role': 'system',
              'content': widget.config.systemPrompt,
            },
            ...history,
          ],
          'temperature': 0.7,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply = data['choices'][0] 
                          ['message']['content'];
        setState(() {
          _messages.add(ChatMessage(role: MessageRole.assistant, content: reply));
          _loading = false;
        });
      } else {
        _addError('API error ${res.statusCode}. Check your API key.');
      }
    } catch (e) {
      _addError('Network error: $e');
    }
    _scrollToBottom();
  }

  void _addError(String msg) {
    setState(() {
      _messages.add(ChatMessage(role: MessageRole.assistant, content: '⚠️ $msg'));
      _loading = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() => setState(() => _messages.clear());

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildChatArea(),
          const SizedBox(height: 8),
          if (_messages.isEmpty) _buildSuggestedQuestions(),
          if (_messages.isEmpty) const SizedBox(height: 8),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1D4ED8).withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text(
                'AI Tutor  •  ${widget.config.topicLabel}',
                style: const TextStyle(
                  color: Color(0xFF93C5FD),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_messages.isNotEmpty)
          GestureDetector(
            onTap: _clearChat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Chat area ─────────────────────────────────────────────────────────────

  Widget _buildChatArea() {
    if (_messages.isEmpty && !_loading) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF21262D)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎓', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                'Ask me anything about ${widget.config.topicLabel}!',
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(10),
        itemCount: _messages.length + (_loading ? 1 : 0),
        itemBuilder: (_, i) {
          if (_loading && i == _messages.length) return _buildTypingIndicator();
          return _buildBubble(_messages[i]);
        },
      ),
    );
  }

  // ── Chat bubble ───────────────────────────────────────────────────────────

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _avatar('🤖'),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(msg.content),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: isUser
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF1C2128),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? 12 : 4),
                    topRight: Radius.circular(isUser ? 4 : 12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: const Color(0xFF30363D)),
                ),
                child: _buildMessageContent(msg.content, isUser),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar('👤'),
        ],
      ),
    );
  }

  Widget _avatar(String emoji) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 14))),
    );
  }

  /// Renders message content — detects fenced code blocks and styles them
  Widget _buildMessageContent(String content, bool isUser) {
    final codeBlockRegex = RegExp(r'```(\w*)\n?([\s\S]*?)```');
    final matches = codeBlockRegex.allMatches(content);

    if (matches.isEmpty) {
      return Text(
        content,
        style: TextStyle(
          color: isUser ? Colors.white : const Color(0xFFCBD5E1),
          fontSize: 13,
          fontFamily: 'monospace',
          height: 1.6,
        ),
      );
    }

    // Split content into text and code block segments
    final spans = <Widget>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Text before code block
      if (match.start > lastEnd) {
        final text = content.substring(lastEnd, match.start).trim();
        if (text.isNotEmpty) {
          spans.add(Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : const Color(0xFFCBD5E1),
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.6,
            ),
          ));
          spans.add(const SizedBox(height: 8));
        }
      }
      // Code block
      final lang = match.group(1) ?? '';
      final code = match.group(2) ?? '';
      spans.add(_CodeBlock(language: lang, code: code.trim()));
      spans.add(const SizedBox(height: 8));
      lastEnd = match.end;
    }

    // Remaining text after last code block
    if (lastEnd < content.length) {
      final text = content.substring(lastEnd).trim();
      if (text.isNotEmpty) {
        spans.add(Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFFCBD5E1),
            fontSize: 13,
            fontFamily: 'monospace',
            height: 1.6,
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: spans,
    );
  }

  // ── Typing indicator ──────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          _avatar('🤖'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2128),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  // ── Suggested questions ───────────────────────────────────────────────────

  Widget _buildSuggestedQuestions() {
    final questions = widget.config.suggestedQuestions.isNotEmpty
        ? widget.config.suggestedQuestions
        : [
            'Explain this step by step',
            'What is the time complexity?',
            'Can you give an example?',
            'How does this compare to other approaches?',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested questions:',
          style: TextStyle(
            color: Color(0xFF8B949E),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: questions.map((q) {
            return GestureDetector(
              onTap: () => _send(q),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q,
                  style: const TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              enabled: !_loading,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                hintText: _loading
                    ? 'AI is thinking...'
                    : 'Ask about ${widget.config.topicLabel}...',
                hintStyle: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onSubmitted: _send,
              textInputAction: TextInputAction.send,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _loading ? null : () => _send(_inputCtrl.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _loading
                      ? const Color(0xFF21262D)
                      : const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _loading ? Icons.hourglass_empty : Icons.send,
                  color: _loading ? const Color(0xFF4B5563) : Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF1C2128),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CODE BLOCK WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _CodeBlock extends StatelessWidget {
  final String language;
  final String code;

  const _CodeBlock({required this.language, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
            ),
            child: Row(
              children: [
                Text(
                  language.isNotEmpty ? language : 'code',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Clipboard.setData(ClipboardData(text: code)),
                  child: const Row(
                    children: [
                      Icon(Icons.copy, size: 12, color: Color(0xFF8B949E)),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Code
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            child: Text(
              code,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPING DOTS ANIMATION
// ─────────────────────────────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final phase = ((t - delay) % 1.0).abs();
            final opacity = phase < 0.5 ? 0.3 + (phase * 1.4) : 1.0 - ((phase - 0.5) * 1.4);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}