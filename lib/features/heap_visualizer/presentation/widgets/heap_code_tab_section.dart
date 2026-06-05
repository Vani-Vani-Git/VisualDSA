import 'package:flutter/material.dart';

class HeapCodeTabSection extends StatefulWidget {
  final String operation;
  final String heapType;
  final void Function(String language)? onLanguageChanged;

  const HeapCodeTabSection({
    super.key,
    required this.operation,
    required this.heapType,
    this.onLanguageChanged,
  });

  @override
  State<HeapCodeTabSection> createState() => _HeapCodeTabSectionState();
}

class _HeapCodeTabSectionState extends State<HeapCodeTabSection> {
  String _lang = 'Python';
  static const _langs = ['Python', 'Java', 'C', 'C++'];

  // ── Code snippets ──────────────────────────────────────────────────────────
  static const Map<String, Map<String, Map<String, String>>> _snippets = {
    'insert': {
      'max': {
        'Python': '''class MaxHeap:
    def __init__(self):
        self.heap = []

    def insert(self, val):
        self.heap.append(val)   # Add at last
        self._heapify_up(len(self.heap) - 1)

    def _heapify_up(self, i):
        parent = (i - 1) // 2
        # While child > parent → swap
        while i > 0 and self.heap[i] > self.heap[parent]:
            self.heap[i], self.heap[parent] = (
                self.heap[parent], self.heap[i])
            i = parent
            parent = (i - 1) // 2''',

        'Java': '''import java.util.ArrayList;

public class MaxHeap {
    private ArrayList<Integer> heap = new ArrayList<>();

    public void insert(int val) {
        heap.add(val);          // Add at last
        heapifyUp(heap.size() - 1);
    }

    private void heapifyUp(int i) {
        int parent = (i - 1) / 2;
        // While child > parent → swap
        while (i > 0 && heap.get(i) > heap.get(parent)) {
            int tmp = heap.get(i);
            heap.set(i, heap.get(parent));
            heap.set(parent, tmp);
            i = parent;
            parent = (i - 1) / 2;
        }
    }
}''',

        'C': '''#define MAX 100
int heap[MAX], size = 0;

void swap(int i, int j) {
    int t = heap[i]; heap[i] = heap[j]; heap[j] = t;
}

void insert(int val) {
    heap[size++] = val;     // Add at last
    int i = size - 1;
    int p = (i - 1) / 2;
    // While child > parent → swap
    while (i > 0 && heap[i] > heap[p]) {
        swap(i, p);
        i = p; p = (i - 1) / 2;
    }
}''',

        'C++': '''#include <vector>
using namespace std;

class MaxHeap {
    vector<int> heap;
    void swap_(int i, int j) {
        int t = heap[i]; heap[i] = heap[j]; heap[j] = t;
    }
public:
    void insert(int val) {
        heap.push_back(val);   // Add at last
        int i = heap.size() - 1;
        int p = (i - 1) / 2;
        // While child > parent → swap
        while (i > 0 && heap[i] > heap[p]) {
            swap_(i, p);
            i = p; p = (i - 1) / 2;
        }
    }
};''',
      },
      'min': {
        'Python': '''class MinHeap:
    def __init__(self):
        self.heap = []

    def insert(self, val):
        self.heap.append(val)   # Add at last
        self._heapify_up(len(self.heap) - 1)

    def _heapify_up(self, i):
        parent = (i - 1) // 2
        # While child < parent → swap
        while i > 0 and self.heap[i] < self.heap[parent]:
            self.heap[i], self.heap[parent] = (
                self.heap[parent], self.heap[i])
            i = parent
            parent = (i - 1) // 2''',

        'Java': '''import java.util.ArrayList;

public class MinHeap {
    private ArrayList<Integer> heap = new ArrayList<>();

    public void insert(int val) {
        heap.add(val);          // Add at last
        heapifyUp(heap.size() - 1);
    }

    private void heapifyUp(int i) {
        int parent = (i - 1) / 2;
        // While child < parent → swap
        while (i > 0 && heap.get(i) < heap.get(parent)) {
            int tmp = heap.get(i);
            heap.set(i, heap.get(parent));
            heap.set(parent, tmp);
            i = parent;
            parent = (i - 1) / 2;
        }
    }
}''',

        'C': '''#define MAX 100
int heap[MAX], size = 0;

void swap(int i, int j) {
    int t = heap[i]; heap[i] = heap[j]; heap[j] = t;
}

void insert(int val) {
    heap[size++] = val;     // Add at last
    int i = size - 1;
    int p = (i - 1) / 2;
    // While child < parent → swap
    while (i > 0 && heap[i] < heap[p]) {
        swap(i, p);
        i = p; p = (i - 1) / 2;
    }
}''',

        'C++': '''#include <vector>
using namespace std;

class MinHeap {
    vector<int> heap;
    void swap_(int i, int j) {
        int t = heap[i]; heap[i] = heap[j]; heap[j] = t;
    }
public:
    void insert(int val) {
        heap.push_back(val);   // Add at last
        int i = heap.size() - 1;
        int p = (i - 1) / 2;
        // While child < parent → swap
        while (i > 0 && heap[i] < heap[p]) {
            swap_(i, p);
            i = p; p = (i - 1) / 2;
        }
    }
};''',
      },
    },

    'delete': {
      'max': {
        'Python': '''class MaxHeap:
    def delete(self, i):
        # Replace target with last element
        self.heap[i] = self.heap[-1]
        self.heap.pop()
        if not self.heap: return
        # Try heapify up then down
        self._heapify_up(i)
        self._heapify_down(i)

    def _heapify_down(self, i):
        n = len(self.heap)
        while True:
            largest, l, r = i, 2*i+1, 2*i+2
            if l < n and self.heap[l] > self.heap[largest]:
                largest = l
            if r < n and self.heap[r] > self.heap[largest]:
                largest = r
            if largest == i: break
            self.heap[i], self.heap[largest] = (
                self.heap[largest], self.heap[i])
            i = largest''',

        'Java': '''public void delete(int i) {
    int last = heap.size() - 1;
    // Replace target with last element
    heap.set(i, heap.get(last));
    heap.remove(last);
    if (heap.isEmpty()) return;
    heapifyUp(i);
    heapifyDown(i);
}

private void heapifyDown(int i) {
    int n = heap.size();
    while (true) {
        int largest = i, l = 2*i+1, r = 2*i+2;
        if (l<n && heap.get(l) > heap.get(largest)) largest=l;
        if (r<n && heap.get(r) > heap.get(largest)) largest=r;
        if (largest == i) break;
        int tmp = heap.get(i);
        heap.set(i, heap.get(largest));
        heap.set(largest, tmp);
        i = largest;
    }
}''',

        'C': '''void heapifyDown(int i, int n) {
    while (1) {
        int largest = i, l = 2*i+1, r = 2*i+2;
        if (l<n && heap[l]>heap[largest]) largest=l;
        if (r<n && heap[r]>heap[largest]) largest=r;
        if (largest == i) break;
        swap(i, largest); i = largest;
    }
}

void deleteNode(int i) {
    heap[i] = heap[--size];  // Replace with last
    heapifyUp(i);
    heapifyDown(i, size);
}''',

        'C++': '''void heapifyDown(int i, int n) {
    while (true) {
        int largest = i, l = 2*i+1, r = 2*i+2;
        if (l<n && heap[l]>heap[largest]) largest=l;
        if (r<n && heap[r]>heap[largest]) largest=r;
        if (largest == i) break;
        swap_(i, largest); i = largest;
    }
}

void deleteNode(int i) {
    heap[i] = heap.back();   // Replace with last
    heap.pop_back();
    if (heap.empty()) return;
    heapifyUp(i);
    heapifyDown(i, heap.size());
}''',
      },
      'min': {
        'Python': '''class MinHeap:
    def delete(self, i):
        # Replace target with last element
        self.heap[i] = self.heap[-1]
        self.heap.pop()
        if not self.heap: return
        self._heapify_up(i)
        self._heapify_down(i)

    def _heapify_down(self, i):
        n = len(self.heap)
        while True:
            smallest, l, r = i, 2*i+1, 2*i+2
            if l < n and self.heap[l] < self.heap[smallest]:
                smallest = l
            if r < n and self.heap[r] < self.heap[smallest]:
                smallest = r
            if smallest == i: break
            self.heap[i], self.heap[smallest] = (
                self.heap[smallest], self.heap[i])
            i = smallest''',

        'Java': '''public void delete(int i) {
    heap.set(i, heap.get(heap.size()-1));
    heap.remove(heap.size()-1);
    if (heap.isEmpty()) return;
    heapifyUp(i);
    heapifyDown(i);
}

private void heapifyDown(int i) {
    int n = heap.size();
    while (true) {
        int smallest = i, l = 2*i+1, r = 2*i+2;
        if (l<n && heap.get(l)<heap.get(smallest)) smallest=l;
        if (r<n && heap.get(r)<heap.get(smallest)) smallest=r;
        if (smallest == i) break;
        int tmp = heap.get(i);
        heap.set(i, heap.get(smallest));
        heap.set(smallest, tmp);
        i = smallest;
    }
}''',

        'C': '''void heapifyDown(int i, int n) {
    while (1) {
        int s = i, l = 2*i+1, r = 2*i+2;
        if (l<n && heap[l]<heap[s]) s=l;
        if (r<n && heap[r]<heap[s]) s=r;
        if (s == i) break;
        swap(i, s); i = s;
    }
}
void deleteNode(int i) {
    heap[i] = heap[--size];
    heapifyUp(i); heapifyDown(i, size);
}''',

        'C++': '''void heapifyDown(int i, int n) {
    while (true) {
        int s = i, l = 2*i+1, r = 2*i+2;
        if (l<n && heap[l]<heap[s]) s=l;
        if (r<n && heap[r]<heap[s]) s=r;
        if (s == i) break;
        swap_(i, s); i = s;
    }
}
void deleteNode(int i) {
    heap[i] = heap.back(); heap.pop_back();
    if (!heap.empty()) { heapifyUp(i); heapifyDown(i, heap.size()); }
}''',
      },
    },

    'update': {
      'max': {
        'Python': '''class MaxHeap:
    def update(self, i, new_val):
        self.heap[i] = new_val
        # Fix upward if new_val is larger than parent
        self._heapify_up(i)
        # Fix downward if new_val is smaller than children
        self._heapify_down(i)

    def _heapify_up(self, i):
        p = (i - 1) // 2
        while i > 0 and self.heap[i] > self.heap[p]:
            self.heap[i], self.heap[p] = self.heap[p], self.heap[i]
            i = p; p = (i - 1) // 2

    def _heapify_down(self, i):
        n = len(self.heap)
        while True:
            lg, l, r = i, 2*i+1, 2*i+2
            if l<n and self.heap[l]>self.heap[lg]: lg=l
            if r<n and self.heap[r]>self.heap[lg]: lg=r
            if lg == i: break
            self.heap[i], self.heap[lg] = self.heap[lg], self.heap[i]
            i = lg''',

        'Java': '''public void update(int i, int newVal) {
    heap.set(i, newVal);
    heapifyUp(i);    // Try bubble up
    heapifyDown(i);  // Try sink down
}''',

        'C': '''void update(int i, int newVal) {
    heap[i] = newVal;
    heapifyUp(i);    // Try bubble up
    heapifyDown(i, size); // Try sink down
}''',

        'C++': '''void update(int i, int newVal) {
    heap[i] = newVal;
    heapifyUp(i);            // Try bubble up
    heapifyDown(i, heap.size()); // Try sink down
}''',
      },
      'min': {
        'Python': '''class MinHeap:
    def update(self, i, new_val):
        self.heap[i] = new_val
        self._heapify_up(i)
        self._heapify_down(i)

    def _heapify_up(self, i):
        p = (i - 1) // 2
        while i > 0 and self.heap[i] < self.heap[p]:
            self.heap[i], self.heap[p] = self.heap[p], self.heap[i]
            i = p; p = (i - 1) // 2

    def _heapify_down(self, i):
        n = len(self.heap)
        while True:
            sm, l, r = i, 2*i+1, 2*i+2
            if l<n and self.heap[l]<self.heap[sm]: sm=l
            if r<n and self.heap[r]<self.heap[sm]: sm=r
            if sm == i: break
            self.heap[i], self.heap[sm] = self.heap[sm], self.heap[i]
            i = sm''',

        'Java': '''public void update(int i, int newVal) {
    heap.set(i, newVal);
    heapifyUp(i);    // Try bubble up
    heapifyDown(i);  // Try sink down
}''',

        'C': '''void update(int i, int newVal) {
    heap[i] = newVal;
    heapifyUp(i);
    heapifyDown(i, size);
}''',

        'C++': '''void update(int i, int newVal) {
    heap[i] = newVal;
    heapifyUp(i);
    heapifyDown(i, heap.size());
}''',
      },
    },

    'sort': {
      'max': {
        'Python': '''def heap_sort(arr):
    n = len(arr)
    # Build max-heap
    for i in range(n//2 - 1, -1, -1):
        _heapify(arr, n, i)
    # Extract elements from heap one by one
    for i in range(n-1, 0, -1):
        arr[0], arr[i] = arr[i], arr[0]  # Move root to end
        _heapify(arr, i, 0)              # Heapify reduced heap

def _heapify(arr, n, i):
    largest, l, r = i, 2*i+1, 2*i+2
    if l < n and arr[l] > arr[largest]: largest = l
    if r < n and arr[r] > arr[largest]: largest = r
    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]
        _heapify(arr, n, largest)''',

        'Java': '''public static void heapSort(int[] arr) {
    int n = arr.length;
    // Build max-heap
    for (int i = n/2-1; i >= 0; i--)
        heapify(arr, n, i);
    // Extract elements one by one
    for (int i = n-1; i > 0; i--) {
        int tmp = arr[0]; arr[0] = arr[i]; arr[i] = tmp;
        heapify(arr, i, 0);
    }
}
static void heapify(int[] arr, int n, int i) {
    int lg = i, l = 2*i+1, r = 2*i+2;
    if (l<n && arr[l]>arr[lg]) lg=l;
    if (r<n && arr[r]>arr[lg]) lg=r;
    if (lg != i) {
        int t = arr[i]; arr[i] = arr[lg]; arr[lg] = t;
        heapify(arr, n, lg);
    }
}''',

        'C': '''void heapify(int arr[], int n, int i) {
    int lg = i, l = 2*i+1, r = 2*i+2;
    if (l<n && arr[l]>arr[lg]) lg=l;
    if (r<n && arr[r]>arr[lg]) lg=r;
    if (lg != i) {
        int t = arr[i]; arr[i] = arr[lg]; arr[lg] = t;
        heapify(arr, n, lg);
    }
}
void heapSort(int arr[], int n) {
    for (int i=n/2-1; i>=0; i--) heapify(arr,n,i);
    for (int i=n-1; i>0; i--) {
        int t=arr[0]; arr[0]=arr[i]; arr[i]=t;
        heapify(arr, i, 0);
    }
}''',

        'C++': '''#include <vector>
using namespace std;
void heapify(vector<int>& a, int n, int i) {
    int lg=i, l=2*i+1, r=2*i+2;
    if(l<n && a[l]>a[lg]) lg=l;
    if(r<n && a[r]>a[lg]) lg=r;
    if(lg!=i){ swap(a[i],a[lg]); heapify(a,n,lg); }
}
void heapSort(vector<int>& a) {
    int n=a.size();
    for(int i=n/2-1;i>=0;i--) heapify(a,n,i);
    for(int i=n-1;i>0;i--){
        swap(a[0],a[i]); heapify(a,i,0);
    }
}''',
      },
      'min': {
        'Python': '''def heap_sort_min(arr):
    # Min-heap sort → descending order
    n = len(arr)
    for i in range(n//2 - 1, -1, -1):
        _heapify_min(arr, n, i)
    for i in range(n-1, 0, -1):
        arr[0], arr[i] = arr[i], arr[0]
        _heapify_min(arr, i, 0)

def _heapify_min(arr, n, i):
    smallest, l, r = i, 2*i+1, 2*i+2
    if l < n and arr[l] < arr[smallest]: smallest = l
    if r < n and arr[r] < arr[smallest]: smallest = r
    if smallest != i:
        arr[i], arr[smallest] = arr[smallest], arr[i]
        _heapify_min(arr, n, smallest)''',

        'Java': '''public static void heapSortMin(int[] arr) {
    int n = arr.length;
    for (int i = n/2-1; i >= 0; i--)
        heapifyMin(arr, n, i);
    for (int i = n-1; i > 0; i--) {
        int tmp = arr[0]; arr[0] = arr[i]; arr[i] = tmp;
        heapifyMin(arr, i, 0);
    }
}
static void heapifyMin(int[] arr, int n, int i) {
    int sm = i, l = 2*i+1, r = 2*i+2;
    if (l<n && arr[l]<arr[sm]) sm=l;
    if (r<n && arr[r]<arr[sm]) sm=r;
    if (sm != i) {
        int t = arr[i]; arr[i] = arr[sm]; arr[sm] = t;
        heapifyMin(arr, n, sm);
    }
}''',

        'C': '''void heapifyMin(int arr[], int n, int i) {
    int sm=i, l=2*i+1, r=2*i+2;
    if(l<n && arr[l]<arr[sm]) sm=l;
    if(r<n && arr[r]<arr[sm]) sm=r;
    if(sm!=i){ int t=arr[i];arr[i]=arr[sm];arr[sm]=t;
               heapifyMin(arr,n,sm); }
}
void heapSortMin(int arr[], int n) {
    for(int i=n/2-1;i>=0;i--) heapifyMin(arr,n,i);
    for(int i=n-1;i>0;i--){
        int t=arr[0];arr[0]=arr[i];arr[i]=t;
        heapifyMin(arr,i,0);
    }
}''',

        'C++': '''void heapifyMin(vector<int>& a, int n, int i) {
    int sm=i,l=2*i+1,r=2*i+2;
    if(l<n&&a[l]<a[sm]) sm=l;
    if(r<n&&a[r]<a[sm]) sm=r;
    if(sm!=i){ swap(a[i],a[sm]); heapifyMin(a,n,sm); }
}
void heapSortMin(vector<int>& a) {
    int n=a.size();
    for(int i=n/2-1;i>=0;i--) heapifyMin(a,n,i);
    for(int i=n-1;i>0;i--){
        swap(a[0],a[i]); heapifyMin(a,i,0);
    }
}''',
      },
    },
  };

