import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/app.dart';

/// Entry point for the JARA running app.
///
/// Wraps the entire application tree in [ProviderScope] so that
/// all Riverpod providers are available downstream.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: JaraApp()));
}
