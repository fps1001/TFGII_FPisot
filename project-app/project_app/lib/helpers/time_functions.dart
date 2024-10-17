String formatDuration(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;

  if (hours > 0) {
    return '$hours horas $minutes minutos';
  } else {
    return '$minutes minutos';
  }
}

String formatDistance(double meters) {
  if (meters >= 1000) {
    double kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(1)} km';
  } else {
    return '${meters.round()} m';
  }
}

String formatTime(double minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;

  if (hours == 0) {
    return '${mins.round()}m'; // Solo mostrar minutos si es menos de una hora
  } else if (hours == 1 && mins == 0) {
    return '1 hora'; // Mostrar "1 hora" si es exactamente una hora
  } else if (hours == 1) {
    return '1 hora ${mins.round()}m'; // "1 hora" en singular con minutos
  } else if (mins == 0) {
    return '$hours horas'; // Mostrar solo horas si no hay minutos
  } else {
    return '$hours horas ${mins.round()}m'; // Mostrar horas y minutos
  }
}
