import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/features/settings/domain/change_request_model.dart';

final Logger _logger = Logger('ChangeRequestService');

/// Submits Change Requests to the Cloudflare Worker.
class ChangeRequestService {
  const ChangeRequestService();

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
