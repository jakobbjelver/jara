/// Sort options for the run history list.
enum RunSortFilter {
  /// Most recent runs first (default).
  newest,

  /// Oldest runs first.
  oldest,

  /// Longest distance first.
  longest,

  /// Fastest pace first.
  fastest;

  /// Human-readable label for UI display.
  String get label {
    switch (this) {
      case RunSortFilter.newest:
        return 'Newest';
      case RunSortFilter.oldest:
        return 'Oldest';
      case RunSortFilter.longest:
        return 'Longest';
      case RunSortFilter.fastest:
        return 'Fastest';
    }
  }

  /// Returns a comparison function that orders runs according to this filter.
  ///
  /// Both [newest] and [oldest] sort by `startTime`. [longest] sorts by
  /// `distanceMeters` descending, then by `startTime` as a tiebreaker.
  /// [fastest] sorts by `avgPaceSecondsPerKm` ascending (faster = lower),
  /// falling back to `startTime` for runs missing pace data.
  int Function(T a, T b) comparator<T>(
    DateTime Function(T) startTime,
    double? Function(T) distanceMeters,
    double? Function(T) avgPaceSecondsPerKm,
  ) {
    switch (this) {
      case RunSortFilter.newest:
        return (a, b) => startTime(b).compareTo(startTime(a));
      case RunSortFilter.oldest:
        return (a, b) => startTime(a).compareTo(startTime(b));
      case RunSortFilter.longest:
        return (a, b) {
          final distA = distanceMeters(a) ?? 0;
          final distB = distanceMeters(b) ?? 0;
          final distCmp = distB.compareTo(distA);
          if (distCmp != 0) return distCmp;
          return startTime(b).compareTo(startTime(a));
        };
      case RunSortFilter.fastest:
        return (a, b) {
          final paceA = avgPaceSecondsPerKm(a);
          final paceB = avgPaceSecondsPerKm(b);
          if (paceA != null && paceB != null) {
            final paceCmp = paceA.compareTo(paceB);
            if (paceCmp != 0) return paceCmp;
          } else if (paceA != null) {
            return -1;
          } else if (paceB != null) {
            return 1;
          }
          return startTime(b).compareTo(startTime(a));
        };
    }
  }
}
