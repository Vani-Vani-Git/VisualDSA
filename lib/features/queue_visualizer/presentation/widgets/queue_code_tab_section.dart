import 'package:flutter/material.dart';

class QueueCodeTabSection extends StatefulWidget {
  final String operation;
  final void Function(String language)? onLanguageChanged;

  const QueueCodeTabSection({
    super.key,
    required this.operation,
    this.onLanguageChanged,
  });

  @override
  State<QueueCodeTabSection> createState() => _QueueCodeTabSectionState();
}

class _QueueCodeTabSectionState extends State<QueueCodeTabSection> {
  String _lang = 'Python';

  static const _langs = ['Python', 'Java', 'C', 'C++'];

  static const Map<String, Map<String, String>> _snippets = {
    'enqueue': {
      'Python': '''from collections import deque

class Queue:
    def __init__(self, max_size=7):
        self.queue = deque()
        self.max_size = max_size

    def enqueue(self, value):
        # Check for queue overflow
        if len(self.queue) >= self.max_size:
            raise OverflowError("Queue is Full!")
        self.queue.append(value)  # Insert at REAR
        print(f"Enqueued {value}. Rear → {self.rear()}")

    def front(self):
        return self.queue[0] if self.queue else None

    def rear(self):
        return self.queue[-1] if self.queue else None

    def size(self):
        return len(self.queue)''',

      'Java': '''import java.util.LinkedList;
import java.util.Queue;

public class QueueDemo {
    private Queue<Integer> queue = new LinkedList<>();
    private final int MAX_SIZE = 7;

    public void enqueue(int value) {
        // Check for queue overflow
        if (queue.size() >= MAX_SIZE) {
            throw new RuntimeException("Queue is Full!");
        }
        queue.offer(value); // Insert at REAR
        System.out.println("Enqueued: " + value
            + "  |  Rear → " + rear());
    }

    public int front() {
        return queue.peek();
    }

    public int rear() {
        int last = -1;
        for (int v : queue) last = v;
        return last;
    }

    public int size() { return queue.size(); }
}''',

      'C': '''#include <stdio.h>
#define MAX 7

int queue[MAX];
int front = -1, rear = -1;

void enqueue(int value) {
    // Check for queue overflow
    if (rear >= MAX - 1) {
        printf("Queue Overflow!\\n");
        return;
    }
    if (front == -1) front = 0; // First element
    queue[++rear] = value;      // Insert at REAR
    printf("Enqueued %d | rear[%d]=%d\\n",
           value, rear, queue[rear]);
}

int getFront() {
    return (front != -1) ? queue[front] : -1;
}

int getRear() {
    return (rear != -1) ? queue[rear] : -1;
}

int size() { return (rear - front + 1); }''',

      'C++': '''#include <iostream>
#include <queue>
using namespace std;

class QueueDemo {
    queue<int> q;
    const int MAX_SIZE = 7;

public:
    void enqueue(int value) {
        // Check for queue overflow
        if ((int)q.size() >= MAX_SIZE) {
            throw overflow_error("Queue is Full!");
        }
        q.push(value); // Insert at REAR
        cout << "Enqueued: " << value
             << "  |  Rear → " << rear() << endl;
    }

    int front() { return q.front(); }

    int rear() {
        // std::queue doesn't expose rear directly
        queue<int> tmp = q;
        int last = -1;
        while (!tmp.empty()) {
            last = tmp.front(); tmp.pop();
        }
        return last;
    }

    int size() { return q.size(); }
};''',
    },

    'dequeue': {
      'Python': '''from collections import deque

class Queue:
    def __init__(self):
        self.queue = deque()

    def dequeue(self):
        # Check for queue underflow
        if not self.queue:
            raise IndexError("Queue is Empty!")
        value = self.queue.popleft()  # Remove from FRONT
        print(f"Dequeued {value}.")
        return value

    def is_empty(self):
        return len(self.queue) == 0

    def front(self):
        return self.queue[0] if self.queue else None''',

      'Java': '''import java.util.LinkedList;
import java.util.Queue;

public class QueueDemo {
    private Queue<Integer> queue = new LinkedList<>();

    public int dequeue() {
        // Check for queue underflow
        if (queue.isEmpty()) {
            throw new RuntimeException("Queue is Empty!");
        }
        int value = queue.poll(); // Remove from FRONT
        System.out.println("Dequeued: " + value);
        return value;
    }

    public boolean isEmpty() {
        return queue.isEmpty();
    }

    public int front() {
        return queue.peek();
    }
}''',

      'C': '''#include <stdio.h>
#define MAX 7

int queue[MAX];
int front = -1, rear = -1;

int dequeue() {
    // Check for queue underflow
    if (front == -1 || front > rear) {
        printf("Queue Underflow!\\n");
        return -1;
    }
    int value = queue[front++]; // Remove from FRONT
    if (front > rear) {
        front = rear = -1; // Queue is now empty
    }
    printf("Dequeued %d | front now [%d]\\n",
           value, front);
    return value;
}

int isEmpty() {
    return (front == -1 || front > rear);
}

int getFront() {
    return (!isEmpty()) ? queue[front] : -1;
}''',

      'C++': '''#include <iostream>
#include <queue>
using namespace std;

class QueueDemo {
    queue<int> q;

public:
    int dequeue() {
        // Check for queue underflow
        if (q.empty()) {
            throw underflow_error("Queue is Empty!");
        }
        int value = q.front();
        q.pop(); // Remove from FRONT
        cout << "Dequeued: " << value << endl;
        return value;
    }

    bool isEmpty() { return q.empty(); }
    int  front()   { return q.front(); }
};''',
    },

    'peek': {
      'Python': '''from collections import deque

class Queue:
    def __init__(self):
        self.queue = deque()

    def peek(self):
        # Check if queue is empty
        if not self.queue:
            raise IndexError("Queue is Empty!")
        # Return FRONT element WITHOUT removing it
        return self.queue[0]

    def enqueue(self, value):
        self.queue.append(value)

    def dequeue(self):
        return self.queue.popleft() if self.queue else None

    def is_empty(self):
        return len(self.queue) == 0''',

      'Java': '''import java.util.LinkedList;
import java.util.Queue;

public class QueueDemo {
    private Queue<Integer> queue = new LinkedList<>();

    public int peek() {
        // Check if queue is empty
        if (queue.isEmpty()) {
            throw new RuntimeException("Queue is Empty!");
        }
        // Returns FRONT element WITHOUT removing it
        return queue.peek();
    }

    public void enqueue(int value) {
        queue.offer(value);
    }

    public int dequeue() {
        return queue.poll();
    }
}''',

      'C': '''#include <stdio.h>
#define MAX 7

int queue[MAX];
int front = -1, rear = -1;

int peek() {
    // Check if queue is empty
    if (front == -1 || front > rear) {
        printf("Queue is Empty!\\n");
        return -1;
    }
    // Return FRONT element WITHOUT removing
    printf("Front element = %d\\n", queue[front]);
    return queue[front];
}

void enqueue(int v) {
    if (front == -1) front = 0;
    queue[++rear] = v;
}

int dequeue() {
    if (front == -1) return -1;
    return queue[front++];
}''',

      'C++': '''#include <iostream>
#include <queue>
using namespace std;

class QueueDemo {
    queue<int> q;

public:
    int peek() {
        // Check if queue is empty
        if (q.empty()) {
            throw runtime_error("Queue is Empty!");
        }
        // Return FRONT element WITHOUT removing it
        return q.front();
    }

    void enqueue(int v) { q.push(v); }

    int dequeue() {
        int v = q.front();
        q.pop();
        return v;
    }
};''',
    },
  };

