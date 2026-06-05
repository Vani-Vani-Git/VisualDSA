import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HuffmanCodeTab extends StatefulWidget {
  final void Function(String lang)? onLanguageChanged;

  const HuffmanCodeTab({super.key, this.onLanguageChanged});

  @override
  State<HuffmanCodeTab> createState() => _HuffmanCodeTabState();
}

class _HuffmanCodeTabState extends State<HuffmanCodeTab> {
  String _lang = 'Python';
  bool _langOpen = false;
  static const _langs = ['Python', 'Java', 'C', 'C++'];

  static const _code = {
    'Python': '''import heapq
from collections import Counter

class HuffNode:
    def __init__(self, char, freq):
        self.char = char
        self.freq = freq
        self.left = None
        self.right = None
    def __lt__(self, other):
        return self.freq < other.freq

def build_huffman_tree(text):
    freq = Counter(text)
    heap = [HuffNode(c, f)
            for c, f in freq.items()]
    heapq.heapify(heap)

    while len(heap) > 1:
        n1 = heapq.heappop(heap)
        n2 = heapq.heappop(heap)
        merged = HuffNode(None,
                          n1.freq + n2.freq)
        merged.left = n1
        merged.right = n2
        heapq.heappush(heap, merged)

    return heap[0] if heap else None

def get_codes(node, prefix="", codes={}):
    if node is None:
        return
    if node.char is not None:
        codes[node.char] = prefix or "0"
        return
    get_codes(node.left,  prefix+"0", codes)
    get_codes(node.right, prefix+"1", codes)
    return codes

def huffman_encode(text):
    root  = build_huffman_tree(text)
    codes = get_codes(root)
    encoded = "".join(codes[c] for c in text)
    return codes, encoded

# Example
codes, encoded = huffman_encode("aeiousaeiousaeiousaeiust")
for char, code in sorted(codes.items()):
    freq = text.count(char)
    print(f"{char}: freq={freq} code={code}"
          f" bits={freq*len(code)}")
print(f"Encoded: {encoded}")''',

    'Java': '''import java.util.*;

class HuffNode implements Comparable<HuffNode> {
  char ch; int freq;
  HuffNode left, right;
  HuffNode(char c, int f) { ch=c; freq=f; }
  HuffNode(int f, HuffNode l, HuffNode r) {
    freq=f; left=l; right=r;
  }
  public int compareTo(HuffNode o) {
    return freq - o.freq;
  }
}

class Huffman {
  static Map<Character,String> codes
      = new HashMap<>();

  static HuffNode buildTree(String text) {
    Map<Character,Integer> freq = new HashMap<>();
    for (char c : text.toCharArray())
      freq.merge(c, 1, Integer::sum);

    PriorityQueue<HuffNode> pq
        = new PriorityQueue<>();
    for (var e : freq.entrySet())
      pq.add(new HuffNode(e.getKey(),
                          e.getValue()));

    while (pq.size() > 1) {
      HuffNode l = pq.poll();
      HuffNode r = pq.poll();
      pq.add(new HuffNode(
          l.freq+r.freq, l, r));
    }
    return pq.poll();
  }

  static void getCodes(HuffNode n,
                       String prefix) {
    if (n == null) return;
    if (n.left==null && n.right==null) {
      codes.put(n.ch,
          prefix.isEmpty() ? "0" : prefix);
      return;
    }
    getCodes(n.left,  prefix + "0");
    getCodes(n.right, prefix + "1");
  }

  public static void main(String[] args) {
    String text = "aeiousaeiousaeiousaeiust";
    HuffNode root = buildTree(text);
    getCodes(root, "");
    for (var e : codes.entrySet())
      System.out.printf("%c → %s%n",
          e.getKey(), e.getValue());
  }
}''',

    'C': '''#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node {
  char ch;
  int freq;
  struct Node *left, *right;
} Node;

Node* newNode(char c, int f) {
  Node* n = malloc(sizeof(Node));
  n->ch=c; n->freq=f;
  n->left=n->right=NULL;
  return n;
}

// Min-heap (simplified array-based)
Node* heap[256]; int heapSize=0;

void swap(int i, int j) {
  Node* t=heap[i]; heap[i]=heap[j];
  heap[j]=t;
}

void push(Node* n) {
  heap[heapSize++] = n;
  int i = heapSize-1;
  while (i>0) {
    int p=(i-1)/2;
    if (heap[p]->freq > heap[i]->freq) {
      swap(p,i); i=p;
    } else break;
  }
}

Node* pop() {
  Node* top=heap[0];
  heap[0]=heap[--heapSize];
  int i=0;
  while(1){
    int l=2*i+1,r=2*i+2,s=i;
    if(l<heapSize&&heap[l]->freq<heap[s]->freq) s=l;
    if(r<heapSize&&heap[r]->freq<heap[s]->freq) s=r;
    if(s==i) break;
    swap(i,s); i=s;
  }
  return top;
}

void getCodes(Node* n, char* buf,
              int depth) {
  if(!n) return;
  if(!n->left && !n->right) {
    buf[depth]=\'\\0\';
    printf("%c -> %s\\n", n->ch, buf);
    return;
  }
  buf[depth]=\'0\';
  getCodes(n->left, buf, depth+1);
  buf[depth]=\'1\';
  getCodes(n->right, buf, depth+1);
}

int main() {
  char* text = "aeiousaeiousaeiousaeiust";
  int freq[256]={0};
  for(int i=0;text[i];i++) freq[(int)text[i]]++;
  for(int i=0;i<256;i++)
    if(freq[i]) push(newNode(i,freq[i]));
  while(heapSize>1){
    Node* l=pop(); Node* r=pop();
    Node* m=newNode(0,l->freq+r->freq);
    m->left=l; m->right=r; push(m);
  }
  char buf[64];
  getCodes(heap[0], buf, 0);
}''',

    'C++': '''#include <bits/stdc++.h>
using namespace std;

struct HuffNode {
  char ch; int freq;
  HuffNode *left, *right;
  HuffNode(char c,int f,
           HuffNode*l=nullptr,
           HuffNode*r=nullptr)
    :ch(c),freq(f),left(l),right(r){}
};

struct Cmp {
  bool operator()(HuffNode* a,
                  HuffNode* b) {
    return a->freq > b->freq;
  }
};

void getCodes(HuffNode* n, string code,
    map<char,string>& codes){
  if(!n) return;
  if(!n->left && !n->right){
    codes[n->ch] = code.empty()?"0":code;
    return;
  }
  getCodes(n->left, code+"0", codes);
  getCodes(n->right,code+"1", codes);
}

int main(){
  string text =
    "aeiousaeiousaeiousaeiust";
  map<char,int> freq;
  for(char c:text) freq[c]++;

  priority_queue<HuffNode*,
    vector<HuffNode*>,Cmp> pq;
  for(auto&[c,f]:freq)
    pq.push(new HuffNode(c,f));

  while(pq.size()>1){
    auto l=pq.top(); pq.pop();
    auto r=pq.top(); pq.pop();
    pq.push(new HuffNode(
        0, l->freq+r->freq, l, r));
  }

  map<char,string> codes;
  getCodes(pq.top(),"",codes);
  for(auto&[c,code]:codes)
    cout << c <<" -> "<< code << "\\n";
}''',
  };

