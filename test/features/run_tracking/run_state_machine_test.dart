import 'package:flutter_test/flutter_test.dart';

import 'package:jara/features/run_tracking/domain/run_state_machine.dart';

void main() {
  group('RunState', () {
    test('idle state is idle', () {
      const state = RunState.idle();
      expect(state.isIdle, isTrue);
      expect(state.isRunning, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.isStopped, isFalse);
    });

    test('running state carries start time', () {
      final startTime = DateTime(2026, 8, 12, 10, 0);
      final running =
          RunState.running(startTime: startTime, distance: 0, pace: 0)
              as RunRunning;
      expect(running.startTime, startTime);
      expect(running.isRunning, isTrue);
    });

    test('paused state is paused', () {
      final state = RunState.paused(
        startTime: DateTime(2026, 8, 12, 10, 0),
        distance: 100,
        pace: 300,
      );
      expect(state.isPaused, isTrue);
      expect(state.isRunning, isFalse);
    });

    test('stopped state carries run ID', () {
      final state = RunState.stopped(runId: 'abc') as RunStopped;
      expect(state.runId, 'abc');
      expect(state.isStopped, isTrue);
    });

    test('running to paused preserves data', () {
      final startTime = DateTime(2026, 8, 12, 10, 0);
      final running =
          RunState.running(
                startTime: startTime,
                distance: 500,
                pace: 290,
                route: [(lat: 60.0, lon: 10.0, ts: startTime)],
              )
              as RunRunning;

      final paused =
          RunState.paused(
                startTime: running.startTime,
                distance: running.distance,
                pace: running.pace,
                route: running.route,
              )
              as RunPaused;

      expect(paused.distance, 500);
      expect(paused.pace, 290);
      expect(paused.route, hasLength(1));
    });
  });
}
