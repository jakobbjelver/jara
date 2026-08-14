import 'package:flutter_test/flutter_test.dart';

import 'package:jara/features/settings/domain/change_request_service.dart';

void main() {
  group('ChangeRequestReport.fromJson', () {
    test('parses a full triaged row', () {
      final report = ChangeRequestReport.fromJson({
        'id': 'a1b2c3d4',
        'type': 'bug',
        'title': 'Pace chart wrong',
        'status': 'triaged',
        'screenshot_url':
            'https://api.jara.messerstudios.dev/screenshots/x.png',
        'github_issue_number': 7,
        'github_issue_url': 'https://github.com/jakobbjelver/jara/issues/7',
        'created_at': '2026-08-14T08:00:00.000Z',
        'triaged_at': '2026-08-14T09:00:00.000Z',
      });

      expect(report.id, 'a1b2c3d4');
      expect(report.type, 'bug');
      expect(report.title, 'Pace chart wrong');
      expect(report.status, 'triaged');
      expect(report.githubIssueNumber, 7);
      expect(report.githubIssueUrl, endsWith('/issues/7'));
      expect(report.createdAt, isNotNull);
      expect(report.triagedAt, isNotNull);
    });

    test('parses a minimal pending row with nulls', () {
      final report = ChangeRequestReport.fromJson({
        'id': 'x',
        'type': 'feature',
        'title': 'Dark theme',
        'status': 'pending',
        'created_at': null,
        'triaged_at': null,
      });

      expect(report.status, 'pending');
      expect(report.githubIssueNumber, isNull);
      expect(report.githubIssueUrl, isNull);
      expect(report.createdAt, isNull);
      expect(report.triagedAt, isNull);
    });

    test('tolerates missing fields entirely', () {
      final report = ChangeRequestReport.fromJson(const {});

      expect(report.id, '');
      expect(report.type, 'bug');
      expect(report.title, '');
      expect(report.status, 'pending');
    });
  });

  group('ChangeRequestFetchException', () {
    test('carries its message', () {
      const e = ChangeRequestFetchException('Server error: 500');
      expect(e.message, 'Server error: 500');
      expect(e.toString(), 'Server error: 500');
    });
  });
}
