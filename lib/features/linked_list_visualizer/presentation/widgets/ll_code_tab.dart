import 'package:flutter/material.dart';

class LLCodeTab extends StatefulWidget {
  final String operation;
  final String subOperation;
  final void Function(String language)? onLanguageChanged;
  const LLCodeTab({super.key, required this.operation, required this.subOperation, this.onLanguageChanged});
  @override
  State<LLCodeTab> createState() => _LLCodeTabState();
}

class _LLCodeTabState extends State<LLCodeTab> {
  String _lang = 'Python';
  bool _open = false;
  static const _langs = ['Python', 'Java', 'C', 'C++'];

  static const Map<String, Map<String, Map<String, String>>> _snippets = {
    'insert': {
      'head': {
        'Python': 'class Node:\n    def __init__(self, data):\n        self.data = data\n        self.next = None\n\ndef insert_at_head(head, data):\n    new_node = Node(data)   # create new node\n    new_node.next = head    # new.next = head\n    head = new_node         # update head\n    return head',
        'Java': 'void insertAtHead(int data) {\n    Node newNode = new Node(data);\n    newNode.next = head;  // point to old head\n    head = newNode;       // update head\n}',
        'C': 'void insertAtHead(Node** head, int data) {\n    Node* n = malloc(sizeof(Node));\n    n->data = data;\n    n->next = *head;   // point to old head\n    *head = n;         // update head\n}',
        'C++': 'void insertAtHead(Node*& head, int data) {\n    Node* n = new Node(data);\n    n->next = head;   // point to old head\n    head = n;         // update head\n}',
      },
      'tail': {
        'Python': 'def insert_at_tail(head, data):\n    new_node = Node(data)\n    if head is None:\n        return new_node\n    pred = head\n    while pred.next is not None:\n        pred = pred.next    # traverse to tail\n    pred.next = new_node    # link new node\n    return head',
        'Java': 'void insertAtTail(int data) {\n    Node newNode = new Node(data);\n    if (head == null) { head = newNode; return; }\n    Node pred = head;\n    while (pred.next != null)\n        pred = pred.next;   // traverse\n    pred.next = newNode;\n}',
        'C': 'void insertAtTail(Node** head, int data) {\n    Node* n = malloc(sizeof(Node));\n    n->data = data; n->next = NULL;\n    if (!*head) { *head = n; return; }\n    Node* pred = *head;\n    while (pred->next) pred = pred->next;\n    pred->next = n;\n}',
        'C++': 'void insertAtTail(Node*& head, int data) {\n    Node* n = new Node(data);\n    if (!head) { head = n; return; }\n    Node* pred = head;\n    while (pred->next)\n        pred = pred->next;  // traverse\n    pred->next = n;\n}',
      },
      'position': {
        'Python': 'def insert_at_pos(head, data, pos):\n    if pos == 0:\n        return insert_at_head(head, data)\n    new_node = Node(data)\n    pred = head\n    for _ in range(pos - 1):\n        if pred is None: break\n        pred = pred.next    # traverse to pred\n    if pred is None: return head\n    new_node.next = pred.next  # new.next = succ\n    pred.next = new_node       # pred.next = new\n    return head',
        'Java': 'void insertAtPos(int data, int pos) {\n    if (pos == 0) { insertAtHead(data); return; }\n    Node newNode = new Node(data);\n    Node pred = head;\n    for (int i=0; i<pos-1 && pred!=null; i++)\n        pred = pred.next;\n    if (pred == null) return;\n    newNode.next = pred.next;  // link successor\n    pred.next = newNode;\n}',
        'C': 'void insertAtPos(Node** head, int data, int pos) {\n    if (pos==0) { insertAtHead(head,data); return; }\n    Node* n = malloc(sizeof(Node));\n    n->data = data;\n    Node* pred = *head;\n    for (int i=0; i<pos-1 && pred; i++)\n        pred = pred->next;\n    if (!pred) return;\n    n->next = pred->next;\n    pred->next = n;\n}',
        'C++': 'void insertAtPos(Node*& head, int data, int pos) {\n    if (pos==0) { insertAtHead(head,data); return; }\n    Node* n = new Node(data);\n    Node* pred = head;\n    for (int i=0; i<pos-1 && pred; i++)\n        pred = pred->next;\n    if (!pred) return;\n    n->next = pred->next;  // link successor\n    pred->next = n;\n}',
      },
    },
    'delete': {
      'head': {
        'Python': 'def delete_head(head):\n    if head is None:\n        return None\n    temp = head          # save reference\n    head = head.next     # move head forward\n    temp.next = None     # detach\n    return head',
        'Java': 'void deleteHead() {\n    if (head == null) return;\n    Node temp = head;\n    head = head.next;   // move head forward\n    temp.next = null;   // detach\n}',
        'C': 'void deleteHead(Node** head) {\n    if (!*head) return;\n    Node* temp = *head;\n    *head = (*head)->next;\n    free(temp);\n}',
        'C++': 'void deleteHead(Node*& head) {\n    if (!head) return;\n    Node* temp = head;\n    head = head->next;  // move head forward\n    delete temp;\n}',
      },
      'tail': {
        'Python': 'def delete_tail(head):\n    if head is None: return None\n    if head.next is None: return None\n    pred = head\n    temp = head.next\n    while temp.next is not None:\n        pred = temp          # pred follows temp\n        temp = temp.next\n    pred.next = None         # unlink tail\n    return head',
        'Java': 'void deleteTail() {\n    if (head==null) return;\n    if (head.next==null) { head=null; return; }\n    Node pred=head, temp=head.next;\n    while (temp.next != null) {\n        pred=temp; temp=temp.next;\n    }\n    pred.next = null;  // unlink tail\n}',
        'C': 'void deleteTail(Node** head) {\n    if (!*head) return;\n    if (!(*head)->next) { free(*head); *head=NULL; return; }\n    Node* pred=*head, *temp=(*head)->next;\n    while (temp->next) { pred=temp; temp=temp->next; }\n    pred->next = NULL;\n    free(temp);\n}',
        'C++': 'void deleteTail(Node*& head) {\n    if (!head) return;\n    if (!head->next) { delete head; head=nullptr; return; }\n    Node* pred=head, *temp=head->next;\n    while (temp->next) { pred=temp; temp=temp->next; }\n    pred->next = nullptr;  // unlink\n    delete temp;\n}',
      },
      'position': {
        'Python': 'def delete_at_pos(head, pos):\n    if head is None: return None\n    if pos == 0: return delete_head(head)\n    pred = head\n    for _ in range(pos - 1):\n        if pred.next is None: return head\n        pred = pred.next\n    temp = pred.next       # node to delete\n    if temp is None: return head\n    pred.next = temp.next  # bypass temp\n    temp.next = None\n    return head',
        'Java': 'void deleteAtPos(int pos) {\n    if (head==null) return;\n    if (pos==0) { deleteHead(); return; }\n    Node pred = head;\n    for (int i=0; i<pos-1 && pred.next!=null; i++)\n        pred = pred.next;\n    Node temp = pred.next;\n    if (temp == null) return;\n    pred.next = temp.next;  // bypass\n    temp.next = null;\n}',
        'C': 'void deleteAtPos(Node** head, int pos) {\n    if (!*head) return;\n    if (pos==0) { deleteHead(head); return; }\n    Node* pred = *head;\n    for (int i=0; i<pos-1 && pred->next; i++)\n        pred = pred->next;\n    Node* temp = pred->next;\n    if (!temp) return;\n    pred->next = temp->next;\n    free(temp);\n}',
        'C++': 'void deleteAtPos(Node*& head, int pos) {\n    if (!head) return;\n    if (pos==0) { deleteHead(head); return; }\n    Node* pred = head;\n    for (int i=0; i<pos-1 && pred->next; i++)\n        pred = pred->next;\n    Node* temp = pred->next;\n    if (!temp) return;\n    pred->next = temp->next;  // bypass\n    delete temp;\n}',
      },
    },
    'search': {
      'any': {
        'Python': 'def search(head, value):\n    tmp = head\n    index = 0\n    while tmp is not None:\n        if tmp.data == value:\n            return index      # found!\n        tmp = tmp.next\n        index += 1\n    return -1                 # not found',
        'Java': 'int search(int value) {\n    Node tmp = head;\n    int index = 0;\n    while (tmp != null) {\n        if (tmp.data == value)\n            return index;  // found!\n        tmp = tmp.next;\n        index++;\n    }\n    return -1;  // not found\n}',
        'C': 'int search(Node* head, int value) {\n    Node* tmp = head;\n    int index = 0;\n    while (tmp != NULL) {\n        if (tmp->data == value)\n            return index;\n        tmp = tmp->next;\n        index++;\n    }\n    return -1;\n}',
        'C++': 'int search(Node* head, int value) {\n    Node* tmp = head;\n    int index = 0;\n    while (tmp) {\n        if (tmp->data == value)\n            return index;  // found!\n        tmp = tmp->next;\n        index++;\n    }\n    return -1;  // not found\n}',
      },
    },
  };

