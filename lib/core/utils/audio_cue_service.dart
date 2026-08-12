import 'package:audioplayers/audioplayers.dart';

import 'package:jara/domain/repositories/settings_repository.dart';

/// Plays audio cues during a run at the configured interval.
///
/// V1 cues are short beep tones — spoken announcements (time/distance/pace)
/// arrive with TTS in a later version. Frequency comes from the
/// [SettingsRepository] audio cue setting (0 = off, 1 = 30s, 2 = 1min,
/// 3 = 1km, 4 = 5min).
class AudioCueService {
  final AudioPlayer _player = AudioPlayer();

  /// Tracks which cue code was last announced to avoid repeats.
  int _lastCue = -1;

  AudioCueService();

  /// Plays the cue for the given interval code, if it changed since last time.
  Future<void> playCueFor(int intervalCode) async {
    if (_lastCue == intervalCode) return;
    _lastCue = intervalCode;
    await _beep();
  }

  /// Plays a single beep tone.
  Future<void> _beep() async {
    await _player.play(AssetSource('sounds/cue_beep.wav'));
  }

  /// Resets the dedup tracker (called at run start).
  void reset() {
    _lastCue = -1;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