  static const _keywords = [
    'def', 'return', 'for', 'if', 'elif', 'else', 'while', 'in', 'range',
    'class', 'self', 'import', 'from', 'not', 'and', 'or', 'True', 'False',
    'None', 'break', 'int', 'void', 'public', 'private', 'static', 'new',
    'this', 'true', 'false', 'null', 'using', 'namespace', 'include',
    'vector', 'ArrayList', 'swap', 'swap_', 'heapify', 'heapifyUp',
    'heapifyDown', 'heapifyMin', 'insert', 'delete', 'update', 'size',
    'push_back', 'pop_back', 'back', 'empty', 'add', 'get', 'set',
    'remove', 'append', 'pop',
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
    final rx = RegExp(
  r'''(".*?"|'.*?'|[A-Za-z_]\w*|\d+|[^\w\s]|\s+)'''
);
    for (final m in rx.allMatches(line)) {
      final tok = m.group(0)!;
      final t = tok.trim();
      Color c;
      if ((t.startsWith('"') && t.endsWith('"')) ||
          (t.startsWith("'") && t.endsWith("'"))) {
        c = const Color(0xFF86EFAC);
      } else if (_keywords.contains(t)) {
        c = const Color(0xFFC084FC);
      } else if (RegExp(r'^\d+$').hasMatch(t)) {
        c = const Color(0xFFFB923C);
      } else {
        c = const Color(0xFFE2E8F0);
      }
      spans.add(TextSpan(text: tok, style: TextStyle(color: c)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final code = _snippets[widget.operation]?[widget.heapType]?[_lang]
        ?? '// Not available';
    final lines = code.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLangDropdown(),
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
    return StatefulBuilder(builder: (_, setSt) {
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
                                  ? const Color(0xFFEF4444)
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