import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/use_cases/delete_run.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Loads a single run by ID.
final runDetailProvider = FutureProvider.family<Run?, String>((ref, id) async {
  final repo = ref.watch(runRepositoryProvider);
  return repo.getRun(id);
});

/// Provides the [DeleteRun] use case for this feature.
final deleteRunForDetailProvider = Provider<DeleteRun>((ref) {
  final repo = ref.watch(runRepositoryProvider);
  return DeleteRun(repo);
});
