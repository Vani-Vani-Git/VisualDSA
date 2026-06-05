// interview_question_pages.dart
// Place at: features/home/presentation/pages/interview_question_pages.dart

import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────

class InterviewQuestionCard {
  final String questionTitle;   // shown on front of card
  final String approach;        // how to solve it
  final String dsaPattern;      // which DSA pattern fits
  final String timeComplexity;
  final String spaceComplexity;
  final String keyInsight;      // one-line trick/insight

  const InterviewQuestionCard({
    required this.questionTitle,
    required this.approach,
    required this.dsaPattern,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.keyInsight,
  });
}

class InterviewPageData {
  final String title;
  final Color accentColor;
  final IconData icon;
  final String difficulty;
  final Color difficultyColor;
  final List<InterviewQuestionCard> questions;

  const InterviewPageData({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.difficulty,
    required this.difficultyColor,
    required this.questions,
  });
}

// ─────────────────────────────────────────────
//  GLITTER PAINTER
// ─────────────────────────────────────────────

class _GlitterPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<Offset> _dots;

  _GlitterPainter({required this.progress, required this.color})
      : _dots = List.generate(28, (i) {
          final rng = Random(i * 7 + 13);
          return Offset(rng.nextDouble(), rng.nextDouble());
        });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < _dots.length; i++) {
      final phase = (progress + i / _dots.length) % 1.0;
      final opacity = (sin(phase * pi * 2) * 0.5 + 0.5);
      paint.color = color.withOpacity(opacity * 0.85);
      final sparkSize = 1.5 + sin(phase * pi) * 2.5;
      canvas.drawCircle(
        Offset(_dots[i].dx * size.width, _dots[i].dy * size.height),
        sparkSize,
        paint,
      );
    }
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        startAngle: progress * pi * 2,
        endAngle: progress * pi * 2 + pi,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.9),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(20)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_GlitterPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  INTERVIEW FLIP CARD WIDGET
// ─────────────────────────────────────────────

class _InterviewFlipCard extends StatefulWidget {
  final InterviewQuestionCard data;
  final Color accentColor;
  final int index;

  const _InterviewFlipCard({
    required this.data,
    required this.accentColor,
    required this.index,
  });

  @override
  State<_InterviewFlipCard> createState() => _InterviewFlipCardState();
}

