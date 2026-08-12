/// States for the run tracking state machine.
///
/// Follows the state machine diagram from the plan:
///   idle → running → paused → stopped (→ /run/:id)
sealed class RunState {
  const RunState();

  const factory RunState.idle() = RunIdle;
  const factory RunState.running({
    required DateTime startTime,
    double distance,
    double pace,
    List<({double lat, double lon, DateTime ts})> route,
  }) = RunRunning;
  const factory RunState.paused({
    required DateTime startTime,
    double distance,
    double pace,
    List<({double lat, double lon, DateTime ts})> route,
  }) = RunPaused;
  const factory RunState.stopped({required String runId}) = RunStopped;

  bool get isIdle => this is RunIdle;
  bool get isRunning => this is RunRunning;
  bool get isPaused => this is RunPaused;
  bool get isStopped => this is RunStopped;
}

class RunIdle extends RunState {
  const RunIdle();
}

class RunRunning extends RunState {
  final DateTime startTime;
  final double distance;
  final double pace;
  final List<({double lat, double lon, DateTime ts})> route;

  const RunRunning({
    required this.startTime,
    this.distance = 0,
    this.pace = 0,
    this.route = const [],
  });
}

class RunPaused extends RunState {
  final DateTime startTime;
  final double distance;
  final double pace;
  final List<({double lat, double lon, DateTime ts})> route;

  const RunPaused({
    required this.startTime,
    this.distance = 0,
    this.pace = 0,
    this.route = const [],
  });
}

class RunStopped extends RunState {
  final String runId;

  const RunStopped({required this.runId});
}
