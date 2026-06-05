import 'package:flutter/material.dart';
import 'language_dropdown.dart';

class CodeTabSection extends StatefulWidget {
  final String algorithm;
  final void Function(String language)? onLanguageChanged;

  const CodeTabSection({
    super.key,
    required this.algorithm,
    this.onLanguageChanged,
  });

  @override
  State<CodeTabSection> createState() => _CodeTabSectionState();
}

class _CodeTabSectionState extends State<CodeTabSection> {
  String _lang = 'Python';

  static const Map<String, Map<String, String>> _snippets = {
    'linear_search': {
      'Python': '''def linear_search(arr, target):
    for i in range(len(arr)):
        if arr[i] == target:
            return i   # found at index i
    return -1          # not found''',
      'Java': '''int linearSearch(int[] arr, int target) {
    for (int i = 0; i < arr.length; i++) {
        if (arr[i] == target)
            return i;
    }
    return -1;
}''',
      'C': '''int linearSearch(int arr[], int n, int target) {
    for (int i = 0; i < n; i++) {
        if (arr[i] == target)
            return i;
    }
    return -1;
}''',
      'C++': '''int linearSearch(vector<int>& arr, int target) {
    for (int i = 0; i < arr.size(); i++) {
        if (arr[i] == target)
            return i;
    }
    return -1;
}''',
    },
    'binary_search': {
      'Python': '''def binary_search(arr, target):
    low, high = 0, len(arr) - 1
    while low <= high:
        mid = (low + high) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1''',
      'Java': '''int binarySearch(int[] arr, int target) {
    int low = 0, high = arr.length - 1;
    while (low <= high) {
        int mid = (low + high) / 2;
        if (arr[mid] == target)
            return mid;
        else if (arr[mid] < target)
            low = mid + 1;
        else
            high = mid - 1;
    }
    return -1;
}''',
      'C': '''int binarySearch(int arr[], int n, int target) {
    int low = 0, high = n - 1;
    while (low <= high) {
        int mid = (low + high) / 2;
        if (arr[mid] == target)
            return mid;
        else if (arr[mid] < target)
            low = mid + 1;
        else
            high = mid - 1;
    }
    return -1;
}''',
      'C++': '''int binarySearch(vector<int>& arr, int target) {
    int low = 0, high = arr.size() - 1;
    while (low <= high) {
        int mid = (low + high) / 2;
        if (arr[mid] == target)
            return mid;
        else if (arr[mid] < target)
            low = mid + 1;
        else
            high = mid - 1;
    }
    return -1;
}''',
    },
    'jump_search': {
      'Python': '''import math
def jump_search(arr, target):
    n = len(arr)
    step = int(math.sqrt(n))
    prev = 0
    while arr[min(step,n)-1] < target:
        prev = step
        step += int(math.sqrt(n))
        if prev >= n:
            return -1
    while arr[prev] < target:
        prev += 1
        if prev == min(step, n):
            return -1
    if arr[prev] == target:
        return prev
    return -1''',
      'Java': '''int jumpSearch(int[] arr, int target) {
    int n = arr.length;
    int step = (int)Math.sqrt(n);
    int prev = 0;
    while (arr[Math.min(step,n)-1] < target) {
        prev = step;
        step += (int)Math.sqrt(n);
        if (prev >= n) return -1;
    }
    while (arr[prev] < target) {
        prev++;
        if (prev == Math.min(step, n))
            return -1;
    }
    return arr[prev] == target ? prev : -1;
}''',
      'C': '''int jumpSearch(int arr[], int n, int target) {
    int step = (int)sqrt(n);
    int prev = 0;
    while (arr[fmin(step,n)-1] < target) {
        prev = step;
        step += (int)sqrt(n);
        if (prev >= n) return -1;
    }
    while (arr[prev] < target) {
        prev++;
        if (prev == fmin(step,n)) return -1;
    }
    return (arr[prev]==target) ? prev : -1;
}''',
      'C++': '''int jumpSearch(vector<int>& arr, int target) {
    int n = arr.size();
    int step = (int)sqrt(n), prev = 0;
    while (arr[min(step,n)-1] < target) {
        prev = step;
        step += (int)sqrt(n);
        if (prev >= n) return -1;
    }
    while (arr[prev] < target) {
        if (++prev == min(step,n)) return -1;
    }
    return arr[prev] == target ? prev : -1;
}''',
    },
  };

  static const _keywords = [
    'def', 'return', 'for', 'if', 'elif', 'else', 'while', 'in', 'range',
    'import', 'int', 'void', 'vector', 'Math', 'sqrt', 'fmin', 'min',
    'true', 'false', 'null', 'len', 'size',
  ];

  List<TextSpan> _colorize(String line) {
    final spans = <TextSpan>[];
    final tokenRegex = RegExp(r'([A-Za-z_]\w*|\d+|[^\w\s]|\s+)');
    for (final m in tokenRegex.allMatches(line)) {
      final token = m.group(0)!;
      final trimmed = token.trim();
      Color color;
      if (_keywords.contains(trimmed)) {
        color = const Color(0xFFC084FC);
      } else if (RegExp(r'^\d+$').hasMatch(trimmed)) {
        color = const Color(0xFFFB923C);
      } else if (trimmed.startsWith('#') || trimmed.startsWith('//')) {
        color = const Color(0xFF6B7280);
      } else {
        color = const Color(0xFFE2E8F0);
      }
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final code = _snippets[widget.algorithm]?[_lang] ?? '// Not available';
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
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
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              height: 1.6,
                            ),
                            children: _colorize(lines[i]),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}