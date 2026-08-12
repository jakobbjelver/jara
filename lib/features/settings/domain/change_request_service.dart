import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/features/settings/domain/change_request_model.dart';

/// Submits Change Requests to the Cloudflare Worker.
class ChangeRequestService {
  const ChangeRequestService();

  /// Submits a Change Request. Returns the ID if successful.
  Future<ChangeRequestResult> submit(ChangeRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(AppEndpoints.changeRequest),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ChangeRequestResult.success(data['id'] as String?);
      } else if (response.statusCode == 429) {
        return ChangeRequestResult.rateLimited();
      } else {
        return ChangeRequestResult.failure(
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ChangeRequestResult.failure(e.toString());
    }
  }
}

/// Result of a Change Request submission.
sealed class ChangeRequestResult {
  const ChangeRequestResult._();

  const factory ChangeRequestResult.success(String? id) = _Success;
  const factory ChangeRequestResult.failure(String message) = _Failure;
  const factory ChangeRequestResult.rateLimited() = _RateLimited;

  bool get isSuccess => this is _Success;
  String? get id => this is _Success ? (this as _Success).id : null;
  String? get error => this is _Failure ? (this as _Failure).message : null;
}

class _Success extends ChangeRequestResult {
  @override
  final String? id;
  const _Success(this.id) : super._();
}

class _Failure extends ChangeRequestResult {
  final String message;
  const _Failure(this.message) : super._();
}

class _RateLimited extends ChangeRequestResult {
  const _RateLimited() : super._();
}