class _InterviewFlipCardState extends State<_InterviewFlipCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _glitterController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _glitterController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glitterController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _glitterController]),
        builder: (context, _) {
          final angle = _flipAnimation.value * pi;
          final isFront = angle <= pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 200),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.accentColor.withOpacity(0.25)),
              ),
              child: Stack(
                children: [
                  // Glitter overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: _GlitterPainter(
                          progress: _glitterController.value,
                          color: widget.accentColor,
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(isFront ? 0 : pi),
                    child: isFront
                        ? _FrontFace(
                            data: widget.data,
                            accentColor: widget.accentColor,
                            index: widget.index,
                          )
                        : _BackFace(
                            data: widget.data,
                            accentColor: widget.accentColor,
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FRONT FACE
// ─────────────────────────────────────────────

class _FrontFace extends StatelessWidget {
  final InterviewQuestionCard data;
  final Color accentColor;
  final int index;

  const _FrontFace(
      {required this.data, required this.accentColor, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.touch_app_rounded,
                  size: 16, color: accentColor.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                'Tap to reveal',
                style: TextStyle(
                    fontSize: 11, color: accentColor.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.questionTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _PillTag(label: data.dsaPattern, color: accentColor),
              const SizedBox(width: 8),
              _PillTag(label: data.timeComplexity, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BACK FACE
// ─────────────────────────────────────────────

class _BackFace extends StatelessWidget {
  final InterviewQuestionCard data;
  final Color accentColor;

  const _BackFace({required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section: Approach
          _BackSection(
            icon: Icons.route_rounded,
            label: 'Approach',
            content: data.approach,
            accentColor: accentColor,
          ),
          const SizedBox(height: 14),

          // Section: DSA Pattern
          _BackSection(
            icon: Icons.pattern_rounded,
            label: 'DSA Pattern',
            content: data.dsaPattern,
            accentColor: accentColor,
          ),
          const SizedBox(height: 14),

          // Section: Key Insight
          _BackSection(
            icon: Icons.lightbulb_rounded,
            label: 'Key Insight',
            content: data.keyInsight,
            accentColor: Colors.amber,
          ),
          const SizedBox(height: 14),

          // Complexities row
          Row(
            children: [
              Expanded(
                child: _ComplexityChip(
                  label: 'Time',
                  value: data.timeComplexity,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ComplexityChip(
                  label: 'Space',
                  value: data.spaceComplexity,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String content;
  final Color accentColor;

  const _BackSection({
    required this.icon,
    required this.label,
    required this.content,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: accentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade300, height: 1.5),
        ),
      ],
    );
  }
}

class _ComplexityChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ComplexityChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  final String label;
  final Color color;

  const _PillTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color == Colors.grey ? Colors.grey.shade400 : color,
              fontWeight: FontWeight.w500)),
    );
  }
}

// ─────────────────────────────────────────────
//  INTERVIEW DETAIL PAGE TEMPLATE
// ─────────────────────────────────────────────

class DSAInterviewPage extends StatelessWidget {
  final InterviewPageData data;

  const DSAInterviewPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: CustomScrollView(
        slivers: [
          // Hero AppBar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF0D1117),
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: data.difficultyColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.difficulty,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: data.difficultyColor),
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.accentColor.withOpacity(0.25),
                      const Color(0xFF0D1117),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(data.icon,
                      size: 64,
                      color: data.accentColor.withOpacity(0.2)),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header info
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                          color: data.accentColor,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '💼 Interview Questions',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    'Tap each card to reveal approach, pattern & complexity',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 20),

                // Cards — one per question, full width
                ...data.questions.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _InterviewFlipCard(
                      data: entry.value,
                      accentColor: data.accentColor,
                      index: entry.key,
                    ),
                  );
                }),

                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  1. ARRAY
// ══════════════════════════════════════════════

class ArrayInterviewPage extends StatelessWidget {
  const ArrayInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Array',
        accentColor: Colors.blue,
        icon: Icons.grid_view_rounded,
        difficulty: 'Easy',
        difficultyColor: Colors.green,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Find two numbers that sum to a target (Two Sum)',
            approach: 'Use a HashMap to store each number and its index as you iterate. For each element, check if (target - current) already exists in the map. If yes, return both indices.',
            dsaPattern: 'Hash Map / Complement Lookup',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Store complement → index. One pass is enough — no need to sort.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Rotate an array by K positions',
            approach: 'Use the reverse trick: (1) reverse the entire array, (2) reverse first k elements, (3) reverse the remaining n-k elements. Handle k > n with k = k % n.',
            dsaPattern: 'Reversal / In-place Manipulation',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Three reversals give rotation in-place. Always normalize k = k % n first.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find maximum subarray sum (Kadane\'s Algorithm)',
            approach: 'Track currentMax and globalMax. At each element, decide: extend the current subarray or start fresh. currentMax = max(num, currentMax + num). Update globalMax if currentMax is larger.',
            dsaPattern: 'Dynamic Programming / Greedy (Kadane\'s)',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'If extending the subarray makes it smaller than starting fresh, restart. Never carry a negative prefix.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Move all zeros to end (without changing non-zero order)',
            approach: 'Use two pointers: a write pointer starts at 0. Iterate through array — whenever a non-zero is found, place it at write pointer index and increment. Fill remaining positions with zeros.',
            dsaPattern: 'Two Pointers / Partition',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Write pointer tracks where to place the next non-zero. Non-zero elements naturally maintain relative order.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find the missing number in 1 to N',
            approach: 'Use the mathematical sum formula: expected = n*(n+1)/2. Subtract actual sum of array elements. The difference is the missing number. Alternatively, use XOR of 1..n XOR all array elements.',
            dsaPattern: 'Math Formula / XOR Bit Trick',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'XOR approach avoids integer overflow for large n. a XOR a = 0, so duplicates cancel out.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Best time to buy and sell stock (one transaction)',
            approach: 'Track the minimum price seen so far as you iterate. At each day, compute profit = price - minSoFar and update maxProfit. Single pass, no need to check all pairs.',
            dsaPattern: 'Greedy / Running Min',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'You want the largest drop between any two indices (i < j). Track running minimum to find it in one pass.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find duplicate number in array of 1 to N (Floyd\'s)',
            approach: 'Treat array values as pointers (like a linked list). Use Floyd\'s cycle detection: slow moves 1 step, fast moves 2 steps. When they meet, reset slow to start, advance both 1 step until they meet again — that is the duplicate.',
            dsaPattern: 'Floyd\'s Cycle Detection / Linked List Analogy',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Values are indices — the duplicate creates a cycle entry point, which Floyd\'s finds exactly.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Merge two sorted arrays without extra space',
            approach: 'Use gap method (Shell sort variant): start with gap = ceil((m+n)/2), compare elements gap apart and swap if out of order. Reduce gap by half each round until gap = 1.',
            dsaPattern: 'Gap Method / Shell Sort Variant',
            timeComplexity: 'O((m+n) log(m+n))',
            spaceComplexity: 'O(1)',
            keyInsight: 'Simpler O(m+n) approach uses extra array. Gap method achieves in-place at the cost of O(log n) passes.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find intersection of two arrays',
            approach: 'Use a HashSet for the first array. Iterate through the second array and add elements found in the set to the result. To handle duplicates, remove from set after adding to result.',
            dsaPattern: 'Hash Set / Set Operations',
            timeComplexity: 'O(m+n)',
            spaceComplexity: 'O(min(m,n))',
            keyInsight: 'For sorted arrays, two-pointer approach gives O(m+n) time with O(1) space — no hashing needed.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Longest consecutive sequence in unsorted array',
            approach: 'Insert all elements into a HashSet. For each element, check if (element - 1) is NOT in set (it\'s a sequence start). If so, keep incrementing count while (element + count) exists in set. Track max count.',
            dsaPattern: 'Hash Set / Sequence Starting Point',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Only start counting from sequence starts (no left neighbor). Each element is counted at most twice total.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  2. SORTING
// ══════════════════════════════════════════════

class SortingInterviewPage extends StatelessWidget {
  const SortingInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Sorting',
        accentColor: Colors.purple,
        icon: Icons.sort_rounded,
        difficulty: 'Medium',
        difficultyColor: Colors.orange,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Sort Colors — Dutch National Flag Problem (0s, 1s, 2s)',
            approach: 'Three pointers: low=0, mid=0, high=n-1. If arr[mid]==0, swap with arr[low], advance both. If arr[mid]==1, advance mid. If arr[mid]==2, swap with arr[high], decrease high (don\'t advance mid — new element unchecked).',
            dsaPattern: 'Dutch National Flag / Three-Pointer Partition',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'When swapping with high, mid stays — the swapped element from high is unknown and must be re-examined.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Merge overlapping intervals',
            approach: 'Sort intervals by start time. Iterate: if current interval\'s start <= last merged interval\'s end, merge by updating end to max(both ends). Otherwise, push current interval as new merged interval.',
            dsaPattern: 'Sorting + Greedy Merge',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'After sorting by start, only adjacent intervals can overlap. Always track the last merged interval\'s end.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find Kth largest element in array',
            approach: 'Use QuickSelect (partition-based): partition array around a random pivot. If pivot index == k-1 from right, found. If pivot index < k-1, recurse right. Else recurse left. Average O(n) without full sort.',
            dsaPattern: 'QuickSelect / Partition (Lomuto/Hoare)',
            timeComplexity: 'O(n) average, O(n²) worst',
            spaceComplexity: 'O(1)',
            keyInsight: 'Min-Heap of size k gives O(n log k) guaranteed. QuickSelect is faster on average but has worst case.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Count inversions in array (pairs where i<j but arr[i]>arr[j])',
            approach: 'Modify Merge Sort: during the merge step, when an element from the right half is placed before elements in the left half, those left-half elements form inversions. Count mid - left_pointer inversions at each such placement.',
            dsaPattern: 'Modified Merge Sort / Divide and Conquer',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Brute force is O(n²). Merge sort counts inversions for free during the merge step — left elements not yet placed are all > right element placed.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Sort array of strings by frequency then lexicographically',
            approach: 'Build frequency map. Sort strings using custom comparator: primary sort by frequency descending, secondary sort by lexicographic order ascending for tie-breaking.',
            dsaPattern: 'Custom Comparator Sort / HashMap',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Custom comparator must handle both conditions in one comparison function. Stability matters for tie-breaking.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Minimum number of platforms required at railway station',
            approach: 'Separate arrivals and departures into two sorted arrays. Use two pointers: if next arrival < next departure, need new platform (count++). Else one platform freed (count--). Track max platforms simultaneously.',
            dsaPattern: 'Sorting + Two Pointers (Activity Selection)',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'This is the meeting rooms overlap problem. Sort both arrays independently — you only care about simultaneous events.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Largest number formed by concatenating array numbers',
            approach: 'Custom sort: compare two numbers a and b by comparing (str(a)+str(b)) vs (str(b)+str(a)). The concatenation that forms a larger number comes first. Join sorted result. Handle edge case: if largest element is 0, return "0".',
            dsaPattern: 'Custom Sort Comparator / String Comparison',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Direct number comparison fails — "3" vs "30" needs "330" > "303" check. String concatenation comparison handles this naturally.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find median of two sorted arrays',
            approach: 'Binary search on the smaller array. Partition both arrays so left halves combined have (m+n)/2 elements. Check if partition is valid (max of left parts ≤ min of right parts). Adjust binary search based on validity.',
            dsaPattern: 'Binary Search on Partition',
            timeComplexity: 'O(log(min(m,n)))',
            spaceComplexity: 'O(1)',
            keyInsight: 'You\'re searching for the right partition, not a value. Always binary search on the smaller array for efficiency.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  3. SEARCHING
// ══════════════════════════════════════════════

class SearchingInterviewPage extends StatelessWidget {
  const SearchingInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Searching',
        accentColor: Colors.green,
        icon: Icons.search_rounded,
        difficulty: 'Easy',
        difficultyColor: Colors.green,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Binary search on a rotated sorted array',
            approach: 'Find which half is sorted: if arr[mid] >= arr[left], left half is sorted. Check if target lies in sorted half — if yes, search there; else search other half. Repeat until found or lo > hi.',
            dsaPattern: 'Modified Binary Search',
            timeComplexity: 'O(log n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'In a rotated array, one half is always sorted. Use that half to decide which side to recurse into.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find first and last position of target in sorted array',
            approach: 'Run binary search twice: once to find the leftmost occurrence (when found, continue searching left: hi = mid - 1), once for rightmost (continue searching right: lo = mid + 1). Return [-1,-1] if not found.',
            dsaPattern: 'Binary Search (Lower/Upper Bound)',
            timeComplexity: 'O(log n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Two independent binary searches. Don\'t stop on first match — continue in the respective direction to find the boundary.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Search a 2D matrix (sorted row-wise and column-wise)',
            approach: 'Start at top-right corner. If current == target, found. If current > target, move left (eliminate column). If current < target, move down (eliminate row). Continue until out of bounds.',
            dsaPattern: 'Staircase Search / Elimination',
            timeComplexity: 'O(m+n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Top-right is unique: it\'s the largest in its row and smallest in its column — so one comparison eliminates an entire row or column.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find square root of a number (integer part) without sqrt()',
            approach: 'Binary search on answer space [1, n]. If mid*mid == n return mid. If mid*mid < n, this could be the answer — save it and search right. If mid*mid > n, search left.',
            dsaPattern: 'Binary Search on Answer',
            timeComplexity: 'O(log n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Binary search on answer space, not array index. Searching for the largest x where x² ≤ n.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find peak element (greater than both neighbors)',
            approach: 'Binary search: if arr[mid] > arr[mid+1], peak is in left half (including mid). Else peak is in right half. Repeat until lo == hi — that\'s a peak.',
            dsaPattern: 'Binary Search on Peak / Ternary Search',
            timeComplexity: 'O(log n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Moving toward the higher neighbor always leads to a peak — guaranteed. Any local maximum qualifies.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find minimum in a rotated sorted array',
            approach: 'Binary search: if arr[mid] > arr[right], minimum is in right half (mid+1 to right). Else minimum is in left half (left to mid). When lo == hi, that\'s the minimum.',
            dsaPattern: 'Modified Binary Search',
            timeComplexity: 'O(log n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'The minimum is at the rotation point. Compare mid with right (not left) to determine which half contains the drop.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Count occurrences of element in sorted array',
            approach: 'Use binary search to find first and last occurrence. Count = lastIndex - firstIndex + 1. If element not found, return 0.',
            dsaPattern: 'Binary Search (Lower/Upper Bound)',
            timeComplexity: 'O(log n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'upperBound(x) - lowerBound(x) gives count. Two binary searches, both O(log n).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find K closest elements to target in sorted array',
            approach: 'Binary search to find the closest element position. Use two pointers expanding outward from that position: compare distances of left and right candidates, always pick the closer one (tie goes left).',
            dsaPattern: 'Binary Search + Two Pointers Expansion',
            timeComplexity: 'O(log n + k)',
            spaceComplexity: 'O(1)',
            keyInsight: 'After finding insertion point, two pointers expand to pick k closest. No need to sort distances.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  4. GRAPH
// ══════════════════════════════════════════════

class GraphInterviewPage extends StatelessWidget {
  const GraphInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Graph',
        accentColor: Colors.orange,
        icon: Icons.hub_rounded,
        difficulty: 'Hard',
        difficultyColor: Colors.red,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Detect cycle in directed graph',
            approach: 'DFS with two boolean arrays: visited[] and inStack[] (current DFS path). Mark node in inStack when entering DFS, unmark when backtracking. If DFS visits a node already in inStack, cycle detected.',
            dsaPattern: 'DFS + Recursion Stack',
            timeComplexity: 'O(V+E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'visited[] avoids re-visiting. inStack[] tracks current path — a back edge (to inStack node) means cycle. Undirected cycle detection only needs visited[].',
          ),
          InterviewQuestionCard(
            questionTitle: 'Number of islands (count connected components of 1s)',
            approach: 'For each unvisited cell with value 1, run DFS/BFS to mark all connected 1s as visited (change to 0 or use visited array). Each DFS call = one island. Count total DFS initiations.',
            dsaPattern: 'DFS/BFS Flood Fill',
            timeComplexity: 'O(m×n)',
            spaceComplexity: 'O(m×n)',
            keyInsight: 'Treat the 2D grid as a graph. Connected 1s (4-directionally) form one island. Flood-filling marks the entire component.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Clone a graph (deep copy)',
            approach: 'Use a HashMap<Node, Node> mapping original node to its clone. DFS/BFS from the source. For each neighbor: if already cloned (in map), use existing clone; otherwise create new clone node and recurse.',
            dsaPattern: 'DFS/BFS + HashMap for visited clones',
            timeComplexity: 'O(V+E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'HashMap serves dual purpose: tracking visited nodes AND mapping originals to clones. Without it, you\'d create infinite loops on cycles.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Course Schedule — can all courses be completed? (Cycle in DAG)',
            approach: 'Build directed graph from prerequisites. Run topological sort (Kahn\'s BFS with in-degree): if all nodes are processed (count == numCourses), no cycle — schedule possible. If count < numCourses, cycle exists.',
            dsaPattern: 'Topological Sort / Cycle Detection (Kahn\'s)',
            timeComplexity: 'O(V+E)',
            spaceComplexity: 'O(V+E)',
            keyInsight: 'If topological sort processes all nodes, no cycle. If stuck early (no zero in-degree nodes left), circular dependency exists.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Bipartite graph check (two-colorable)',
            approach: 'BFS/DFS with 2-coloring: assign color 0 to start. For each neighbor, assign opposite color. If a neighbor already has the same color as current node — not bipartite. Check all components.',
            dsaPattern: 'BFS/DFS Graph Coloring',
            timeComplexity: 'O(V+E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'Graph is bipartite iff it has no odd-length cycles. 2-coloring detects this automatically — same color conflict means odd cycle.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Word Ladder — shortest transformation sequence',
            approach: 'BFS from beginWord. At each step, try all possible single-character changes. If the new word is in wordList and not visited, add to queue. BFS guarantees shortest path. Level = transformation count.',
            dsaPattern: 'BFS on Implicit Graph',
            timeComplexity: 'O(M² × N) where M=word length, N=dict size',
            spaceComplexity: 'O(M² × N)',
            keyInsight: 'BFS gives shortest path in unweighted graph. The graph is implicit — nodes are words, edges are single-char differences. Use HashSet for O(1) lookup.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Rotten Oranges — minimum minutes to rot all',
            approach: 'Multi-source BFS: enqueue all initially rotten oranges. BFS spreads rot to fresh neighbors level by level (each level = 1 minute). Count levels. After BFS, if fresh oranges remain, return -1.',
            dsaPattern: 'Multi-Source BFS',
            timeComplexity: 'O(m×n)',
            spaceComplexity: 'O(m×n)',
            keyInsight: 'Start BFS from ALL rotten oranges simultaneously. Each BFS level = 1 minute. This is the classic "0-1 BFS" or multi-source shortest distance pattern.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find all paths from source to target in DAG',
            approach: 'DFS with backtracking: maintain current path. At each node, add to path and recurse to all neighbors. When target is reached, save copy of current path. Backtrack by removing last node from path.',
            dsaPattern: 'DFS + Backtracking',
            timeComplexity: 'O(2^V × V)',
            spaceComplexity: 'O(V)',
            keyInsight: 'Backtracking undoes path choices — same pattern as subset/permutation problems. Copy path when target is reached, not reference.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  5. GRAPH TRAVERSAL
// ══════════════════════════════════════════════

class GraphTraversalInterviewPage extends StatelessWidget {
  const GraphTraversalInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Graph Traversal',
        accentColor: Colors.teal,
        icon: Icons.account_tree_rounded,
        difficulty: 'Medium',
        difficultyColor: Colors.orange,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'BFS — Shortest path in unweighted graph',
            approach: 'Standard BFS from source with a distance[] array initialized to -1. When dequeuing a node, update distance of its unvisited neighbors as distance[current]+1 and enqueue them. Continue until target reached or queue empty.',
            dsaPattern: 'BFS / Level-Order Shortest Path',
            timeComplexity: 'O(V+E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'BFS visits nodes in order of distance from source. First visit is always the shortest path — no revisiting needed.',
          ),
          InterviewQuestionCard(
            questionTitle: 'DFS — Detect cycle in undirected graph',
            approach: 'DFS with parent tracking: when visiting neighbors, skip the parent node. If a visited non-parent neighbor is found, cycle detected. Use visited[] to avoid re-processing.',
            dsaPattern: 'DFS with Parent Tracking',
            timeComplexity: 'O(V+E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'In undirected graphs, every edge is visited twice (from both endpoints). Parent tracking avoids false cycle detection from the back-edge to parent.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Topological Sort — Task scheduling order',
            approach: 'Kahn\'s Algorithm: compute in-degree for all nodes. Enqueue nodes with in-degree 0. For each dequeued node, reduce in-degree of its neighbors. Enqueue neighbors whose in-degree becomes 0. Order of dequeue = topological sort.',
            dsaPattern: 'Kahn\'s BFS / Topological Sort',
            timeComplexity: 'O(V+E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'Nodes with in-degree 0 have no dependencies — they can be scheduled first. Removing them may free others. If not all nodes processed → cycle.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Flood Fill — Paint bucket algorithm',
            approach: 'DFS/BFS from the clicked cell. Change original color to new color. For 4-directional neighbors, if neighbor has the original color, recurse. Handle edge case: if original color == new color, return immediately.',
            dsaPattern: 'DFS/BFS Flood Fill',
            timeComplexity: 'O(m×n)',
            spaceComplexity: 'O(m×n)',
            keyInsight: 'Classic connected component marking. The color itself acts as visited marker. Always check if source color == new color to avoid infinite loop.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Walls and Gates — fill with distance to nearest gate',
            approach: 'Multi-source BFS: enqueue all gates (value 0) first. BFS propagates distances outward: each neighbor of current cell gets min(current+1, existing distance). INF cells become reachable with correct min distance.',
            dsaPattern: 'Multi-Source BFS',
            timeComplexity: 'O(m×n)',
            spaceComplexity: 'O(m×n)',
            keyInsight: 'Starting BFS from all gates simultaneously is equivalent to running BFS from each gate and taking minimum. Multi-source BFS does this in one pass.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Pacific Atlantic Water Flow',
            approach: 'Reverse thinking: instead of water flowing down, BFS/DFS outward from each ocean (uphill). Find cells reachable from Pacific and cells reachable from Atlantic. Intersection is the answer.',
            dsaPattern: 'Reverse BFS/DFS from Multiple Sources',
            timeComplexity: 'O(m×n)',
            spaceComplexity: 'O(m×n)',
            keyInsight: 'Direct simulation is expensive. Reverse flow (from ocean to land) with ≥ neighbor height condition simplifies the problem drastically.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Alien Dictionary — find character ordering',
            approach: 'Build directed graph: for adjacent words, find first differing characters — that character comes before the other. Topological sort of the graph gives the alien alphabet order. If cycle detected — invalid input.',
            dsaPattern: 'Graph Construction + Topological Sort',
            timeComplexity: 'O(C) where C = total characters',
            spaceComplexity: 'O(1) (26 chars max)',
            keyInsight: 'Only compare adjacent words — each pair gives at most one ordering constraint. Check for prefix violations (word2 is prefix of word1 but appears after).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Number of Provinces (Connected Components)',
            approach: 'DFS/BFS on adjacency matrix or Union-Find. For each unvisited city, start DFS and mark all directly/indirectly connected cities as visited. Each DFS start = one new province. Count total starts.',
            dsaPattern: 'DFS Connected Components / Union-Find',
            timeComplexity: 'O(V²) for adj matrix',
            spaceComplexity: 'O(V)',
            keyInsight: 'Same as "friend circles" problem. Use Union-Find for cleaner code — merge all friends into one component, count distinct roots.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  6. BINARY TREE
// ══════════════════════════════════════════════

class BinaryTreeInterviewPage extends StatelessWidget {
  const BinaryTreeInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Binary Tree',
        accentColor: Colors.cyan,
        icon: Icons.device_hub_rounded,
        difficulty: 'Medium',
        difficultyColor: Colors.orange,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Lowest Common Ancestor (LCA) of two nodes',
            approach: 'DFS recursively. If current node is null or equals p or q, return it. Recurse left and right. If both return non-null, current node is the LCA. If only one returns non-null, that subtree contains both nodes.',
            dsaPattern: 'DFS / Post-order Traversal',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(h)',
            keyInsight: 'The first node where p and q appear in different subtrees (or node itself is p/q) is the LCA. Post-order naturally bubbles this up.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Maximum depth / height of binary tree',
            approach: 'Recursive DFS: maxDepth(node) = 1 + max(maxDepth(left), maxDepth(right)). Base case: null → return 0. BFS approach: count levels as BFS processes each level.',
            dsaPattern: 'DFS Recursion / BFS Level Count',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(h)',
            keyInsight: 'Height = longest root-to-leaf path. Recursive solution is concise — trust the recursion to explore all paths and return max.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Zigzag level order traversal',
            approach: 'BFS with level tracking. Use a flag to alternate direction. For odd levels, add values left-to-right. For even levels, add right-to-left (use deque or reverse). Toggle flag after each level.',
            dsaPattern: 'BFS + Direction Flag',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Standard BFS but reverse insertion order every other level. Deque with appendLeft avoids actual reversal overhead.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Check if binary tree is balanced (height-balanced)',
            approach: 'DFS returns height of subtree OR -1 if unbalanced. At each node: compute left and right heights. If either is -1 or |left-right| > 1, return -1 (unbalanced). Else return 1 + max(left, right).',
            dsaPattern: 'DFS with Height Check (Bottom-Up)',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(h)',
            keyInsight: '-1 as sentinel value propagates imbalance upward immediately — avoids recomputing height. One-pass bottom-up solution.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Binary tree right side view',
            approach: 'BFS level-order traversal. For each level, the last node in the level is visible from the right. Add last node of each level to result. Alternatively, DFS with level tracking — first visit of each new level depth is the rightmost.',
            dsaPattern: 'BFS Level Order / DFS with Depth',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Right side view = last node of each BFS level. DFS approach: visit right before left — first node at each depth is the answer.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Diameter of binary tree (longest path between any two nodes)',
            approach: 'DFS: for each node compute left height + right height (path through this node). Track global maximum of this sum. Return max(leftHeight, rightHeight) + 1 to parent. Answer is global max.',
            dsaPattern: 'DFS with Global Maximum',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(h)',
            keyInsight: 'Diameter at each node = leftHeight + rightHeight. The path may not pass through root. Track global max during DFS — similar to maximum path sum.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Serialize and deserialize binary tree',
            approach: 'Serialize: pre-order DFS, append node values separated by comma. Use "#" for null. Deserialize: split by comma into queue. Recursively build tree: dequeue value, if "#" return null, else create node and recurse for left and right.',
            dsaPattern: 'DFS Pre-order / Queue-based Deserialization',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Pre-order serialization with null markers uniquely encodes tree structure. Queue makes deserialization sequential and elegant.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Path sum — does any root-to-leaf path sum to target?',
            approach: 'DFS: subtract current node value from target. At leaf, check if remaining == 0. Recurse left and right. Return true if either subtree has a valid path. Handle null node: return false immediately.',
            dsaPattern: 'DFS / Root-to-Leaf Traversal',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(h)',
            keyInsight: 'Check at leaf (both children null), not at any node. Subtracting progressively avoids carrying a sum array — O(1) extra per call.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  7. BST
// ══════════════════════════════════════════════

class BSTInterviewPage extends StatelessWidget {
  const BSTInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Binary Search Tree',
        accentColor: Colors.indigo,
        icon: Icons.schema_rounded,
        difficulty: 'Medium',
        difficultyColor: Colors.orange,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Validate if a binary tree is a valid BST',
            approach: 'DFS with min/max bounds: isValid(node, min, max). At each node, check min < node.val < max. For left subtree, pass (min, node.val). For right subtree, pass (node.val, max). Initial call: (-INF, +INF).',
            dsaPattern: 'DFS with Range Bounds',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(h)',
            keyInsight: 'Comparing only with direct parent is wrong — values must satisfy bounds from all ancestors. Pass min/max range down the recursion.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Kth smallest element in BST',
            approach: 'In-order traversal (Left→Root→Right) of BST gives elements in ascending order. Decrement k each time a node is visited. When k reaches 0, current node is the kth smallest. Can use iterative stack-based in-order.',
            dsaPattern: 'In-order Traversal (BST Property)',
            timeComplexity: 'O(h+k)',
            spaceComplexity: 'O(h)',
            keyInsight: 'In-order traversal of BST is always sorted ascending. Kth element = stop at kth in-order visit. Iterative approach allows early termination.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Convert sorted array to height-balanced BST',
            approach: 'Recursively pick the middle element of current range as root. Left subtree = recursively build from left half. Right subtree = recursively build from right half. This ensures balanced height since mid always splits evenly.',
            dsaPattern: 'Divide and Conquer / Binary Search',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(log n)',
            keyInsight: 'Middle element as root ensures left and right subtrees are equal (or off by one). Same idea as binary search partitioning.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Inorder successor in BST',
            approach: 'If node has a right subtree: successor = leftmost node in right subtree. Else: traverse from root, tracking the last node where you went left — that is the successor. No parent pointer needed.',
            dsaPattern: 'BST Property Navigation',
            timeComplexity: 'O(h)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Successor = smallest value greater than current. Leftmost in right subtree OR nearest ancestor that you came from its left child.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Lowest Common Ancestor in BST',
            approach: 'Use BST property: if both p and q are less than current, LCA is in left subtree. If both greater, in right subtree. Otherwise current node is the LCA (where the paths diverge).',
            dsaPattern: 'BST Property Navigation',
            timeComplexity: 'O(h)',
            spaceComplexity: 'O(1)',
            keyInsight: 'BST LCA is simpler than general binary tree — no DFS needed. The node where p and q first split (one goes left, one right) is the LCA.',
          ),
          InterviewQuestionCard(
            questionTitle: 'BST to Greater Sum Tree (replace node with sum of all greater values)',
            approach: 'Reverse in-order traversal (Right→Root→Left): this visits nodes in descending order. Maintain a running sum. Replace each node\'s value with the running sum (includes node itself for Greater Sum Tree variant).',
            dsaPattern: 'Reverse In-order Traversal',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(h)',
            keyInsight: 'Right→Root→Left gives descending order. Running sum accumulates all values greater than current — exactly what we need to assign.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Two Sum in BST — do two nodes sum to target?',
            approach: 'In-order traversal to get sorted array. Use two-pointer technique on sorted array: if sum < target, move left pointer right; if sum > target, move right pointer left; if equal, found.',
            dsaPattern: 'In-order Traversal + Two Pointers',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'BST in-order gives sorted array — classic two-sum with two pointers. Alternative: use a HashSet during DFS traversal for O(n) time O(n) space without extra array.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Delete node in BST',
            approach: 'Find node via BST navigation. Three cases: (1) Leaf → set to null. (2) One child → replace with that child. (3) Two children → find in-order successor (min of right subtree), copy its value to current node, delete successor.',
            dsaPattern: 'BST Deletion (3 Cases)',
            timeComplexity: 'O(h)',
            spaceComplexity: 'O(h)',
            keyInsight: 'Two-children case is the tricky one — in-order successor always has at most one (right) child, simplifying its deletion. BST property maintained throughout.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  8. LINKED LIST
// ══════════════════════════════════════════════

class LinkedListInterviewPage extends StatelessWidget {
  const LinkedListInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Linked List',
        accentColor: Colors.pink,
        icon: Icons.linear_scale_rounded,
        difficulty: 'Medium',
        difficultyColor: Colors.orange,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Reverse a singly linked list',
            approach: 'Iterative: three pointers — prev=null, curr=head, next=null. Loop: save next, point curr.next to prev, advance prev to curr, advance curr to saved next. Return prev as new head.',
            dsaPattern: 'Three-Pointer Iterative Reversal',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'In each step: save next, reverse pointer, advance both. Order matters — save next BEFORE reversing curr.next, or you lose the rest of the list.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Detect cycle in linked list (Floyd\'s Cycle Detection)',
            approach: 'Two pointers: slow moves 1 step, fast moves 2 steps. If they meet → cycle exists. To find entry: reset slow to head. Advance both one step at a time — they meet at cycle entry.',
            dsaPattern: 'Floyd\'s Cycle Detection (Tortoise & Hare)',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'If cycle length is L and entry is at distance k, after meeting point reset math proves both pointers meet at entry after exactly k more steps.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Merge two sorted linked lists',
            approach: 'Use a dummy head node. Compare heads of both lists — attach the smaller node to result. Advance the pointer of the list whose node was used. When one list empties, append the other. Return dummy.next.',
            dsaPattern: 'Merge (Two Pointer / Dummy Node)',
            timeComplexity: 'O(m+n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Dummy head simplifies edge cases (empty lists). You never need to check if result head is null — dummy handles it. Same merge as Merge Sort.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find the middle of linked list',
            approach: 'Fast/slow pointer: slow moves 1 step, fast moves 2 steps. When fast reaches end, slow is at middle. For even length, this gives the second middle. For first middle, check fast.next before advancing.',
            dsaPattern: 'Fast/Slow Pointer (Tortoise & Hare)',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Fast moves 2x, so when fast traverses n nodes, slow traverses n/2. One-pass — no need to count length first.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Remove Nth node from end of list',
            approach: 'Two pointers with n+1 gap: advance fast pointer n+1 steps ahead. Then move both until fast is null. Now slow.next is the Nth from end — set slow.next = slow.next.next. Dummy head handles edge case of removing head.',
            dsaPattern: 'Two Pointer with Fixed Gap',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'n+1 gap (not n) so slow lands at the node BEFORE the one to delete. Dummy head lets you delete the actual head node without special casing.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Check if linked list is palindrome',
            approach: '(1) Find middle using fast/slow. (2) Reverse second half. (3) Compare first half with reversed second half node by node. (4) Optionally restore list. Return true only if all values match.',
            dsaPattern: 'Find Middle + Reverse Half + Compare',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Three sub-problems chained: find middle → reverse → compare. Restoring is good practice. No extra array needed — in-place reversal.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Flatten a multilevel doubly linked list',
            approach: 'Iterative: traverse the list. When a node has a child: find the tail of the child list. Connect current.next to child, child.prev to current. Connect child tail to current\'s old next. Set child pointer to null.',
            dsaPattern: 'Iteration + Pointer Manipulation',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Insert child list between current and next. Four pointer connections needed: (curr→child), (child←curr), (tail→next), (next←tail). Handle null next carefully.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Add two numbers represented as linked lists',
            approach: 'Traverse both lists simultaneously. At each step, sum = l1.val + l2.val + carry. New node value = sum % 10. Carry = sum / 10. Continue even when one list ends (pad with 0). After loop, if carry remains, add extra node.',
            dsaPattern: 'Simultaneous Traversal + Carry Propagation',
            timeComplexity: 'O(max(m,n))',
            spaceComplexity: 'O(max(m,n))',
            keyInsight: 'Digits are reversed (least significant first) — simplifies carry propagation. Handle different lengths and final carry as edge cases.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  9. STACK
// ══════════════════════════════════════════════

class StackInterviewPage extends StatelessWidget {
  const StackInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Stack',
        accentColor: Colors.amber,
        icon: Icons.layers_rounded,
        difficulty: 'Easy',
        difficultyColor: Colors.green,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Valid parentheses — check if brackets are balanced',
            approach: 'Push every opening bracket onto stack. For every closing bracket, check if stack top matches. If yes, pop; if no or stack empty → invalid. At end, stack should be empty for valid input.',
            dsaPattern: 'Stack (LIFO Bracket Matching)',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Stack naturally reverses order — last opened must be first closed. HashMap for bracket pairs makes code clean. Empty stack at end = fully matched.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Next Greater Element for each array element',
            approach: 'Monotonic decreasing stack: iterate left to right. While stack not empty and stack top < current element, pop — current element is the NGE for that popped element. Push current element. Remaining stack elements have no NGE (-1).',
            dsaPattern: 'Monotonic Stack',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Stack maintains elements waiting for their NGE. When a larger element arrives, it\'s the NGE for all smaller elements in stack. Each element is pushed/popped exactly once.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Min Stack — stack that supports getMin() in O(1)',
            approach: 'Use two stacks: main stack and minStack. On push: push to main, push to minStack only if new element ≤ current min (or if minStack is empty). On pop: pop from main, pop from minStack only if popped == minStack.top.',
            dsaPattern: 'Auxiliary Stack / Stack Design',
            timeComplexity: 'O(1) all operations',
            spaceComplexity: 'O(n)',
            keyInsight: 'MinStack stores current minimum at each level. When that element is popped, the previous min is revealed. Single stack variant: push (val, currentMin) pairs.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Largest rectangle in histogram',
            approach: 'Monotonic increasing stack of indices. When current bar is shorter than stack top: pop top. Width = current index - stack.top - 1 (if stack not empty, else width = current index). Area = height[popped] × width. Update max area.',
            dsaPattern: 'Monotonic Stack',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'When a shorter bar appears, it limits all taller bars behind it. Stack gives the nearest shorter bar to the left. Current position gives nearest shorter to the right.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Evaluate Reverse Polish Notation (postfix expression)',
            approach: 'Iterate through tokens. If number, push to stack. If operator (+,-,*,/): pop two operands (b first, then a). Compute a op b. Push result. Final stack top is the answer.',
            dsaPattern: 'Stack (Postfix Evaluation)',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Pop order matters: second pop is left operand (a), first pop is right (b). Division is a/b not b/a. Postfix removes need for precedence and parentheses.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Daily temperatures — days until warmer temperature',
            approach: 'Monotonic decreasing stack of indices. Iterate through temperatures. While stack not empty and current temp > temp at stack.top index: pop index, set result[poppedIndex] = currentIndex - poppedIndex. Push current index.',
            dsaPattern: 'Monotonic Stack',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Store indices not temperatures in stack. result[i] = currentDay - stackTop gives days until warmer. Same pattern as Next Greater Element.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Implement Queue using two Stacks',
            approach: 'Stack1 for enqueue (push directly). Stack2 for dequeue/peek. When Stack2 is empty and dequeue is called: pour all of Stack1 into Stack2 (reverses order). Then pop from Stack2. Amortized O(1) dequeue.',
            dsaPattern: 'Stack Pair / Amortized Design',
            timeComplexity: 'O(1) amortized',
            spaceComplexity: 'O(n)',
            keyInsight: 'Pouring from Stack1 to Stack2 reverses order — LIFO becomes FIFO. Each element is pushed twice and popped twice max. Amortized O(1).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Trapping Rain Water',
            approach: 'Monotonic stack: for each bar, while current bar > stack top bar, compute water. Height = min(current, bar before top) - top bar height. Width = current index - index before top - 1. Area = height × width.',
            dsaPattern: 'Monotonic Stack / Two Pointer',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Water is trapped between taller bars. Stack tracks bars that could form left boundary. Two-pointer approach (precompute maxLeft, maxRight arrays) is simpler to implement.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  10. QUEUE
// ══════════════════════════════════════════════

class QueueInterviewPage extends StatelessWidget {
  const QueueInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Queue',
        accentColor: Colors.lightBlue,
        icon: Icons.queue_rounded,
        difficulty: 'Easy',
        difficultyColor: Colors.green,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Implement Stack using two Queues',
            approach: 'On push(x): enqueue x to Q1. Then dequeue all elements from Q1 and enqueue to Q2. Swap Q1 and Q2. Now top of stack is front of Q1. Pop = dequeue from Q1.',
            dsaPattern: 'Queue Pair / Re-ordering',
            timeComplexity: 'O(n) push, O(1) pop',
            spaceComplexity: 'O(n)',
            keyInsight: 'Rotate elements so newly pushed item is always at front. Alternative: lazy pop approach — only rotate on pop, making push O(1) and pop O(n).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Sliding Window Maximum — max in each window of size k',
            approach: 'Use a Deque (double-ended queue) of indices. Maintain decreasing order of values. Before adding index i: remove indices outside window (front < i-k+1). Remove from back while arr[back] <= arr[i]. Front of deque = current window max.',
            dsaPattern: 'Monotonic Deque',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(k)',
            keyInsight: 'Deque maintains potential maximums in decreasing order. Back removals eliminate elements that can never be the maximum (smaller AND older). Front = current max.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Generate binary numbers from 1 to N using queue',
            approach: 'Enqueue "1". For each iteration (1 to N): dequeue front as current number, print/store it. Enqueue current+"0" and current+"1". The dequeue order naturally gives binary numbers in order.',
            dsaPattern: 'BFS / Level Generation',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'FIFO order ensures binary numbers generated in sequence. Each number generates two children — a perfect binary tree structure explored level by level (BFS).',
          ),
          InterviewQuestionCard(
            questionTitle: 'First non-repeating character in a stream',
            approach: 'Use a Queue and frequency HashMap. For each character: increment frequency. If frequency == 1, enqueue. After each character: peek front of queue — if its frequency > 1, dequeue (it now repeats). Front of queue is first non-repeating.',
            dsaPattern: 'Queue + HashMap (Stream Processing)',
            timeComplexity: 'O(1) amortized per char',
            spaceComplexity: 'O(1) (26 chars)',
            keyInsight: 'Queue preserves arrival order. Lazy cleanup at front: only remove when queried, not immediately when character repeats. This keeps operation fast.',
          ),
          InterviewQuestionCard(
            questionTitle: 'BFS — Level order traversal of binary tree',
            approach: 'Enqueue root. While queue not empty: record queue size (level size). Dequeue size nodes, collecting their values for current level. Enqueue each dequeued node\'s non-null children. Each loop = one level.',
            dsaPattern: 'BFS Level-by-Level',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Queue size at start of each iteration = number of nodes at that level. Process exactly that many nodes per level to separate levels correctly.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Rotting Oranges using multi-source BFS',
            approach: 'Count fresh oranges. Enqueue all initially rotten oranges. BFS spreads rot to 4-directional fresh neighbors each round (decrement fresh count). Count rounds. If fresh oranges remain after BFS, return -1.',
            dsaPattern: 'Multi-Source BFS',
            timeComplexity: 'O(m×n)',
            spaceComplexity: 'O(m×n)',
            keyInsight: 'All rot sources spread simultaneously — multi-source BFS is equivalent to single-source BFS on a super-source connected to all rotten oranges.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Design circular queue with fixed capacity',
            approach: 'Use array with head and tail pointers. Enqueue: if not full, place at tail, advance tail = (tail+1)%capacity, increment size. Dequeue: if not empty, retrieve arr[head], advance head = (head+1)%capacity, decrement size.',
            dsaPattern: 'Circular Buffer Design',
            timeComplexity: 'O(1) all operations',
            spaceComplexity: 'O(k)',
            keyInsight: 'Modulo arithmetic wraps pointers around — no shifting needed. Track size separately from head/tail to distinguish empty (size=0) from full (size=capacity).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Shortest path in binary matrix (0=open, 1=blocked)',
            approach: 'BFS from top-left (0,0). Explore all 8-directional neighbors of each cell. Track visited cells. BFS guarantees shortest path — first time target (n-1, n-1) is reached is the shortest path.',
            dsaPattern: 'BFS Shortest Path on Grid',
            timeComplexity: 'O(n²)',
            spaceComplexity: 'O(n²)',
            keyInsight: 'BFS on grid with 8-directional movement. Level = path length. Check start and end are open before BFS. Modify grid to mark visited (set to 1) to avoid extra visited array.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  11. HEAP
// ══════════════════════════════════════════════

class HeapInterviewPage extends StatelessWidget {
  const HeapInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Heap',
        accentColor: Colors.deepOrange,
        icon: Icons.filter_list_rounded,
        difficulty: 'Hard',
        difficultyColor: Colors.red,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Merge K sorted linked lists',
            approach: 'Push the head of each list into a Min Heap. Repeatedly extract minimum node, add to result, and push the next node from that list into the heap. Continue until heap is empty.',
            dsaPattern: 'Min Heap (Priority Queue)',
            timeComplexity: 'O(n log k)',
            spaceComplexity: 'O(k)',
            keyInsight: 'k is the number of lists, n is total nodes. Heap always gives next minimum across all lists in O(log k). Only k elements in heap at any time.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find median from a data stream',
            approach: 'Two heaps: Max Heap for lower half, Min Heap for upper half. On each insertion: add to Max Heap, then balance by moving Max Heap top to Min Heap. If Min Heap has more, move its top back. Median = Max Heap top (or average of both tops).',
            dsaPattern: 'Two Heaps (Max + Min)',
            timeComplexity: 'O(log n) insert, O(1) median',
            spaceComplexity: 'O(n)',
            keyInsight: 'Max Heap contains lower half, Min Heap upper half. Keep sizes equal (or max heap 1 larger). Median is always accessible at heap tops — no sorting needed.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Top K frequent elements',
            approach: 'Build frequency HashMap. Use a Min Heap of size K: iterate all (element, frequency) pairs — if heap size < k, push; else if current frequency > heap top frequency, pop and push. Return heap elements.',
            dsaPattern: 'Min Heap of Size K / Bucket Sort',
            timeComplexity: 'O(n log k)',
            spaceComplexity: 'O(n+k)',
            keyInsight: 'Min Heap of size k efficiently keeps k largest frequencies. Alternative: Bucket Sort by frequency gives O(n) — create buckets indexed by frequency, fill, read top k.',
          ),
          InterviewQuestionCard(
            questionTitle: 'K closest points to origin',
            approach: 'Use Max Heap of size K storing (distance, point). For each point: if heap size < k, push. Else if distance < heap top distance, pop and push current. Return heap contents after processing all points.',
            dsaPattern: 'Max Heap of Size K',
            timeComplexity: 'O(n log k)',
            spaceComplexity: 'O(k)',
            keyInsight: 'Max Heap maintains k SMALLEST — when new point is closer than largest in heap, evict the largest. QuickSelect gives O(n) average. No need to sqrt — compare squared distances.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Task Scheduler — minimum CPU intervals (with cooldown n)',
            approach: 'Count task frequencies. Max heap of frequencies. Simulate: in each cooling cycle (n+1 slots), pick up to n+1 highest-frequency tasks. Decrement each. Add non-zero frequencies back to heap. Count total time as max(tasks used in cycle, n+1).',
            dsaPattern: 'Max Heap / Greedy Simulation',
            timeComplexity: 'O(n × cycle_count)',
            spaceComplexity: 'O(1) (26 task types)',
            keyInsight: 'Math formula: answer = max(task count, (maxFreq-1)×(n+1) + countOfMaxFreq). Greedy always schedules most-frequent tasks first to minimize idle slots.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Kth largest element in a stream',
            approach: 'Maintain a Min Heap of size K. On each add(val): push val to heap. If heap size > k, pop the minimum. Heap top is always the Kth largest since k-1 elements larger than it are above.',
            dsaPattern: 'Min Heap of Size K (Online Algorithm)',
            timeComplexity: 'O(log k) per insertion',
            spaceComplexity: 'O(k)',
            keyInsight: 'Min heap of size k: top is kth largest. Any element larger than top displaces top (old kth becomes smaller than k elements). Works for streaming data.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Ugly Number II — find Nth ugly number (2,3,5 factors only)',
            approach: 'Use three pointers p2, p3, p5 (initially 0). Each points to index in ugly[] array. Next ugly = min(ugly[p2]×2, ugly[p3]×3, ugly[p5]×5). Advance the pointer(s) that generated the min. Fill ugly[1..n].',
            dsaPattern: 'Three Pointer DP / Min Heap',
            timeComplexity: 'O(n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Three pointers avoid duplicates naturally — when multiple pointers generate the same min, advance all of them. Equivalent to min heap approach but O(n) vs O(n log n).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Minimum cost to connect ropes (Huffman-style)',
            approach: 'Use a Min Heap of all rope lengths. Repeatedly extract two shortest ropes, combine them (cost = sum), push combined rope back. Total cost = sum of all combination costs. This greedy approach minimizes total cost.',
            dsaPattern: 'Greedy + Min Heap (Huffman Coding)',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Same greedy as Huffman coding. Combining shortest ropes first minimizes accumulated cost — longer ropes are only combined at higher levels (added fewer times to total).',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  12. SHORTEST PATH
// ══════════════════════════════════════════════

class ShortestPathInterviewPage extends StatelessWidget {
  const ShortestPathInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Shortest Path',
        accentColor: Colors.lime,
        icon: Icons.route_rounded,
        difficulty: 'Hard',
        difficultyColor: Colors.red,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Network Delay Time — all nodes receive signal (Dijkstra)',
            approach: 'Build weighted directed graph. Run Dijkstra from source k. Track shortest time to reach each node. Answer = max of all shortest times. If any node unreachable (dist = INF), return -1.',
            dsaPattern: "Dijkstra's Single Source Shortest Path",
            timeComplexity: 'O((V+E) log V)',
            spaceComplexity: 'O(V+E)',
            keyInsight: 'All edge weights positive → Dijkstra optimal. Answer is the max shortest path to any node (last node to receive signal determines total time).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Cheapest flights within K stops (Bellman-Ford)',
            approach: 'Run Bellman-Ford for exactly K+1 iterations (K stops = K+1 edges). Use a copy of distances from previous iteration to avoid using new edges in same round. After K+1 relaxations, dist[dst] is the answer.',
            dsaPattern: 'Bellman-Ford with K Iterations',
            timeComplexity: 'O(K × E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'K stops = K+1 edges. Must use previous iteration\'s distances (snapshot) to prevent using multiple new edges in one Bellman-Ford pass. Dijkstra with modified state also works.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Path with minimum effort (binary search + BFS/DFS)',
            approach: 'Binary search on the answer (effort value). For each candidate effort, check if path exists from top-left to bottom-right using BFS/DFS where we only traverse edges with difference ≤ effort. Find minimum valid effort.',
            dsaPattern: 'Binary Search on Answer + BFS/Dijkstra',
            timeComplexity: 'O(m×n × log(maxDiff))',
            spaceComplexity: 'O(m×n)',
            keyInsight: 'Effort is monotonic — if path exists for effort X, it exists for X+1. Binary search on answer space. Dijkstra with min-heap directly gives O(m×n×log(m×n)).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find city with fewest reachable cities within threshold',
            approach: 'Run Floyd-Warshall to get all-pairs shortest paths. For each city, count neighbors reachable within distance threshold. Pick city with minimum reachable count (choose highest-numbered city for ties).',
            dsaPattern: 'Floyd-Warshall All-Pairs',
            timeComplexity: 'O(V³)',
            spaceComplexity: 'O(V²)',
            keyInsight: 'Small V (≤100) makes O(V³) feasible. Floyd-Warshall gives all pairs in one go — more efficient than running Dijkstra from each source when V is small.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Minimum cost path in grid (Dijkstra on grid)',
            approach: 'Treat each grid cell as a graph node. Edge cost = cell value. Run Dijkstra from (0,0). Priority queue with (cost, row, col). Expand 4 neighbors. First time (n-1,m-1) is reached = minimum cost path.',
            dsaPattern: "Dijkstra's on Grid",
            timeComplexity: 'O(m×n × log(m×n))',
            spaceComplexity: 'O(m×n)',
            keyInsight: 'Grid is just a special graph. Dijkstra works when cell values (edge weights) can vary. BFS only works for unit costs. Use distance matrix initialized to INF.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Word Ladder II — all shortest transformation sequences',
            approach: 'BFS to build layer-by-layer shortest path graph (parent map). Then DFS/backtracking from end word to start word using parent map to collect all shortest paths. BFS ensures only shortest paths are in the parent graph.',
            dsaPattern: 'BFS (Build Graph) + DFS (Collect Paths)',
            timeComplexity: 'O(M² × N)',
            spaceComplexity: 'O(M² × N)',
            keyInsight: 'Separate BFS (find structure) from DFS (enumerate paths). Don\'t enumerate during BFS — too slow. BFS parent map captures all shortest paths simultaneously.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Minimum knight moves on infinite chessboard',
            approach: 'BFS from (0,0) to target. Explore all 8 knight moves from each position. BFS guarantees shortest (minimum moves). Limit search space by reflecting to first quadrant (|x|, |y|) due to symmetry.',
            dsaPattern: 'BFS on Implicit Graph',
            timeComplexity: 'O(|x| × |y|)',
            spaceComplexity: 'O(|x| × |y|)',
            keyInsight: 'Symmetry reduces search: reflect target to first quadrant. A* with Manhattan distance heuristic speeds this up significantly for large targets.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Currency exchange arbitrage detection (negative cycle)',
            approach: 'Convert exchange rates: edge weight = -log(rate). Run Bellman-Ford. If after V-1 relaxations, any edge can still be relaxed → negative cycle exists → arbitrage opportunity.',
            dsaPattern: 'Bellman-Ford Negative Cycle Detection',
            timeComplexity: 'O(VE)',
            spaceComplexity: 'O(V)',
            keyInsight: '-log(rate) converts multiplication chain to addition: log(a×b×c) = log(a)+log(b)+log(c). Negative sum = product > 1 = arbitrage. Negative cycle = endless profit loop.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  13. MST
// ══════════════════════════════════════════════

class MSTInterviewPage extends StatelessWidget {
  const MSTInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Minimum Spanning Tree',
        accentColor: Colors.greenAccent,
        icon: Icons.park_rounded,
        difficulty: 'Hard',
        difficultyColor: Colors.red,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Minimum cost to connect all points (Prim\'s MST)',
            approach: 'Treat points as graph nodes, edge weight = Manhattan distance. Prim\'s: maintain minDist[] array. Start from point 0. Repeatedly pick unvisited point with minimum distance from current MST, add to MST, update neighbors\' minDist.',
            dsaPattern: "Prim's Algorithm (Dense Graph)",
            timeComplexity: 'O(n²)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Complete graph has O(n²) edges — Prim\'s with array (not heap) is O(n²) which matches edge count. For sparse graphs, heap gives O(E log V).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Optimize water distribution in a village (virtual node MST)',
            approach: 'Add virtual node 0 connected to each house with edge weight = well cost for that house. Run Kruskal\'s or Prim\'s MST on this augmented graph. Edge to virtual node = build well; other edges = pipes.',
            dsaPattern: 'Virtual Node + Kruskal\'s MST',
            timeComplexity: 'O(E log E)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Virtual source node elegantly handles the choice between building a well (connect to virtual node) or laying a pipe (connect two houses). MST automatically picks optimal combination.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Remove max number of edges to keep graph fully traversable',
            approach: 'Use two Union-Find structures (one for Alice, one for Bob). First process type-3 edges (shared). Then process type-1 (Alice) and type-2 (Bob) edges. Count edges added. If both graphs aren\'t fully connected at end, return -1.',
            dsaPattern: 'Union-Find + Greedy Edge Selection',
            timeComplexity: 'O(E × α(n))',
            spaceComplexity: 'O(n)',
            keyInsight: 'Shared edges (type 3) used first — they benefit both Alice and Bob simultaneously. Greedy: add edge only if it connects two components. Unused edges can be removed.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Minimum spanning tree with Kruskal\'s and Union-Find',
            approach: 'Sort all edges by weight. Initialize Union-Find with each node as its own component. Iterate edges: if edge connects two different components (find returns different roots), add to MST and union them. Stop when V-1 edges added.',
            dsaPattern: "Kruskal's + Union-Find",
            timeComplexity: 'O(E log E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'Sorted greedy + cycle avoidance (Union-Find) = optimal MST. Path compression and union by rank make Union-Find nearly O(1) amortized. Kruskal beats Prim for sparse graphs.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find critical and pseudo-critical edges in MST',
            approach: 'For each edge: (1) Find MST weight excluding it — if higher, it\'s critical. (2) Find MST weight forcing it included — if equals original MST weight, it\'s pseudo-critical. Run Kruskal\'s for each check.',
            dsaPattern: "Kruskal's MST + Edge Classification",
            timeComplexity: 'O(E² × α(V))',
            spaceComplexity: 'O(V)',
            keyInsight: 'Critical edge: removing increases MST weight or disconnects. Pseudo-critical: part of some MST but not all. Brute force each edge with Kruskal\'s — feasible for small E.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Connecting cities with minimum cost (weighted edges)',
            approach: 'Build a complete or partial graph from given edge list. Run Kruskal\'s MST — sort edges, use Union-Find to build spanning tree greedily. Total MST weight = minimum connection cost. Check all nodes are connected.',
            dsaPattern: "Kruskal's Algorithm",
            timeComplexity: 'O(E log E)',
            spaceComplexity: 'O(V)',
            keyInsight: 'Standard MST problem — identify it by: minimize total cost + connect all nodes + no cycles. Kruskal preferred for edge-list input, Prim for adjacency matrix.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Checking if graph is a valid tree (n nodes, n-1 edges, connected)',
            approach: 'Valid tree requires: exactly n-1 edges AND graph is connected. Run Union-Find: for each edge, if both endpoints already in same component → cycle → not a tree. If all edges processed without cycle and exactly one component, it\'s a tree.',
            dsaPattern: 'Union-Find / DFS Connectivity Check',
            timeComplexity: 'O(E × α(V))',
            spaceComplexity: 'O(V)',
            keyInsight: 'Tree iff: n-1 edges + connected (no cycles + fully connected). Union-Find detects cycles while counting components. Can also verify: DFS from any node visits all n nodes.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Path compression and union by rank in Union-Find',
            approach: 'Path Compression: in find(), make every node on path point directly to root (flatten the tree). Union by Rank: attach smaller-rank tree under larger-rank root. Together, amortized time per operation is nearly O(1) (inverse Ackermann).',
            dsaPattern: 'Union-Find Optimization',
            timeComplexity: 'O(α(n)) amortized',
            spaceComplexity: 'O(n)',
            keyInsight: 'Path compression + union by rank makes trees extremely flat. α(n) ≤ 4 for all practical n — effectively O(1). Foundation for efficient Kruskal\'s and network connectivity.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  14. HUFFMAN
// ══════════════════════════════════════════════

class HuffmanInterviewPage extends StatelessWidget {
  const HuffmanInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSAInterviewPage(
      data: InterviewPageData(
        title: 'Huffman Coding',
        accentColor: Colors.red,
        icon: Icons.compress_rounded,
        difficulty: 'Hard',
        difficultyColor: Colors.red,
        questions: [
          InterviewQuestionCard(
            questionTitle: 'Build Huffman encoding for a string',
            approach: 'Count character frequencies. Insert all (char, freq) as leaf nodes into a Min Heap. Repeatedly extract two minimum-frequency nodes, create a parent with combined frequency, insert back. Tree root emerges after n-1 merges. DFS tree to extract codes (0=left, 1=right).',
            dsaPattern: 'Greedy + Min Heap + Tree DFS',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Always merging two smallest guarantees minimum total weighted path length = minimum average code length. The tree structure encodes priority — frequent chars near root.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Minimum cost of cutting a rod into segments',
            approach: 'This is the reverse of Huffman — instead of merging, we cut. But optimal merging order is same: always merge/cut smallest pieces first. Use Min Heap: extract two smallest, combine (cost = sum), insert back. Total cost = sum of all combinations.',
            dsaPattern: 'Greedy + Min Heap (Huffman-style)',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Cutting is the reverse of merging. The cost at each step equals the combined length — shorter pieces combined first accumulate less total cost (counted fewer times).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Minimum number of coins to represent all values up to N',
            approach: 'Greedy: always use the largest denomination ≤ remaining target. For making optimal coin set: verify that each value 1..N is reachable. A coin set is complete if each new coin ≤ (reachable range + 1) — otherwise a gap exists.',
            dsaPattern: 'Greedy / Dynamic Programming',
            timeComplexity: 'O(n × coins)',
            spaceComplexity: 'O(n)',
            keyInsight: 'Coin set completeness: if current reachable range is [1, reach] and next coin ≤ reach+1, new reach = reach + coin. If coin > reach+1, gap at reach+1 — need to add a coin.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Rearrange string so no two adjacent characters are same',
            approach: 'Count character frequencies. Use Max Heap. Repeatedly extract most-frequent character, append to result. If previous character was same, first extract second-most-frequent, append it, then push previous back.',
            dsaPattern: 'Greedy + Max Heap',
            timeComplexity: 'O(n log k)',
            spaceComplexity: 'O(k)',
            keyInsight: 'Always place the most frequent character, but not consecutively. Hold back the last-placed character for one round. If max frequency > (n+1)/2, impossible to rearrange.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Construct tree from Huffman codes',
            approach: 'Start with an empty trie root. For each (character, code) pair: traverse the trie bit by bit (0=left, 1=right), creating nodes as needed. At end of code, mark as leaf with the character. Used for Huffman decoding setup.',
            dsaPattern: 'Trie Construction from Bit Codes',
            timeComplexity: 'O(n × max_code_length)',
            spaceComplexity: 'O(n × max_code_length)',
            keyInsight: 'Huffman codes form a prefix-free trie — no code is prefix of another, so no ambiguity at leaf nodes. Build once, decode in O(encoded_length).',
          ),
          InterviewQuestionCard(
            questionTitle: 'Find Huffman code for each character given frequencies',
            approach: 'Build Huffman tree using Min Heap. DFS the tree: append "0" when going left, "1" when going right. When reaching a leaf, record (character, accumulated path string) as its Huffman code.',
            dsaPattern: 'Huffman Tree + DFS Path Encoding',
            timeComplexity: 'O(n log n)',
            spaceComplexity: 'O(n)',
            keyInsight: 'DFS collects path from root to each leaf — that path IS the Huffman code. Prefix-free guaranteed because codes only at leaves. Pass code string by value (not reference) in recursion.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Decode a Huffman encoded binary string',
            approach: 'Start at root of Huffman tree. For each bit in encoded string: move left (bit=0) or right (bit=1). When a leaf is reached, output the character and reset to root. Continue until all bits processed.',
            dsaPattern: 'Tree Traversal + Bit Stream Decoding',
            timeComplexity: 'O(encoded_length)',
            spaceComplexity: 'O(1)',
            keyInsight: 'Prefix-free property makes decoding unambiguous — leaf reached = character boundary, no lookahead needed. Same tree used for encoding must be used for decoding.',
          ),
          InterviewQuestionCard(
            questionTitle: 'Huffman coding vs Arithmetic coding comparison',
            approach: 'Huffman: variable-length integer codes, near-optimal within 1 bit per symbol of Shannon entropy. Fast encode/decode. Arithmetic: encodes entire message as single fraction, achieves Shannon entropy exactly but requires high-precision arithmetic.',
            dsaPattern: 'Algorithm Design / Compression Theory',
            timeComplexity: 'Huffman: O(n log n), Arithmetic: O(n)',
            spaceComplexity: 'Both: O(alphabet size)',
            keyInsight: 'Huffman is suboptimal when probabilities are not negative powers of 2 (e.g., p=0.33 needs fractional bits). Arithmetic coding solves this at the cost of implementation complexity.',
          ),
        ],
      ),
    );
  }
}