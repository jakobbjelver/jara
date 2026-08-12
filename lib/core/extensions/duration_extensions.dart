import 'package:intl/intl.dart';

/// Formatting extensions for [Duration].
extension DurationExtensions on Duration {
  /// Formats as HH:MM:SS for durations >= 1 hour, MM:SS otherwise.
  String formatDuration() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats as a compact string: "1h 23m" or "45m 12s".
  String formatCompact() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    final seconds = inSeconds.remainder(60);
    if (minutes > 0 && seconds > 0) return '${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m';
    return '${seconds}s';
  }
}

/// Formatting extensions for numeric values.
extension NumericExtensions on double {
  /// Formats distance in kilometers with 2 decimal places.
  String formatKm() => '${toStringAsFixed(2)} km';

  /// Formats distance in meters with no decimal places.
  String formatMeters() => '${round()} m';

  /// Formats pace as MM:SS per km.
  String formatPacePerKm() {
    if (this <= 0 || isNaN || isInfinite) return '--:--';
    final totalSeconds = this; // pace in seconds per km
    final minutes = (totalSeconds / 60).floor();
    final seconds = (totalSeconds % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /km';
  }

  /// Formats pace as MM:SS per mile.
  String formatPacePerMile() {
    if (this <= 0 || isNaN || isInfinite) return '--:--';
    final totalSeconds = this * 1.60934; // convert km pace to mile pace
    final minutes = (totalSeconds / 60).floor();
    final seconds = (totalSeconds % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /mi';
  }
}

/// Date formatting for run history.
class DateFormatter {
  DateFormatter._();

  static final _dayFormat = DateFormat('EEE, MMM d');
  static final _monthFormat = DateFormat('MMMM yyyy');
  static final _timeFormat = DateFormat('h:mm a');
  static final _fullFormat = DateFormat('MMM d, yyyy – h:mm a');
  static final _isoFormat = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime date) => _dayFormat.format(date);

  static String formatMonth(DateTime date) => _monthFormat.format(date);

  static String formatTime(DateTime date) => _timeFormat.format(date);

  static String formatFull(DateTime date) => _fullFormat.format(date);

  static String formatIso(DateTime date) => _isoFormat.format(date);
}
