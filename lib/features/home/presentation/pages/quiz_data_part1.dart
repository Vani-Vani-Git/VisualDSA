// quiz_data_part1.dart
// Place at: features/home/presentation/pages/quiz_data_part1.dart

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  const QuizQuestion({required this.question, required this.options, required this.correctIndex});
}

class QuizSubtopicData {
  final String algorithm;
  final String subtopic;
  final List<QuizQuestion> questions;
  const QuizSubtopicData({required this.algorithm, required this.subtopic, required this.questions});
}

// ═══════════════ ARRAY ═══════════════

const arrayIndexing = QuizSubtopicData(algorithm: 'Array', subtopic: 'Indexing', questions: [
  QuizQuestion(question: 'What is the index of the first element in a zero-indexed array?', options: ['1', '0', '-1', 'Depends on language'], correctIndex: 1),
  QuizQuestion(question: 'Time complexity of accessing an element by index?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'For an array of size n, what is the last valid index?', options: ['n', 'n+1', 'n-1', 'n-2'], correctIndex: 2),
  QuizQuestion(question: 'What happens when you access an array out of bounds in Java?', options: ['Returns null', 'Returns 0', 'ArrayIndexOutOfBoundsException', 'Undefined behavior'], correctIndex: 2),
  QuizQuestion(question: 'How is the memory address of arr[i] calculated?', options: ['Base + i', 'Base × i', 'Base + i × element_size', 'Base - i'], correctIndex: 2),
  QuizQuestion(question: 'In a 2D array arr[3][4], how many elements are there?', options: ['7', '12', '34', '6'], correctIndex: 1),
  QuizQuestion(question: 'For arr[r][c] in row-major order, what is the 1D index?', options: ['r + c', 'r × cols + c', 'c × rows + r', 'r × c'], correctIndex: 1),
  QuizQuestion(question: 'Which operation is O(1) for arrays?', options: ['Insertion at beginning', 'Deletion from middle', 'Access by index', 'Search by value'], correctIndex: 2),
  QuizQuestion(question: 'What is a jagged array?', options: ['An array with odd size', 'An array of arrays with different lengths', 'A sorted array', 'A circular array'], correctIndex: 1),
  QuizQuestion(question: 'What type of memory do arrays use?', options: ['Non-contiguous', 'Heap only', 'Contiguous', 'Linked'], correctIndex: 2),
]);

const arrayTraversal = QuizSubtopicData(algorithm: 'Array', subtopic: 'Traversal', questions: [
  QuizQuestion(question: 'Time complexity of traversing all elements in an array?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Which loop is most natural for array traversal?', options: ['while loop', 'do-while loop', 'for loop', 'recursion only'], correctIndex: 2),
  QuizQuestion(question: 'What is a reverse traversal?', options: ['Traversing from middle', 'Traversing from last index to first', 'Skipping every other element', 'Traversing randomly'], correctIndex: 1),
  QuizQuestion(question: 'Two-pointer traversal is commonly used for?', options: ['Sorting only', 'Finding pairs with a given sum', 'Deleting elements', 'Only reversing'], correctIndex: 1),
  QuizQuestion(question: 'What does a sliding window traversal optimize?', options: ['Random access', 'Subarray computations avoiding recomputation', 'Sorting', 'Deletion'], correctIndex: 1),
  QuizQuestion(question: 'Traversing a 2D array row by row is called?', options: ['Column-major order', 'Diagonal traversal', 'Row-major traversal', 'Depth-first'], correctIndex: 2),
  QuizQuestion(question: 'Space complexity of in-place traversal?', options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'], correctIndex: 3),
  QuizQuestion(question: 'How many iterations to traverse an array of size n?', options: ['n-1', 'n+1', 'n', 'n/2'], correctIndex: 2),
  QuizQuestion(question: 'What is prefix sum used for?', options: ['Sorting', 'Range sum queries in O(1) after O(n) preprocessing', 'Searching', 'Rotation'], correctIndex: 1),
  QuizQuestion(question: 'Result of traversing while computing sum of all elements?', options: ['Prefix sum', 'Running total (sum)', 'Product', 'Count'], correctIndex: 1),
]);

const arrayInsertion = QuizSubtopicData(algorithm: 'Array', subtopic: 'Insertion', questions: [
  QuizQuestion(question: 'Time complexity of inserting at the beginning of an array?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'What must happen before inserting at index i?', options: ['Elements 0 to i-1 shift left', 'Elements i to end shift right', 'Array is sorted first', 'Nothing'], correctIndex: 1),
  QuizQuestion(question: 'Inserting at the end of an array with available space is?', options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'], correctIndex: 3),
  QuizQuestion(question: 'When a dynamic array is full and you insert, what happens?', options: ['Insert fails', 'Array doubles in size', 'Array shrinks', 'Element is ignored'], correctIndex: 1),
  QuizQuestion(question: 'What is the amortized cost of insertion in a dynamic array?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'How many shifts are needed to insert at index 0 in array of size n?', options: ['0', 'n/2', 'n-1', 'n'], correctIndex: 3),
  QuizQuestion(question: 'Linked list is better than array for frequent insertions because?', options: ['Faster access', 'No shifting needed — just pointer update', 'Less memory', 'Always sorted'], correctIndex: 1),
  QuizQuestion(question: 'Inserting into a fixed-size full array causes?', options: ['Silent overwrite', 'Array expansion', 'Exception or undefined behavior', 'Auto sorting'], correctIndex: 2),
  QuizQuestion(question: 'Best case to insert into sorted array (keeping sorted)?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'], correctIndex: 2),
  QuizQuestion(question: 'Inserting n elements one by one at end of dynamic array costs?', options: ['O(n²)', 'O(n log n)', 'O(n) amortized', 'O(1) each'], correctIndex: 2),
]);

const arrayDeletion = QuizSubtopicData(algorithm: 'Array', subtopic: 'Deletion', questions: [
  QuizQuestion(question: 'Time complexity of deleting from middle of an array?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'After deleting element at index i, elements shift?', options: ['Right', 'Left', 'No shift', 'Both directions'], correctIndex: 1),
  QuizQuestion(question: 'Deleting from the end of an array is?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'What is "lazy deletion" in arrays?', options: ['Deleting slowly', 'Marking element as deleted without physically removing', 'Only for sorted arrays', 'Using a separate delete array'], correctIndex: 1),
  QuizQuestion(question: 'How many elements shift when deleting from index 0 in array of size n?', options: ['0', 'n-1', 'n', 'n/2'], correctIndex: 1),
  QuizQuestion(question: 'To remove duplicates from unsorted array in O(n), use?', options: ['Sorting', 'Two pointers', 'Hash Set', 'Binary search'], correctIndex: 2),
  QuizQuestion(question: 'Deleting by value first requires?', options: ['Sorting', 'Finding the element — O(n) search', 'No preprocessing', 'Building a BST'], correctIndex: 1),
  QuizQuestion(question: 'What happens to array size after deletion in a static array?', options: ['Shrinks', 'Remains same', 'Doubles', 'Halves'], correctIndex: 1),
  QuizQuestion(question: 'In Python list.remove(x), time complexity?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Which is faster: deleting from start or end of array?', options: ['Start — fewer elements to move', 'Both are O(1)', 'End — no shifting needed', 'Same always'], correctIndex: 2),
]);

const arrayUpdate = QuizSubtopicData(algorithm: 'Array', subtopic: 'Update', questions: [
  QuizQuestion(question: 'Time complexity of updating a value at a known index?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Updating all elements of array of size n takes?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'What is a "range update" in an array?', options: ['Update a single element', 'Update all elements from index l to r', 'Sort a subarray', 'Find max in range'], correctIndex: 1),
  QuizQuestion(question: 'Which data structure optimizes range updates and queries?', options: ['Stack', 'Queue', 'Segment Tree or BIT', 'Linked List'], correctIndex: 2),
  QuizQuestion(question: 'Updating arr[i] = arr[i] + 5 for all i is?', options: ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'], correctIndex: 1),
  QuizQuestion(question: 'In an immutable array, update creates?', options: ['In-place change', 'A new array with the modified value', 'Error always', 'Partial update'], correctIndex: 1),
  QuizQuestion(question: 'What is a segment tree used for?', options: ['Sorting only', 'Range queries (sum, min, max) and point updates', 'Graph traversal', 'String matching'], correctIndex: 1),
  QuizQuestion(question: 'Time complexity of point update in a Fenwick (BIT) tree?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'], correctIndex: 1),
  QuizQuestion(question: 'What is a difference array used for?', options: ['Range updates in O(1) with O(n) reconstruction', 'Point queries only', 'Sorting', 'Detecting cycles'], correctIndex: 0),
  QuizQuestion(question: 'Thread-safe updates to shared array require?', options: ['Sorting', 'Synchronized/atomic operations', 'Copying the array', 'Using a stack'], correctIndex: 1),
]);

const arraySearch = QuizSubtopicData(algorithm: 'Array', subtopic: 'Search', questions: [
  QuizQuestion(question: 'Time complexity of linear search in unsorted array?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Binary search requires the array to be?', options: ['Non-empty', 'Sorted', 'Unique elements', 'All positive'], correctIndex: 1),
  QuizQuestion(question: 'Binary search time complexity?', options: ['O(n)', 'O(n²)', 'O(1)', 'O(log n)'], correctIndex: 3),
  QuizQuestion(question: 'Safe mid formula to avoid integer overflow?', options: ['(low + high) / 2', 'low + (high - low) / 2', 'high - low / 2', 'low * high / 2'], correctIndex: 1),
  QuizQuestion(question: 'Binary search on 1024 elements — worst case comparisons?', options: ['1024', '512', '10', '32'], correctIndex: 2),
  QuizQuestion(question: 'Which search works on an unsorted array?', options: ['Binary Search', 'Interpolation Search', 'Linear Search', 'Jump Search'], correctIndex: 2),
  QuizQuestion(question: 'Jump search block size for array of size n?', options: ['n/2', 'log n', '√n', 'n²'], correctIndex: 2),
  QuizQuestion(question: 'Binary search returns -1 means?', options: ['Found at index 0', 'Element not present', 'Array is empty', 'Overflow occurred'], correctIndex: 1),
  QuizQuestion(question: 'Exponential search is best when?', options: ['Array is huge and target is near beginning', 'Array is unsorted', 'Array has duplicates', 'Array is small'], correctIndex: 0),
  QuizQuestion(question: 'Sentinel search places target at end to?', options: ['Speed up sort', 'Avoid bounds check in linear search', 'Search with hash', 'Find duplicates'], correctIndex: 1),
]);

// ═══════════════ SORTING ═══════════════

const bubbleSort = QuizSubtopicData(algorithm: 'Sorting', subtopic: 'Bubble Sort', questions: [
  QuizQuestion(question: 'Worst case time complexity of Bubble Sort?', options: ['O(n)', 'O(n log n)', 'O(n²)', 'O(log n)'], correctIndex: 2),
  QuizQuestion(question: 'In each pass of Bubble Sort, what happens?', options: ['Minimum element moves to front', 'Maximum element bubbles to the end', 'Array is split in half', 'Pivot is selected'], correctIndex: 1),
  QuizQuestion(question: 'Best case of Bubble Sort (already sorted)?', options: ['O(n²)', 'O(n log n)', 'O(n)', 'O(1)'], correctIndex: 2),
  QuizQuestion(question: 'Is Bubble Sort stable?', options: ['No', 'Yes', 'Depends', 'Only for integers'], correctIndex: 1),
  QuizQuestion(question: 'How many passes does Bubble Sort need for n elements?', options: ['1', 'log n', 'n', 'n-1'], correctIndex: 3),
  QuizQuestion(question: 'Optimization that stops Bubble Sort early if sorted?', options: ['Pivot check', 'Swap flag — if no swaps in a pass, stop', 'Boundary reduction', 'Both B and C'], correctIndex: 1),
  QuizQuestion(question: 'Space complexity of Bubble Sort?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'After k passes of Bubble Sort, how many elements are in final position?', options: ['k/2', 'k-1', 'k', '2k'], correctIndex: 2),
  QuizQuestion(question: 'Bubble Sort compares?', options: ['Non-adjacent elements', 'Random pairs', 'Adjacent elements', 'First and last only'], correctIndex: 2),
  QuizQuestion(question: 'Bubble Sort is practically used for?', options: ['Large datasets', 'Nearly sorted small arrays', 'Reverse sorted data', 'Linked lists'], correctIndex: 1),
]);

const selectionSort = QuizSubtopicData(algorithm: 'Sorting', subtopic: 'Selection Sort', questions: [
  QuizQuestion(question: 'Time complexity of Selection Sort in all cases?', options: ['O(n)', 'O(n log n)', 'O(n²)', 'O(log n)'], correctIndex: 2),
  QuizQuestion(question: 'What does Selection Sort do in each pass?', options: ['Swap adjacent elements', 'Find minimum and place at current position', 'Divide array in half', 'Pick pivot'], correctIndex: 1),
  QuizQuestion(question: 'Maximum swaps Selection Sort performs?', options: ['n²', 'n log n', 'n-1', 'n'], correctIndex: 2),
  QuizQuestion(question: 'Is Selection Sort stable by default?', options: ['Yes', 'No', 'Always', 'Only for strings'], correctIndex: 1),
  QuizQuestion(question: 'Space complexity of Selection Sort?', options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'], correctIndex: 3),
  QuizQuestion(question: 'Selection Sort is better than Bubble Sort in terms of?', options: ['Time complexity', 'Stability', 'Number of swaps (at most n-1)', 'Memory usage'], correctIndex: 2),
  QuizQuestion(question: 'After k passes of Selection Sort, how many elements are sorted?', options: ['k/2', 'k', 'n-k', '2k'], correctIndex: 1),
  QuizQuestion(question: 'Selection Sort on already sorted array?', options: ['O(n)', 'O(n log n)', 'O(n²) — still scans all', 'O(1)'], correctIndex: 2),
  QuizQuestion(question: 'Selection Sort is an example of which paradigm?', options: ['Divide and conquer', 'Dynamic programming', 'Greedy', 'Backtracking'], correctIndex: 2),
  QuizQuestion(question: 'Why is Selection Sort not adaptive?', options: ['Uses recursion', 'Time complexity does not improve for sorted arrays', 'Not stable', 'Needs extra space'], correctIndex: 1),
]);

const insertionSort = QuizSubtopicData(algorithm: 'Sorting', subtopic: 'Insertion Sort', questions: [
  QuizQuestion(question: 'Best case time complexity of Insertion Sort?', options: ['O(n²)', 'O(n log n)', 'O(n)', 'O(1)'], correctIndex: 2),
  QuizQuestion(question: 'Insertion Sort is most efficient when array is?', options: ['Completely reversed', 'Random', 'Nearly sorted', 'Very large'], correctIndex: 2),
  QuizQuestion(question: 'How does Insertion Sort work?', options: ['Divides and merges', 'Picks pivot', 'Builds sorted array by inserting each element at correct position', 'Finds minimum repeatedly'], correctIndex: 2),
  QuizQuestion(question: 'Is Insertion Sort stable?', options: ['No', 'Yes', 'Sometimes', 'Only for numbers'], correctIndex: 1),
  QuizQuestion(question: 'Worst case of Insertion Sort?', options: ['O(n)', 'O(n log n)', 'O(n²)', 'O(1)'], correctIndex: 2),
  QuizQuestion(question: 'Space complexity of Insertion Sort?', options: ['O(n)', 'O(n log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Insertion Sort is how humans sort?', options: ['Cards in a deck', 'Books in library', 'Files', 'Database records'], correctIndex: 0),
  QuizQuestion(question: 'Which sort uses Insertion Sort for small subarrays?', options: ['Merge Sort', 'Tim Sort', 'Radix Sort', 'Counting Sort'], correctIndex: 1),
  QuizQuestion(question: 'In Insertion Sort, how is the key placed?', options: ['Swapped with pivot', 'Shifted right until correct position found', 'Placed at end', 'Placed randomly'], correctIndex: 1),
  QuizQuestion(question: 'Insertion Sort on linked list is?', options: ['Not possible', 'O(n²) with O(1) space using pointer adjustments', 'O(n log n)', 'O(n)'], correctIndex: 1),
]);

const mergeSort = QuizSubtopicData(algorithm: 'Sorting', subtopic: 'Merge Sort', questions: [
  QuizQuestion(question: 'Time complexity of Merge Sort in all cases?', options: ['O(n²)', 'O(n)', 'O(n log n)', 'O(log n)'], correctIndex: 2),
  QuizQuestion(question: 'Space complexity of Merge Sort?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Is Merge Sort stable?', options: ['No', 'Yes', 'Depends', 'Only for integers'], correctIndex: 1),
  QuizQuestion(question: 'Merge Sort follows which paradigm?', options: ['Greedy', 'Dynamic Programming', 'Divide and Conquer', 'Backtracking'], correctIndex: 2),
  QuizQuestion(question: 'Merge Sort is preferred over Quick Sort for?', options: ['In-place sorting', 'Sorting linked lists', 'Average case speed', 'Small arrays'], correctIndex: 1),
  QuizQuestion(question: 'How many times does Merge Sort divide the array?', options: ['n times', 'log n times', 'n/2 times', 'n² times'], correctIndex: 1),
  QuizQuestion(question: 'Base case of Merge Sort recursion?', options: ['Array has 2 elements', 'Array is sorted', 'Array has 1 or 0 elements', 'Array has even size'], correctIndex: 2),
  QuizQuestion(question: 'Python built-in sort uses?', options: ['Pure Merge Sort', 'Quick Sort', 'Tim Sort (hybrid)', 'Counting Sort'], correctIndex: 2),
  QuizQuestion(question: 'External sorting (data on disk) uses?', options: ['Quick Sort', 'Bubble Sort', 'Merge Sort', 'Counting Sort'], correctIndex: 2),
  QuizQuestion(question: 'Recurrence relation for Merge Sort?', options: ['T(n) = T(n-1) + O(1)', 'T(n) = 2T(n/2) + O(n)', 'T(n) = T(n/2) + O(n)', 'T(n) = 2T(n-1) + O(1)'], correctIndex: 1),
]);

const quickSort = QuizSubtopicData(algorithm: 'Sorting', subtopic: 'Quick Sort', questions: [
  QuizQuestion(question: 'Average case time complexity of Quick Sort?', options: ['O(n²)', 'O(n)', 'O(n log n)', 'O(log n)'], correctIndex: 2),
  QuizQuestion(question: 'Worst case of Quick Sort happens when?', options: ['Array is random', 'Pivot is always median', 'Pivot is always min or max', 'Array has duplicates'], correctIndex: 2),
  QuizQuestion(question: 'Is Quick Sort stable?', options: ['Yes', 'No', 'Only with random pivot', 'Always'], correctIndex: 1),
  QuizQuestion(question: 'Space complexity of Quick Sort (average)?', options: ['O(n)', 'O(n²)', 'O(log n)', 'O(1)'], correctIndex: 2),
  QuizQuestion(question: 'Purpose of partitioning in Quick Sort?', options: ['Find minimum', 'Merge sorted halves', 'Place pivot in correct position with smaller left, larger right', 'Find median'], correctIndex: 2),
  QuizQuestion(question: 'Randomized Quick Sort picks pivot?', options: ['Always first', 'Always last', 'Randomly to avoid worst case', 'Always middle'], correctIndex: 2),
  QuizQuestion(question: 'Quick Sort is faster than Merge Sort in practice because?', options: ['Better worst case', 'Better cache locality', 'It is stable', 'Less comparisons always'], correctIndex: 1),
  QuizQuestion(question: 'Three-way Quick Sort handles?', options: ['Large arrays', 'Nearly sorted data', 'Arrays with many duplicates', 'Strings only'], correctIndex: 2),
  QuizQuestion(question: 'Lomuto partition scheme uses?', options: ['Two pointers from both ends', 'Pivot as last element with single pointer', 'Median pivot', 'Random pivot'], correctIndex: 1),
  QuizQuestion(question: 'Quick Sort is in-place using?', options: ['No — needs O(n) space', 'Yes — only O(log n) stack space', 'No — O(n log n) space', 'Yes — zero extra space'], correctIndex: 1),
]);

const heapSort = QuizSubtopicData(algorithm: 'Sorting', subtopic: 'Heap Sort', questions: [
  QuizQuestion(question: 'Time complexity of Heap Sort in all cases?', options: ['O(n²)', 'O(n)', 'O(n log n)', 'O(log n)'], correctIndex: 2),
  QuizQuestion(question: 'Space complexity of Heap Sort?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Is Heap Sort stable?', options: ['Yes', 'No', 'Sometimes', 'Only for integers'], correctIndex: 1),
  QuizQuestion(question: 'Heap Sort first builds a?', options: ['Min-Heap', 'Max-Heap', 'Binary Tree', 'BST'], correctIndex: 1),
  QuizQuestion(question: 'Why is Heap Sort not preferred over Quick Sort in practice?', options: ['Worse time complexity', 'Not in-place', 'Poor cache performance', 'Not stable'], correctIndex: 2),
  QuizQuestion(question: 'Building a heap (heapify) takes?', options: ['O(n log n)', 'O(n²)', 'O(n)', 'O(log n)'], correctIndex: 2),
  QuizQuestion(question: 'Operation repeated in Heap Sort after building max-heap?', options: ['Insert new element', 'Extract max and heapify', 'Merge two heaps', 'Rotate elements'], correctIndex: 1),
  QuizQuestion(question: 'Heap Sort places extracted max element where?', options: ['Front', 'Middle', 'End of unsorted portion', 'New array'], correctIndex: 2),
  QuizQuestion(question: 'Heap Sort gives sorted order?', options: ['Descending by default', 'Ascending from Max-Heap (extract max to end)', 'Random', 'Ascending from Min-Heap directly'], correctIndex: 1),
  QuizQuestion(question: 'Advantage of Heap Sort over Merge Sort?', options: ['Faster average', 'Stable', 'O(1) space (in-place)', 'Better cache'], correctIndex: 2),
]);

// ═══════════════ SEARCHING ═══════════════

const linearSearch = QuizSubtopicData(algorithm: 'Searching', subtopic: 'Linear Search', questions: [
  QuizQuestion(question: 'Time complexity of Linear Search?', options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Linear Search works on?', options: ['Only sorted arrays', 'Only unsorted arrays', 'Both sorted and unsorted', 'Only linked lists'], correctIndex: 2),
  QuizQuestion(question: 'Best case of Linear Search?', options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'], correctIndex: 3),
  QuizQuestion(question: 'In what data structure is Linear Search the only option?', options: ['Sorted array', 'Linked List (without extra info)', 'BST', 'Hash Table'], correctIndex: 1),
  QuizQuestion(question: 'What is Sentinel Search?', options: ['Binary search variant', 'Placing target at end to avoid bounds checking', 'Search with sentinels', 'Recursive linear search'], correctIndex: 1),
  QuizQuestion(question: 'Space complexity of Linear Search?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Worst case comparisons for n elements in linear search?', options: ['log n', 'n/2', 'n', 'n²'], correctIndex: 2),
  QuizQuestion(question: 'Linear Search is preferred when?', options: ['Array is large and sorted', 'Array is small or unsorted', 'Array has only integers', 'Array is linked'], correctIndex: 1),
  QuizQuestion(question: 'Average case of Linear Search?', options: ['O(1)', 'O(n/2) = O(n)', 'O(log n)', 'O(n²)'], correctIndex: 1),
  QuizQuestion(question: 'Linear Search on linked list returns?', options: ['Index', 'Address/reference', 'null if not found', 'Both B and C'], correctIndex: 3),
]);

const binarySearch = QuizSubtopicData(algorithm: 'Searching', subtopic: 'Binary Search', questions: [
  QuizQuestion(question: 'Prerequisite for Binary Search?', options: ['Array must be unsorted', 'Array must be sorted', 'Array must have unique elements', 'Array must be numeric'], correctIndex: 1),
  QuizQuestion(question: 'Time complexity of Binary Search?', options: ['O(n)', 'O(n²)', 'O(log n)', 'O(1)'], correctIndex: 2),
  QuizQuestion(question: 'Binary Search on 1024 elements — at most how many comparisons?', options: ['512', '32', '10', '1024'], correctIndex: 2),
  QuizQuestion(question: 'What does Binary Search return when element is not found?', options: ['0', '-1 or null', 'Last index', 'First index'], correctIndex: 1),
  QuizQuestion(question: 'In Binary Search, which index is checked first?', options: ['First', 'Last', 'Middle', 'Random'], correctIndex: 2),
  QuizQuestion(question: 'Space complexity of iterative Binary Search?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Safe mid formula?', options: ['(low + high) / 2', 'low + (high - low) / 2', 'high - low / 2', '(low × high) / 2'], correctIndex: 1),
  QuizQuestion(question: 'Binary Search can also find?', options: ['Only exact matches', 'First/last occurrence, lower/upper bound', 'Only in integer arrays', 'Only sorted linked lists'], correctIndex: 1),
  QuizQuestion(question: 'Binary Search on rotated sorted array requires?', options: ['Sorting first', 'Modified binary search to find pivot', 'Linear scan', 'Hashing'], correctIndex: 1),
  QuizQuestion(question: 'Which built-in uses Binary Search?', options: ['Python list.index()', 'Java Arrays.binarySearch()', 'C++ std::find()', 'All of above'], correctIndex: 1),
]);

const jumpSearch = QuizSubtopicData(algorithm: 'Searching', subtopic: 'Jump Search', questions: [
  QuizQuestion(question: 'Time complexity of Jump Search?', options: ['O(n)', 'O(log n)', 'O(√n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Optimal block size for Jump Search?', options: ['n/2', 'log n', '√n', 'n²'], correctIndex: 2),
  QuizQuestion(question: 'Jump Search requires the array to be?', options: ['Unsorted', 'Sorted', 'Unique', 'Numeric only'], correctIndex: 1),
  QuizQuestion(question: 'After jumping past target range, Jump Search does?', options: ['Binary search in block', 'Linear search backward in block', 'Restart from beginning', 'Jump again'], correctIndex: 1),
  QuizQuestion(question: 'Jump Search is better than Linear but worse than?', options: ['Bubble Sort', 'Binary Search', 'Insertion Sort', 'Selection Sort'], correctIndex: 1),
  QuizQuestion(question: 'Jump Search is optimal when?', options: ['Jumping backward is expensive (magnetic tape)', 'Array is unsorted', 'Array is tiny', 'Elements are strings'], correctIndex: 0),
  QuizQuestion(question: 'Space complexity of Jump Search?', options: ['O(n)', 'O(log n)', 'O(√n)', 'O(1)'], correctIndex: 3),
  QuizQuestion(question: 'If n = 100, jump step is?', options: ['5', '10', '7', '20'], correctIndex: 1),
  QuizQuestion(question: 'Jump Search when element not found returns?', options: ['Returns 0', 'Returns -1', 'Throws exception', 'Returns last index'], correctIndex: 1),
  QuizQuestion(question: 'Jump Search combines which two techniques?', options: ['Sort and search', 'Block jumping and linear search', 'Hashing and comparison', 'Recursion and iteration'], correctIndex: 1),
]);

const interpolationSearch = QuizSubtopicData(algorithm: 'Searching', subtopic: 'Interpolation Search', questions: [
  QuizQuestion(question: 'Average time complexity of Interpolation Search on uniform data?', options: ['O(n)', 'O(log n)', 'O(log log n)', 'O(√n)'], correctIndex: 2),
  QuizQuestion(question: 'Interpolation Search is analogous to?', options: ['Binary Search', 'Finding word in dictionary by estimated position', 'Linear Search', 'Hash lookup'], correctIndex: 1),
  QuizQuestion(question: 'Interpolation Search works best when data is?', options: ['Sorted and uniformly distributed', 'Random', 'Reverse sorted', 'Has many duplicates'], correctIndex: 0),
  QuizQuestion(question: 'Worst case time complexity of Interpolation Search?', options: ['O(log log n)', 'O(log n)', 'O(n)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Probe formula in Interpolation Search?', options: ['mid = (low + high) / 2', 'pos = low + ((target - arr[low]) × (high-low)) / (arr[high]-arr[low])', 'pos = low + √(high-low)', 'pos = high - low'], correctIndex: 1),
  QuizQuestion(question: 'Interpolation Search requires array to be?', options: ['Sorted', 'Unsorted', 'Only integers', 'Reverse sorted'], correctIndex: 0),
  QuizQuestion(question: 'Interpolation Search degrades to O(n) when?', options: ['Array is large', 'Data is exponentially distributed (non-uniform)', 'Array has even size', 'Target is at end'], correctIndex: 1),
  QuizQuestion(question: 'Interpolation Search beats Binary Search when?', options: ['Always', 'Data is uniformly distributed', 'Data is reverse sorted', 'Array is small'], correctIndex: 1),
  QuizQuestion(question: 'Space complexity of Interpolation Search?', options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'], correctIndex: 2),
  QuizQuestion(question: 'Interpolation Search assumes values are?', options: ['All positive', 'Uniformly spaced between arr[low] and arr[high]', 'All unique', 'All integers'], correctIndex: 1),
]);