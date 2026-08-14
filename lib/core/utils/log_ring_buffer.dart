import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// In-memory ring buffer of the most recent app log lines.
///
/// Purpose (GOAL.md §8.1 / PLAN-002 §1.9): Change Requests can attach the
/// last ~200 log lines so the triage agent gets diagnostic context — but only
/// with the user's consent (visible toggle, default on). Debug builds attach
/// logs automatically (maintainer-route advantage).
///
/// Feeds:
/// - `package:logging` records (root logger, all levels)
/// - Flutter framework errors (`FlutterError.onError`)
/// - Platform/engine errors (`PlatformDispatcher.onError`)
/// - `debugPrint` output (preserves default printing behavior)
class LogRingBuffer {
  LogRingBuffer._();

  /// Process-wide singleton, initialized once from `main()`.
  static final LogRingBuffer instance = LogRingBuffer._();

  /// Target capacity — old lines drop first when exceeded.
  static const int maxLines = 200;

  final Queue<String> _lines = Queue<String>();
  bool _initialized = false;

  /// Attaches listeners to the root logger, error handlers, and debugPrint.
  /// Safe to call multiple times — subsequent calls are no-ops.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      add(
        '${record.time.toIso8601String()} '
        '[${record.level.name}] ${record.loggerName}: ${record.message}',
      );
    });

    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) add(message);
      originalDebugPrint(message, wrapWidth: wrapWidth);
    };

    FlutterError.onError = (details) {
      add('FLUTTER ERROR: ${details.exceptionAsString()}');
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      add('PLATFORM ERROR: $error');
      return false; // keep the default handler as well
    };
  }

  /// Appends one line, evicting the oldest when at capacity.
  void add(String line) {
    for (final trimmed in line.split('\n')) {
      if (_lines.length >= maxLines) _lines.removeFirst();
      _lines.add(trimmed);
    }
  }

  /// Returns the buffered lines joined by newlines (empty string if none).
  String dump() => _lines.join('\n');
}
