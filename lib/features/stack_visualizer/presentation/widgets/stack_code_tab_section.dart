import 'package:flutter/material.dart';
import 'package:visualdsa/features/searching_visualizer/presentation/widgets/language_dropdown.dart';

class StackCodeTabSection extends StatefulWidget {
  final String operation;
  final void Function(String language)? onLanguageChanged;

  const StackCodeTabSection({
    super.key,
    required this.operation,
    this.onLanguageChanged,
  });

  @override
  State<StackCodeTabSection> createState() => _StackCodeTabSectionState();
}

class _StackCodeTabSectionState extends State<StackCodeTabSection> {
  String _lang = 'Python';

  static const Map<String, Map<String, String>> _snippets = {
    'push': {
      'Python': '''class Stack:
    def __init__(self, max_size=8):
        self.stack = []
        self.max_size = max_size

    def push(self, value):
        # Check for stack overflow
        if len(self.stack) >= self.max_size:
            raise OverflowError("Stack Overflow!")
        self.stack.append(value)   # Add to top
        print(f"Pushed {value}. Top → {self.peek()}")

    def peek(self):
        return self.stack[-1] if self.stack else None

    def size(self):
        return len(self.stack)''',
      'Java': '''import java.util.Stack;

public class StackDemo {
    private Stack<Integer> stack = new Stack<>();
    private final int MAX_SIZE = 8;

    public void push(int value) {
        // Check for stack overflow
        if (stack.size() >= MAX_SIZE) {
            throw new RuntimeException("Stack Overflow!");
        }
        stack.push(value); // Add element to top
        System.out.println("Pushed: " + value
            + "  |  Top → " + stack.peek());
    }

    public int peek() {
        return stack.peek();
    }

    public int size() {
        return stack.size();
    }
}''',
      'C': '''#include <stdio.h>
#define MAX 8

int stack[MAX];
int top = -1;

void push(int value) {
    // Check for stack overflow
    if (top >= MAX - 1) {
        printf("Stack Overflow!\\n");
        return;
    }
    stack[++top] = value; // Increment top, then insert
    printf("Pushed %d  |  Top[%d] = %d\\n",
           value, top, stack[top]);
}

int peek() {
    return (top >= 0) ? stack[top] : -1;
}

int size() { return top + 1; }''',
      'C++': '''#include <iostream>
#include <stack>
using namespace std;

class StackDemo {
    stack<int> st;
    const int MAX_SIZE = 8;

public:
    void push(int value) {
        // Check for stack overflow
        if ((int)st.size() >= MAX_SIZE) {
            throw overflow_error("Stack Overflow!");
        }
        st.push(value); // Add to top
        cout << "Pushed: " << value
             << "  |  Top → " << st.top() << endl;
    }

    int peek() { return st.top(); }
    int size()  { return st.size(); }
};''',
    },
    'pop': {
      'Python': '''class Stack:
    def __init__(self):
        self.stack = []

    def pop(self):
        # Check for stack underflow
        if not self.stack:
            raise IndexError("Stack Underflow!")
        value = self.stack.pop()  # Remove from top
        print(f"Popped {value}.")
        return value

    def is_empty(self):
        return len(self.stack) == 0

    def peek(self):
        return self.stack[-1] if self.stack else None''',
      'Java': '''import java.util.Stack;

public class StackDemo {
    private Stack<Integer> stack = new Stack<>();

    public int pop() {
        // Check for stack underflow
        if (stack.isEmpty()) {
            throw new RuntimeException("Stack Underflow!");
        }
        int value = stack.pop(); // Remove from top
        System.out.println("Popped: " + value);
        return value;
    }

    public boolean isEmpty() {
        return stack.isEmpty();
    }

    public int peek() {
        return stack.peek();
    }
}''',
      'C': '''#include <stdio.h>
#define MAX 8

int stack[MAX];
int top = -1;

int pop() {
    // Check for stack underflow
    if (top < 0) {
        printf("Stack Underflow!\\n");
        return -1;
    }
    int value = stack[top--]; // Read, then decrement top
    printf("Popped %d  |  top now = %d\\n", value, top);
    return value;
}

int is_empty() { return top < 0; }

int peek() {
    return (top >= 0) ? stack[top] : -1;
}''',
      'C++': '''#include <iostream>
#include <stack>
using namespace std;

class StackDemo {
    stack<int> st;

public:
    int pop() {
        // Check for stack underflow
        if (st.empty()) {
            throw underflow_error("Stack Underflow!");
        }
        int value = st.top();
        st.pop(); // Remove from top
        cout << "Popped: " << value << endl;
        return value;
    }

    bool isEmpty() { return st.empty(); }
    int  peek()    { return st.top(); }
};''',
    },
    'peek': {
      'Python': '''class Stack:
    def __init__(self):
        self.stack = []

    def peek(self):
        # Check if stack is empty
        if not self.stack:
            raise IndexError("Stack is empty!")
        # Return top element WITHOUT removing it
        return self.stack[-1]

    def push(self, value):
        self.stack.append(value)

    def pop(self):
        return self.stack.pop() if self.stack else None

    def is_empty(self):
        return len(self.stack) == 0''',
      'Java': '''import java.util.Stack;

public class StackDemo {
    private Stack<Integer> stack = new Stack<>();

    public int peek() {
        // Check for empty stack
        if (stack.isEmpty()) {
            throw new RuntimeException("Stack is empty!");
        }
        // Returns top WITHOUT removing it
        return stack.peek();
    }

    public void push(int value) {
        stack.push(value);
    }

    public int pop() {
        return stack.pop();
    }
}''',
      'C': '''#include <stdio.h>
#define MAX 8

int stack[MAX];
int top = -1;

int peek() {
    // Check if stack is empty
    if (top < 0) {
        printf("Stack is empty!\\n");
        return -1;
    }
    // Return top WITHOUT removing it
    printf("Top element = %d\\n", stack[top]);
    return stack[top];
}

void push(int v) { stack[++top] = v; }

int pop() {
    return (top >= 0) ? stack[top--] : -1;
}''',
      'C++': '''#include <iostream>
#include <stack>
using namespace std;

class StackDemo {
    stack<int> st;

public:
    int peek() {
        // Check if stack is empty
        if (st.empty()) {
            throw runtime_error("Stack is empty!");
        }
        // Return top WITHOUT removing it
        return st.top();
    }

    void push(int v) { st.push(v); }

    int pop() {
        int v = st.top();
        st.pop();
        return v;
    }
};''',
    },
  };

