/// Represents one animation frame of a search algorithm.
///
/// [array]       — current array snapshot (may be reordered for display)
/// [currentIdx]  — index being actively probed / compared right now
/// [foundIdx]    — index where target was found (null until found)
/// [eliminatedIndices] — indices greyed out (binary search discards)
/// [low]         — binary search low pointer
/// [high]        — binary search high pointer
/// [mid]         — binary search mid pointer
/// [jumpBlocks]  — list of jump-block boundary indices (jump search arcs)
/// [linearScanRange] — [start,end] for jump search linear back-scan
/// [stepNumber]  — human-readable step counter (1-based)
/// [statusMsg]   — description shown above the array
/// [phase]       — 'comparing' | 'found' | 'not_found' | 'jumping' | 'scanning'
class SearchStep {
  final List<int> array;
  final int? currentIdx;
  final int? foundIdx;
  final Set<int> eliminatedIndices;
  final int? low;
  final int? high;
  final int? mid;
  final List<int> jumpBlocks;       // boundary indices visited by jump search
  final List<int>? linearScanRange; // [start, end] inclusive
  final int stepNumber;
  final String statusMsg;
  final String phase;

  const SearchStep({
    required this.array,
    this.currentIdx,
    this.foundIdx,
    this.eliminatedIndices = const {},
    this.low,
    this.high,
    this.mid,
    this.jumpBlocks = const [],
    this.linearScanRange,
    this.stepNumber = 0,
    this.statusMsg = '',
    this.phase = 'comparing',
  });
}