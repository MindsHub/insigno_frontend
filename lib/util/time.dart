String formatDuration(Duration duration) {
  final negative = duration.isNegative;
  if (negative) {
    duration = -duration;
  }

  final hours = (duration.inHours == 0) ? "" : "${duration.inHours.toString()}:";
  final minutes = duration.inMinutes.remainder(60).toString();
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "${negative ? "-" : ""}$hours${duration.inHours == 0 ? minutes : minutes.padLeft(2, '0')}:$seconds";
}
