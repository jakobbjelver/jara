import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:jara/domain/repositories/settings_repository.dart';

/// Resolves the maintainer token attached to Change Request submissions.
///
/// The token is the ONLY maintainer signal (SELF-IMPROVEMENT.md §4) —
/// `kDebugMode` alone never tags a request as maintainer, because external
/// contributors run debug builds too.
///
/// Resolution order:
/// 1. `--dart-define=JARA_MAINTAINER_TOKEN=<token>` (CI / scripted runs).
/// 2. Release builds: the human token stored via the hidden Developer
///    section (Settings → About, tap version 7×).
/// 3. Debug builds: gitignored `maintainer_token.json` (agent token) in the
///    app documents directory, then — on the iOS simulator only — the
///    project checkout at `/Users/jakob/Repos/jara/maintainer_token.json`.
/// 4. Debug fallback: any token stored in preferences.
class MaintainerTokenResolver {
  const MaintainerTokenResolver();

  static const String fileName = 'maintainer_token.json';
  static const String _dartDefine =
      String.fromEnvironment('JARA_MAINTAINER_TOKEN');

  /// Project checkout path used by the maintainer's iOS simulator debug
  /// builds. Wrapped in try/catch — never throws, never blocks a submission.
  static const String _agentProjectPath = '/Users/jakob/Repos/jara';

  Future<String?> resolve(SettingsRepository repo) async {
    if (_dartDefine.isNotEmpty) return _dartDefine;

    if (!kDebugMode) {
      return repo.getMaintainerToken();
    }

    try {
      final docs = await getApplicationDocumentsDirectory();
      final file = File('${docs.path}/$fileName');
      if (await file.exists()) return _readToken(file);
    } catch (_) {
      // Documents directory unavailable — try the next source.
    }

    if (Platform.isIOS) {
      try {
        final file = File('$_agentProjectPath/$fileName');
        if (await file.exists()) return _readToken(file);
      } catch (_) {
        // Simulator host-path access unavailable — try preferences.
      }
    }

    return repo.getMaintainerToken();
  }

  Future<String?> _readToken(File file) async {
    try {
      final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final token = map['token'];
      return token is String && token.isNotEmpty ? token : null;
    } catch (_) {
      return null;
    }
  }
}
