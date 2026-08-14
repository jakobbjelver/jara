import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/features/settings/domain/change_request_model.dart';

final Logger _logger = Logger('ChangeRequestService');

/// Submits Change Requests to the Cloudflare Worker.
class ChangeRequestService {
  const ChangeRequestService();

  /// Uploads a screenshot (png/jpeg/webp bytes) to the worker's R2 store.
  ///
  /// Returns the public screenshot URL on success, or null. The URL is sent
  /// later as `screenshot_url` in [submit]. ADR-009: worker-mediated upload —
  /// no presigned S3 flow, bucket stays private.
  Future<String?> uploadScreenshot({
    required List<int> bytes,
    required String contentType,
    required String deviceToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppEndpoints.screenshotUpload),
        headers: {
          'Content-Type': contentType,
          'X-Jara-Device-Token': deviceToken,
        },
        body: bytes,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final url = data['screenshot_url'] as String?;
        if (url != null && url.isNotEmpty) return url;
        _logger.warning('Screenshot upload 201 but no URL in response');
        return null;
      }
      _logger.warning(
        'Screenshot upload failed with HTTP ${response.statusCode}',
      );
      return null;
    } catch (e) {
      _logger.severe('Screenshot upload error', e);
      return null;
    }
  }

  /// Fetches this device's own change requests with their triage status —
  /// the in-app status screen ("My Reports"). The device token is the
  /// capability; no other auth.
  Future<List<ChangeRequestReport>> fetchMyReports(String deviceToken) async {
    try {
      final uri = Uri.parse(
        AppEndpoints.changeRequestsByToken,
      ).replace(queryParameters: {'device_token': deviceToken});
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        _logger.warning(
          'fetchMyReports failed with HTTP ${response.statusCode}',
        );
        throw ChangeRequestFetchException(
          'Server error: ${response.statusCode}',
        );
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = (data['change_requests'] as List<dynamic>? ?? []);
      return rows
          .map((r) => ChangeRequestReport.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.severe('fetchMyReports error', e);
      if (e is ChangeRequestFetchException) rethrow;
      throw const ChangeRequestFetchException('Network error');
    }
  }

  /// Submits a Change Request. Returns the ID if successful.
  ///
  /// [maintainerToken] is the ONLY maintainer signal (SELF-IMPROVEMENT.md §4):
  /// when present it is sent as the `X-Jara-Maintainer` header and the worker
  /// maps it to a maintainer role. Absent → plain end-user intake.
  Future<ChangeRequestResult> submit(
    ChangeRequest request, {
    String? maintainerToken,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (maintainerToken != null && maintainerToken.isNotEmpty) {
      headers['X-Jara-Maintainer'] = maintainerToken;
    }

    _logger.info('Submitting ${request.type} change request');

    try {
      final response = await http.post(
        Uri.parse(AppEndpoints.changeRequest),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final id = data['id'] as String?;
        final status = data['status'] as String?;
        _logger.info('Change request ${status ?? 'received'}: $id');
        return ChangeRequestResult.success(id, status);
      } else if (response.statusCode == 429) {
        _logger.warning('Change request rate limited');
        return ChangeRequestResult.rateLimited();
      } else {
        _logger.warning(
          'Change request failed with HTTP ${response.statusCode}',
        );
        return ChangeRequestResult.failure(
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Change request submission error', e);
      return ChangeRequestResult.failure(e.toString());
    }
  }
}

/// Result of a Change Request submission.
sealed class ChangeRequestResult {
  const ChangeRequestResult._();

  const factory ChangeRequestResult.success(String? id, String? status) =
      _Success;
  const factory ChangeRequestResult.failure(String message) = _Failure;
  const factory ChangeRequestResult.rateLimited() = _RateLimited;

  bool get isSuccess => this is _Success;
  bool get isDuplicate =>
      this is _Success && (this as _Success).status == 'duplicate';
  String? get id => this is _Success ? (this as _Success).id : null;
  String? get error => this is _Failure ? (this as _Failure).message : null;
}

class _Success extends ChangeRequestResult {
  @override
  final String? id;
  final String? status;
  const _Success(this.id, this.status) : super._();
}

class _Failure extends ChangeRequestResult {
  final String message;
  const _Failure(this.message) : super._();
}

class _RateLimited extends ChangeRequestResult {
  const _RateLimited() : super._();
}

/// A change request as returned by GET /change-requests/by-token — the
/// in-app status screen ("My Reports").
class ChangeRequestReport {
  final String id;
  final String type; // 'bug' | 'feature'
  final String title;
  final String status; // 'pending' | 'triaged' | 'duplicate' | 'rejected'
  final int? githubIssueNumber;
  final String? githubIssueUrl;
  final DateTime? createdAt;
  final DateTime? triagedAt;

  const ChangeRequestReport({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    this.githubIssueNumber,
    this.githubIssueUrl,
    this.createdAt,
    this.triagedAt,
  });

  factory ChangeRequestReport.fromJson(Map<String, dynamic> json) {
    return ChangeRequestReport(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'bug',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      githubIssueNumber: json['github_issue_number'] as int?,
      githubIssueUrl: json['github_issue_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      triagedAt: DateTime.tryParse(json['triaged_at'] as String? ?? ''),
    );
  }
}

/// Thrown when the by-token status fetch fails (server or network).
class ChangeRequestFetchException implements Exception {
  final String message;
  const ChangeRequestFetchException(this.message);

  @override
  String toString() => message;
}
