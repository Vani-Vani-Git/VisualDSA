import 'package:flutter/material.dart';
import 'language_dropdown.dart';

class CodeTabSection extends StatefulWidget {
  final String algorithm;
  const CodeTabSection({super.key, required this.algorithm});

  @override
  State<CodeTabSection> createState() => _CodeTabSectionState();
}

class _CodeTabSectionState extends State<CodeTabSection> {
  String _lang = 'Java';

  static const Map<String, Map<String, String>> _snippets = {
    'bubble_sort': {
      'Python': '''def bubble_sort(arr):
    n = len(arr)
    for i in range(n-1):
        for j in range(n-i-1):
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
    return arr''',
      'Java': '''void bubbleSort(int[] arr) {
    int n = arr.length;
    for (int i=0; i<n-1; i++) {
        for (int j=0; j<n-i-1; j++) {
            if (arr[j] > arr[j+1]) {
                int t = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = t;
            }
        }
    }
}''',
      'C': '''void bubbleSort(int arr[], int n) {
    for (int i=0; i<n-1; i++) {
        for (int j=0; j<n-i-1; j++) {
            if (arr[j] > arr[j+1]) {
                int t = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = t;
            }
        }
    }
}''',
      'C++': '''void bubbleSort(vector<int>& arr) {
    int n = arr.size();
    for (int i=0; i<n-1; i++)
        for (int j=0; j<n-i-1; j++)
            if (arr[j] > arr[j+1])
                swap(arr[j], arr[j+1]);
}''',
    },
    'selection_sort': {
      'Python': '''def selection_sort(arr):
    n = len(arr)
    for i in range(n-1):
        min_idx = i
        for j in range(i+1, n):
            if arr[j] < arr[min_idx]:
                min_idx = j
        arr[i], arr[min_idx] = arr[min_idx], arr[i]
    return arr''',
      'Java': '''void selectionSort(int[] arr) {
    int n = arr.length;
    for (int i=0; i<n-1; i++) {
        int min = i;
        for (int j=i+1; j<n; j++)
            if (arr[j] < arr[min]) min=j;
        int t=arr[i];
        arr[i]=arr[min];
        arr[min]=t;
    }
}''',
      'C': '''void selectionSort(int arr[], int n) {
    for (int i=0; i<n-1; i++) {
        int min = i;
        for (int j=i+1; j<n; j++)
            if (arr[j] < arr[min]) min=j;
        int t=arr[i];
        arr[i]=arr[min];
        arr[min]=t;
    }
}''',
      'C++': '''void selectionSort(vector<int>& arr) {
    int n = arr.size();
    for (int i=0; i<n-1; i++) {
        int min = i;
        for (int j=i+1; j<n; j++)
            if (arr[j] < arr[min]) min=j;
        swap(arr[i], arr[min]);
    }
}''',
    },
    'insertion_sort': {
      'Python': '''def insertion_sort(arr):
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        while j >= 0 and arr[j] > key:
            arr[j+1] = arr[j]
            j -= 1
        arr[j+1] = key
    return arr''',
      'Java': '''void insertionSort(int[] arr) {
    int n = arr.length;
    for (int i=1; i<n; i++) {
        int key = arr[i];
        int j = i-1;
        while (j>=0 && arr[j]>key) {
            arr[j+1] = arr[j];
            j--;
        }
        arr[j+1] = key;
    }
}''',
      'C': '''void insertionSort(int arr[], int n) {
    for (int i=1; i<n; i++) {
        int key = arr[i];
        int j = i-1;
        while (j>=0 && arr[j]>key) {
            arr[j+1] = arr[j];
            j--;
        }
        arr[j+1] = key;
    }
}''',
      'C++': '''void insertionSort(vector<int>& arr) {
    int n = arr.size();
    for (int i=1; i<n; i++) {
        int key = arr[i];
        int j = i-1;
        while (j>=0 && arr[j]>key) {
            arr[j+1] = arr[j];
            j--;
        }
        arr[j+1] = key;
    }
}''',
    },
    'merge_sort': {
      'Python': '''def merge_sort(arr):
    if len(arr) <= 1:
        return arr
    mid = len(arr) // 2
    L = merge_sort(arr[:mid])
    R = merge_sort(arr[mid:])
    i = j = k = 0
    while i<len(L) and j<len(R):
        if L[i] <= R[j]:
            arr[k] = L[i]; i+=1
        else:
            arr[k] = R[j]; j+=1
        k+=1
    arr[k:] = L[i:] or R[j:]
    return arr''',
      'Java': '''void mergeSort(int[] arr, int l, int r) {
    if (l >= r) return;
    int mid = (l+r)/2;
    mergeSort(arr, l, mid);
    mergeSort(arr, mid+1, r);
    merge(arr, l, mid, r);
}
void merge(int[] a, int l, int m, int r) {
    int[] L=Arrays.copyOfRange(a,l,m+1);
    int[] R=Arrays.copyOfRange(a,m+1,r+1);
    int i=0,j=0,k=l;
    while(i<L.length&&j<R.length)
        a[k++]=L[i]<=R[j]?L[i++]:R[j++];
    while(i<L.length) a[k++]=L[i++];
    while(j<R.length) a[k++]=R[j++];
}''',
      'C': '''void merge(int a[],int l,int m,int r){
    int nL=m-l+1, nR=r-m;
    int L[nL], R[nR];
    for(int i=0;i<nL;i++) L[i]=a[l+i];
    for(int j=0;j<nR;j++) R[j]=a[m+1+j];
    int i=0,j=0,k=l;
    while(i<nL&&j<nR)
        a[k++]=L[i]<=R[j]?L[i++]:R[j++];
    while(i<nL) a[k++]=L[i++];
    while(j<nR) a[k++]=R[j++];
}
void mergeSort(int a[],int l,int r){
    if(l<r){int m=(l+r)/2;
        mergeSort(a,l,m);
        mergeSort(a,m+1,r);
        merge(a,l,m,r);}
}''',
      'C++': '''void mergeSort(vector<int>& a,int l,int r){
    if(l>=r) return;
    int m=(l+r)/2;
    mergeSort(a,l,m);
    mergeSort(a,m+1,r);
    vector<int> L(a.begin()+l,a.begin()+m+1);
    vector<int> R(a.begin()+m+1,a.begin()+r+1);
    int i=0,j=0,k=l;
    while(i<L.size()&&j<R.size())
        a[k++]=L[i]<=R[j]?L[i++]:R[j++];
    while(i<L.size()) a[k++]=L[i++];
    while(j<R.size()) a[k++]=R[j++];
}''',
    },
    'quick_sort': {
      'Python': '''def quick_sort(arr, low, high):
    if low < high:
        pi = partition(arr, low, high)
        quick_sort(arr, low, pi-1)
        quick_sort(arr, pi+1, high)

def partition(arr, low, high):
    pivot = arr[high]
    i = low - 1
    for j in range(low, high):
        if arr[j] <= pivot:
            i += 1
            arr[i], arr[j] = arr[j], arr[i]
    arr[i+1], arr[high] = arr[high], arr[i+1]
    return i + 1''',
      'Java': '''void quickSort(int[] arr, int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        quickSort(arr, low, pi-1);
        quickSort(arr, pi+1, high);
    }
}
int partition(int[] arr, int low, int high) {
    int pivot = arr[high], i = low-1;
    for (int j=low; j<high; j++)
        if (arr[j]<=pivot) {
            i++;
            int t=arr[i];arr[i]=arr[j];arr[j]=t;
        }
    int t=arr[i+1];arr[i+1]=arr[high];arr[high]=t;
    return i+1;
}''',
      'C': '''int partition(int a[],int l,int h){
    int p=a[h],i=l-1;
    for(int j=l;j<h;j++)
        if(a[j]<=p){i++;
            int t=a[i];a[i]=a[j];a[j]=t;}
    int t=a[i+1];a[i+1]=a[h];a[h]=t;
    return i+1;
}
void quickSort(int a[],int l,int h){
    if(l<h){int pi=partition(a,l,h);
        quickSort(a,l,pi-1);
        quickSort(a,pi+1,h);}
}''',
      'C++': '''int partition(vector<int>& a,int l,int h){
    int p=a[h],i=l-1;
    for(int j=l;j<h;j++)
        if(a[j]<=p) swap(a[++i],a[j]);
    swap(a[i+1],a[h]);
    return i+1;
}
void quickSort(vector<int>& a,int l,int h){
    if(l<h){int pi=partition(a,l,h);
        quickSort(a,l,pi-1);
        quickSort(a,pi+1,h);}
}''',
    },
  };

  static const _keywords = [
    'def', 'return', 'for', 'if', 'in', 'range', 'while', 'else', 'and', 'or',
    'void', 'int', 'vector', 'swap', 'Arrays', 'copyOfRange',
    'true', 'false', 'null', 'new', 'class',
  ];

  List<TextSpan> _colorize(String line) {
    final spans = <TextSpan>[];
    final tokenRegex = RegExp(r'([A-Za-z_]\w*|\d+|[^\w\s]|\s+)');
    for (final m in tokenRegex.allMatches(line)) {
      final token = m.group(0)!;
      Color color;
      if (_keywords.contains(token.trim())) {
        color = const Color(0xFFC084FC);
      } else if (RegExp(r'^\d+$').hasMatch(token.trim())) {
        color = const Color(0xFFFB923C);
      } else if (token.trim().startsWith('//') || token.trim().startsWith('#')) {
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
            onChanged: (l) => setState(() => _lang = l),
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