  static const _keywords = [
    'def', 'return', 'for', 'if', 'elif', 'else', 'while', 'in', 'range',
    'import', 'from', 'int', 'void', 'class', 'public', 'private', 'new',
    'throw', 'throws', 'raise', 'bool', 'true', 'false', 'null', 'None',
    'self', 'this', 'const', 'final', 'static', 'using', 'namespace',
    'include', 'print', 'cout', 'endl', 'not', 'and', 'or',
    'Queue', 'queue', 'deque', 'LinkedList',
    'enqueue', 'dequeue', 'peek', 'front', 'rear', 'offer', 'poll', 'push',
    'pop', 'isEmpty', 'is_empty', 'append', 'popleft', 'size',
  ];

  List<TextSpan> _colorize(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('#') || trimmed.startsWith('//')) {
      return [
        TextSpan(
            text: line,
            style: const TextStyle(color: Color(0xFF6B7280)))
      ];
    }
    final spans = <TextSpan>[];
    final tokenRx = RegExp( r'''(".*?"|'.*?'|[A-Za-z_]\w*|\d+|[^\w\s]|\s+)''');
    for (final m in tokenRx.allMatches(line)) {
      final token = m.group(0)!;
      final t = token.trim();
      Color color;
      if ((t.startsWith('"') && t.endsWith('"')) ||
          (t.startsWith("'") && t.endsWith("'"))) {
        color = const Color(0xFF86EFAC);
      } else if (_keywords.contains(t)) {
        color = const Color(0xFFC084FC);
      } else if (RegExp(r'^\d+$').hasMatch(t)) {
        color = const Color(0xFFFB923C);
      } else {
        color = const Color(0xFFE2E8F0);
      }
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final code =
        _snippets[widget.operation]?[_lang] ?? '// Not available';
    final lines = code.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language dropdown
          _buildLangDropdown(),
          const SizedBox(height: 10),
          // Code block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(lines.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontFamily: 'monospace')),
                        ),
                        const SizedBox(width: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                height: 1.6),
                            children: _colorize(lines[i]),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangDropdown() {
    bool open = false;
    return StatefulBuilder(builder: (ctx, setSt) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setSt(() => open = !open),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_lang,
                      style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace')),
                  Icon(
                      open
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF8B949E),
                      size: 16),
                ],
              ),
            ),
          ),
          if (open)
            Container(
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128),
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: _langs.map((l) {
                  final sel = l == _lang;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _lang = l);
                      setSt(() => open = false);
                      widget.onLanguageChanged?.call(l);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      color: sel
                          ? const Color(0xFF21262D)
                          : Colors.transparent,
                      child: Text(l,
                          style: TextStyle(
                              color: sel
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontFamily: 'monospace')),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    });
  }
}