  static const _keywords = [
    'def', 'class', 'return', 'for', 'if', 'in', 'import', 'from',
    'while', 'not', 'and', 'or', 'None', 'True', 'False', 'self',
    'void', 'int', 'char', 'new', 'else', 'static', 'struct',
    'using', 'namespace', 'public', 'include', 'auto', 'bool',
    'nullptr', 'string', 'map', 'auto', 'typedef', 'malloc', 'free',
  ];

  List<TextSpan> _colorize(String line) {
    final spans = <TextSpan>[];
    final tokenRegex = RegExp(r'([A-Za-z_]\w*|\d+|[^\w\s]|\s+)');
    for (final m in tokenRegex.allMatches(line)) {
      final token = m.group(0)!;
      final t = token.trim();
      Color color;
      if (t.startsWith('#') || t.startsWith('//')) {
        color = const Color(0xFF6B7280);
      } else if (t.startsWith('"') || t.startsWith("'")) {
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
    final code = _code[_lang] ?? '';
    final lines = code.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language dropdown
          GestureDetector(
            onTap: () => setState(() => _langOpen = !_langOpen),
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
                      _langOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF8B949E),
                      size: 16),
                ],
              ),
            ),
          ),
          if (_langOpen)
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
                      setState(() {
                        _lang = l;
                        _langOpen = false;
                      });
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
                                  ? const Color(0xFF9333EA)
                                  : const Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontFamily: 'monospace')),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 10),

          // Code block
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Color(0xFF21262D)))),
                  child: Row(
                    children: [
                      Text('Huffman Coding · $_lang',
                          style: const TextStyle(
                              color: Color(0xFF8B949E),
                              fontSize: 10,
                              fontFamily: 'monospace')),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied!'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Color(0xFF1C2128),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.copy,
                                size: 12, color: Color(0xFF8B949E)),
                            SizedBox(width: 4),
                            Text('Copy',
                                style: TextStyle(
                                    color: Color(0xFF8B949E),
                                    fontSize: 10,
                                    fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(lines.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22,
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 10,
                                        fontFamily: 'monospace')),
                              ),
                              const SizedBox(width: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      height: 1.5),
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
          ),
        ],
      ),
    );
  }
}