  static const _kws = ['def','class','return','if','else','elif','while','for','in','range','None','True','False','not','void','int','struct','Node','null','nullptr','NULL','new','delete','free','malloc','sizeof','self','head','next','data','temp','pred','tmp'];

  List<TextSpan> _colorize(String line) {
    final t = line.trimLeft();
    if (t.startsWith('#') || t.startsWith('//')) return [TextSpan(text: line, style: const TextStyle(color: Color(0xFF6B7280)))];
    final spans = <TextSpan>[];
    for (final m in RegExp(r'([A-Za-z_]\w*|\d+|[^\w\s]|\s+)').allMatches(line)) {
      final tok = m.group(0)!;
      final tr = tok.trim();
      Color c = _kws.contains(tr) ? const Color(0xFFC084FC) : RegExp(r'^\d+$').hasMatch(tr) ? const Color(0xFFFB923C) : const Color(0xFFE2E8F0);
      spans.add(TextSpan(text: tok, style: TextStyle(color: c)));
    }
    return spans;
  }

  String get _key => widget.operation == 'search' ? 'any' : widget.subOperation;

  @override
  Widget build(BuildContext context) {
    final code = _snippets[widget.operation]?[_key]?[_lang] ?? _snippets[widget.operation]?['any']?[_lang] ?? '// Not available';
    final lines = code.split('\n');
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(color: const Color(0xFF161B22), border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(Icons.code, color: Color(0xFF3B82F6), size: 14),
                const SizedBox(width: 6),
                Text(_lang, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
              ]),
              Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF8B949E), size: 16),
            ]),
          ),
        ),
        if (_open) Container(
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: const Color(0xFF1C2128), border: Border.all(color: const Color(0xFF30363D)), borderRadius: BorderRadius.circular(8)),
          child: Column(children: _langs.map((l) {
            final sel = l == _lang;
            return GestureDetector(
              onTap: () { setState(() { _lang = l; _open = false; }); widget.onLanguageChanged?.call(l); },
              child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                color: sel ? const Color(0xFF21262D) : Colors.transparent,
                child: Text(l, style: TextStyle(color: sel ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), fontSize: 13, fontFamily: 'monospace', fontWeight: sel ? FontWeight.w700 : FontWeight.normal))),
            );
          }).toList()),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF161B22), border: Border.all(color: const Color(0xFF21262D)), borderRadius: BorderRadius.circular(10)),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lines.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 24, child: Text('${i+1}', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontFamily: 'monospace'))),
                  const SizedBox(width: 6),
                  RichText(text: TextSpan(style: const TextStyle(fontSize: 11, fontFamily: 'monospace', height: 1.6), children: _colorize(lines[i]))),
                ]),
              )),
            ),
          ),
        ),
      ]),
    );
  }
}