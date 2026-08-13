import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/app.dart';
import 'package:jara/core/utils/log_ring_buffer.dart';
import 'package:jara/data/data_sources/background_location_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LogRingBuffer.instance.initialize();
  BackgroundLocationService.initialize();
  runApp(const ProviderScope(child: JaraApp()));
}
