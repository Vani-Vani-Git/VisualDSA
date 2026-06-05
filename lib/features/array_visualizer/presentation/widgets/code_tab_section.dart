import 'package:flutter/material.dart';
import 'language_dropdown.dart';

class CodeTabSection extends StatefulWidget {

  final String operation;

  final Function(String)
      onLanguageChanged;

  const CodeTabSection({

    super.key,

    required this.operation,

    required this.onLanguageChanged,
  });

  @override
  State<CodeTabSection> createState() =>
      _CodeTabSectionState();
}

class _CodeTabSectionState
    extends State<CodeTabSection> {

  String _language = 'Python';

  static const _snippets = {

    'insert': {

      'Python':

          'def insert(arr, val, i):\n    arr.insert(i, val)\n    return arr',

      'Java':

          'void insert(int[] arr, int val, int i) {\n    for(int k=arr.length-1; k>i; k--)\n        arr[k] = arr[k-1];\n    arr[i] = val;\n}',

      'C':

          'void insert(int arr[], int *n, int val, int i) {\n    for(int k=*n; k>i; k--)\n        arr[k] = arr[k-1];\n    arr[i] = val;\n    (*n)++;\n}',

      'C++':

          'void insert(vector<int>& arr, int val, int i) {\n    arr.insert(arr.begin()+i, val);\n}',
    },

    'update': {

      'Python':

          'def update(arr, val, i):\n    arr[i] = val\n    return arr',

      'Java':

          'void update(int[] arr, int val, int i) {\n    arr[i] = val;\n}',

      'C':

          'void update(int arr[], int val, int i) {\n    arr[i] = val;\n}',

      'C++':

          'void update(vector<int>& arr, int val, int i) {\n    arr[i] = val;\n}',
    },

    'delete': {

      'Python':

          'def delete(arr, i):\n    arr.pop(i)\n    return arr',

      'Java':

          'int[] delete(int[] arr, int i) {\n    for(int k=i; k<arr.length-1; k++)\n        arr[k] = arr[k+1];\n    return arr;\n}',

      'C':

          'void delete(int arr[], int *n, int i) {\n    for(int k=i; k<*n-1; k++)\n        arr[k] = arr[k+1];\n    (*n)--;\n}',

      'C++':

          'void deleteAt(vector<int>& arr, int i) {\n    arr.erase(arr.begin()+i);\n}',
    },

    'sort': {

      'Python':

          'def sort(arr):\n    n = len(arr)\n    for i in range(n-1):\n        for j in range(n-i-1):\n            if arr[j] > arr[j+1]:\n                arr[j], arr[j+1] = arr[j+1], arr[j]\n    return arr',

      'Java':

          'void Sort(int[] arr) {\n    int n = arr.length;\n    for(int i=0; i<n-1; i++)\n        for(int j=0; j<n-i-1; j++)\n            if(arr[j] > arr[j+1]) {\n                int t = arr[j];\n                arr[j] = arr[j+1];\n                arr[j+1] = t;\n            }\n}',

      'C':

          'void Sort(int arr[], int n) {\n    for(int i=0; i<n-1; i++)\n        for(int j=0; j<n-i-1; j++)\n            if(arr[j] > arr[j+1]) {\n                int t = arr[j];\n                arr[j] = arr[j+1];\n                arr[j+1] = t;\n            }\n}',

      'C++':

          'void Sort(vector<int>& arr) {\n    int n = arr.size();\n    for(int i=0; i<n-1; i++)\n        for(int j=0; j<n-i-1; j++)\n            if(arr[j] > arr[j+1])\n                swap(arr[j], arr[j+1]);\n}',
    },
  };

  static const _keywords = [

    'def',
    'return',
    'for',
    'if',
    'in',
    'range',
    'void',
    'int',
    'vector',
    'swap',
    'insert',
    'erase',
    'pop',
    'len',
    'size',
    'while',
    'else',
    'class',
    'new',
    'null',
  ];

  List<TextSpan> _colorize(String line) {

    final spans = <TextSpan>[];

    final tokenRegex = RegExp(

      r'(\d+|[A-Za-z_]\w*|[^A-Za-z0-9_\s])|\s+',
    );

    for (final match
        in tokenRegex.allMatches(line)) {

      final token = match.group(0)!;

      Color color =
          const Color(0xFFE2E8F0);

      if (_keywords.contains(
          token.trim())) {

        color =
            const Color(0xFFC084FC);

      } else if (RegExp(r'^\\d+\$')
          .hasMatch(token.trim())) {

        color =
            const Color(0xFFFB923C);
      }

      spans.add(

        TextSpan(

          text: token,

          style: TextStyle(
            color: color,
          ),
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {

    final code =
        _snippets[
                widget.operation]
            ?[_language] ??

            '// Not available';

    final lines = code.split('\n');

    return Padding(

      padding:
          const EdgeInsets.only(
              top: 12),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          LanguageDropdown(

            selected: _language,

            onChanged: (l) {

              setState(() {

                _language = l;
              });

              widget.onLanguageChanged(
                  l);
            },
          ),

          const SizedBox(height: 10),

          Container(

            width: double.infinity,

            padding:
                const EdgeInsets.all(14),

            decoration: BoxDecoration(

              color:
                  const Color(0xFF161B22),

              border: Border.all(

                color:
                    const Color(
                        0xFF21262D),
              ),

              borderRadius:
                  BorderRadius.circular(
                      10),
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: List.generate(

                lines.length,

                (i) {

                  return Padding(

                    padding:
                        const EdgeInsets.only(
                      bottom: 2,
                    ),

                    child: Row(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        SizedBox(

                          width: 20,

                          child: Text(

                            '${i + 1}',

                            style:
                                const TextStyle(

                              color:
                                  Color(
                                      0xFFEF4444),

                              fontSize: 12,

                              fontFamily:
                                  'monospace',
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 8),

                        Expanded(

                          child: RichText(

                            text: TextSpan(

                              style:
                                  const TextStyle(

                                fontSize: 12.5,

                                fontFamily:
                                    'monospace',

                                height: 1.6,
                              ),

                              children:
                                  _colorize(
                                      lines[i]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}