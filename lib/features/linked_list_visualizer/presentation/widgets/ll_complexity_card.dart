import 'package:flutter/material.dart';

class LLComplexityCard extends StatelessWidget {
  final String operation;
  final String subOperation;
  const LLComplexityCard({super.key, required this.operation, required this.subOperation});

  static const _data = {
    'insert_head':     {'time':'O(1)','space':'O(1)','best':'O(1)','worst':'O(1)','note':'Inserting at head is O(1) — just update the head pointer. No traversal needed.','steps':['Create new node.','Set new.next = current head.','Update head = new node.']},
    'insert_tail':     {'time':'O(n)','space':'O(1)','best':'O(1)','worst':'O(n)','note':'Inserting at tail requires traversal to the last node — O(n). O(1) with a tail pointer.','steps':['Create new node.','Traverse using pred until pred.next == null.','Set pred.next = new node.']},
    'insert_position': {'time':'O(n)','space':'O(1)','best':'O(1)','worst':'O(n)','note':'Must traverse to position i-1 (pred). Best case O(1) when inserting at head.','steps':['Create new node.','Traverse to predecessor at index i-1.','Set new.next = pred.next.','Set pred.next = new node.']},
    'delete_head':     {'time':'O(1)','space':'O(1)','best':'O(1)','worst':'O(1)','note':'Deleting head is O(1) — just move the head pointer forward. No traversal.','steps':['Save head as temp.','Move head = head.next.','Free/detach temp.']},
    'delete_tail':     {'time':'O(n)','space':'O(1)','best':'O(1)','worst':'O(n)','note':'Must traverse to second-last node. O(1) with a doubly linked list and tail pointer.','steps':['Traverse with pred + temp until temp.next == null.','Set pred.next = null.','Free temp (old tail).']},
    'delete_position': {'time':'O(n)','space':'O(1)','best':'O(1)','worst':'O(n)','note':'Traverse to index i-1. Best O(1) for head deletion. Pred.next bypasses target.','steps':['Traverse to predecessor (index i-1).','Save pred.next as temp.','Set pred.next = temp.next.','Free/detach temp.']},
    'search_any':      {'time':'O(n)','space':'O(1)','best':'O(1)','worst':'O(n)','note':'Linear search — must scan each node sequentially. Best O(1) when target is at head.','steps':['Set tmp = head, index = 0.','Compare tmp.data with target value.','If match: return index (FOUND).','Else: tmp = tmp.next, index++.','If tmp == null: return -1 (NOT FOUND).']},
  };

  String get _key => operation == 'search' ? 'search_any' : '${operation}_$subOperation';

  @override
  Widget build(BuildContext context) {
    final info = _data[_key] ?? _data['search_any']!;
    final cells = [
      {'label': 'Time (Avg)', 'val': info['time'] as String, 'color': 0xFF3B82F6},
      {'label': 'Space',      'val': info['space'] as String,'color': 0xFF8B5CF6},
      {'label': 'Best Case',  'val': info['best'] as String, 'color': 0xFF22C55E},
      {'label': 'Worst Case', 'val': info['worst'] as String,'color': 0xFFEF4444},
    ];
    final steps = info['steps'] as List<String>;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(children: [
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.4,
          children: cells.map((c) {
            final color = Color(c['color'] as int);
            return Container(
              decoration: BoxDecoration(color: const Color(0xFF161B22), border: Border.all(color: const Color(0xFF21262D)), borderRadius: BorderRadius.circular(10)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(c['label'].toString(), style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11, fontFamily: 'monospace')),
                const SizedBox(height: 4),
                Text(c['val'].toString(), style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
              ]),
            );
          }).toList()),
        const SizedBox(height: 10),
        Container(width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF161B22), border: Border.all(color: const Color(0xFF21262D)), borderRadius: BorderRadius.circular(10)),
          child: Text(info['note'] as String, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace', height: 1.6))),
        const SizedBox(height: 10),
        Container(width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF161B22), border: Border.all(color: const Color(0xFF21262D)), borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Algorithm Steps:', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
            const SizedBox(height: 8),
            ...steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 18, height: 18,
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.15), shape: BoxShape.circle),
                  child: Center(child: Text('${e.key+1}', style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 9, fontWeight: FontWeight.w800, fontFamily: 'monospace')))),
                const SizedBox(width: 8),
                Expanded(child: Text(e.value, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace', height: 1.5))),
              ]),
            )),
          ])),
      ]),
    );
  }
}