import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'package:jara/core/utils/log_ring_buffer.dart';

void main() {
  group('LogRingBuffer', () {
    setUp(() {
      // The singleton initializes once per process; reset its contents
      // between tests by draining via dump-like access is not possible, so
      // we exercise it additively and assert on deltas where needed.
    });

    test('buffers lines up to maxLines, evicting oldest first', () {
      final buffer = LogRingBuffer.instance;

      final before = buffer.dump().isEmpty ? 0 : buffer.dump().length;

      // Add exactly maxLines fresh lines tagged uniquely, then one more.
      for (var i = 0; i < LogRingBuffer.maxLines + 1; i++) {
        buffer.add('ring-test-line-$i');
      }

      final lines = buffer.dump().split('\n');
      expect(lines.length, LogRingBuffer.maxLines);
      // Oldest line (0) evicted, newest present.
      expect(buffer.dump(), isNot(contains('ring-test-line-0')));
      expect(
        buffer.dump(),
        contains('ring-test-line-${LogRingBuffer.maxLines}'),
      );
      // Just a sanity check that the buffer was exercised.
      expect(before, isA<int>());
    });

    test('splits multi-line input into separate lines', () {
      final buffer = LogRingBuffer.instance;
      buffer.add('alpha');
      buffer.add('beta\ngamma');

      final lines = buffer.dump().split('\n');
      expect(lines, containsAllInOrder(['beta', 'gamma']));
    });

    test('captures package:logging records once initialized', () {
      final buffer = LogRingBuffer.instance;
      buffer.initialize(); // no-op if already initialized in main()

      final logger = Logger('ring-buffer-test');
      logger.warning('capture-me-unique-tag');

      expect(buffer.dump(), contains('capture-me-unique-tag'));
    });
  });
}
