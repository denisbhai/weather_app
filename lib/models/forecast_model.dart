import 'package:intl/intl.dart';

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String icon;
  final int chanceOfRain;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    required this.chanceOfRain,
  });
}

class Forecast {
  final List<DailyForecast> daily;

  Forecast({required this.daily});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    // json['list'] contains 3-hourly entries -> group by day and compute min/max
    final List list = json['list'] as List;
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final e in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch((e['dt'] as int) * 1000, isUtc: true).toLocal();
      final key = DateFormat('yyyy-MM-dd').format(dt);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final daily = grouped.entries.take(5).map((entry) {
      final date = DateTime.parse(entry.key);
      double minT = double.infinity;
      double maxT = -double.infinity;
      String icon = '';
      double maxPop = 0.0;

      for (final e in entry.value) {
        final t = (e['main']['temp'] as num).toDouble();
        if (t < minT) minT = t;
        if (t > maxT) maxT = t;
        icon = (e['weather'] as List).first['icon'];

        if (e.containsKey('pop')) {
          final pop = (e['pop'] as num).toDouble();
          if (pop > maxPop) maxPop = pop;
        }
      }
      return DailyForecast(date: date, minTemp: minT, maxTemp: maxT, icon: icon,chanceOfRain: (maxPop * 100).round(),);
    }).toList();

    return Forecast(daily: daily);
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int chanceOfRain;
  final String icon;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.chanceOfRain,
    required this.icon,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true).toLocal().toUtc(),
      temperature: (json['main']['temp'] as num).toDouble(),
      chanceOfRain: ((json['pop'] ?? 0) * 100).round(),
      icon: json['weather'][0]['icon'],
    );
  }

}