  static const _keywords = [
    'def', 'return', 'for', 'if', 'elif', 'else', 'while', 'in', 'range',
    'import', 'int', 'void', 'class', 'public', 'private', 'new', 'throw',
    'throws', 'extends', 'raise', 'bool', 'true', 'false', 'null', 'None',
    'self', 'this', 'const', 'final', 'static', 'using', 'namespace',
    'include', 'return', 'print', 'cout', 'endl', 'not', 'and', 'or',
    'Stack', 'stack', 'push', 'pop', 'peek', 'top', 'size', 'isEmpty',
    'is_empty', 'append',
  ];

  List<TextSpan> _colorize(String line) {
    final spans = <TextSpan>[];
    // Detect full-line comment
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('#') || trimmed.startsWith('//')) {
      return [
        TextSpan(
            text: line,
            style: const TextStyle(color: Color(0xFF6B7280)))
      ];
    }
    final tokenRegex = RegExp(
  r'''(".*?"|'.*?'|[A-Za-z_]\w*|\d+|[^\w\s]|\s+)'''
);
    for (final m in tokenRegex.allMatches(line)) {
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
          LanguageDropdown(
            selected: _lang,
            onChanged: (l) {
              setState(() => _lang = l);
              widget.onLanguageChanged?.call(l);
            },
          ),
          const SizedBox(height: 10),
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
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              height: 1.6,
                            ),
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
}