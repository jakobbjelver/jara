import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Convenience extensions on [BuildContext].
extension ContextExtensions on BuildContext {
  /// Shortcut for reading a riverpod provider.
  T read<T>(ProviderListenable<T> provider) =>
      ProviderScope.containerOf(this).read(provider);

  /// Shortcut for watching a riverpod provider.
  T watch<T>(ProviderListenable<T> provider) =>
      ProviderScope.containerOf(this).read(provider);
}

/// Convenience extensions on [WidgetRef] for common patterns.
extension WidgetRefExtensions on WidgetRef {
  /// Reads a provider (same as ref.read).
  T readProvider<T>(ProviderListenable<T> provider) => read(provider);

  /// Watches a provider (same as ref.watch).
  T watchProvider<T>(ProviderListenable<T> provider) => watch(provider);
}
