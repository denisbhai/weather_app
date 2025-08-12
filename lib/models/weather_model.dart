// import 'package:equatable/equatable.dart';
//
// class Weather extends Equatable {
//   final String city;
//   final double temp;
//   final int humidity;
//   final String description;
//   final String icon;
//   final double lat;
//   final double lon;
//   final dynamic weather;
//
//   const Weather({
//     required this.city,
//     required this.temp,
//     required this.humidity,
//     required this.description,
//     required this.icon,
//     required this.lat,
//     required this.lon,
//     required this.weather,
//   });
//
//   factory Weather.fromJson(Map<String, dynamic> json) {
//     return Weather(
//       weather: json['weather'],
//       city: json['name'],
//       temp: (json['main']['temp'] as num).toDouble(),
//       humidity: json['main']['humidity'],
//       description: (json['weather'] as List).first['description'],
//       icon: (json['weather'] as List).first['icon'],
//       lat: (json['coord']['lat'] as num).toDouble(),
//       lon: (json['coord']['lon'] as num).toDouble(),
//     );
//   }
//
//   @override
//   List<Object?> get props => [city, temp, humidity, description, icon, lat, lon];
// }
//

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Weather extends Equatable {
  final String city;
  final double temp;
  final int humidity;
  final String description;
  final String condition;
  final String icon;
  final double lat;
  final double lon;
  final double windSpeed;
  final String windDirection;
  final double tempMin;
  final double tempMax;
  final double rainProbability;
  final double precipitation; // mm
  final double feelsLike; // wind chill
  final double dewPoint;
  final int cloudCover; // %
  final double uvIndex;
  final int pressure; // mbar
  final DateTime sunrise;
  final DateTime sunset;
  final String moonPhase;
  final String localDate;
  final String localTime;
  final String dayName;
  final dynamic weather;

  const Weather({
    required this.city,
    required this.temp,
    required this.dayName,
    required this.weather,
    required this.humidity,
    required this.description,
    required this.condition,
    required this.icon,
    required this.lat,
    required this.lon,
    required this.windSpeed,
    required this.windDirection,
    required this.tempMin,
    required this.tempMax,
    required this.rainProbability,
    required this.precipitation,
    required this.feelsLike,
    required this.dewPoint,
    required this.cloudCover,
    required this.uvIndex,
    required this.pressure,
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
    required this.localDate,
    required this.localTime,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Timezone offset (for converting sunrise/sunset to local)
    final timezoneOffset = json['timezone'] ?? 0;
    final utcTime =
        DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true);
    final cityTime = utcTime.add(Duration(seconds: timezoneOffset));

    // Separate date & time
    final dateStr = DateFormat("MMM d, yyyy").format(cityTime);
    final timeStr = DateFormat("HH:mm").format(cityTime);
    final dayStr = DateFormat("E").format(cityTime); // <-- NEW


    return Weather(
      weather: json['weather'],
      city: json['name'],
      temp: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'],
      description: (json['weather'] as List).first['description'],
      condition: (json['weather'] as List).first['main'],
      icon: (json['weather'] as List).first['icon'],
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDirection:
          _degreesToDirection((json['wind']['deg'] as num).toDouble()),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      rainProbability: json['rain'] != null
          ? (json['rain']['1h'] ?? json['rain']['3h'] ?? 0.0).toDouble()
          : 0.0,
      precipitation: json['rain'] != null
          ? (json['rain']['1h'] ?? json['rain']['3h'] ?? 0.0).toDouble()
          : 0.0,
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      dewPoint: json['main']['dew_point'] != null
          ? (json['main']['dew_point'] as num).toDouble()
          : 0.0, // Needs One Call API
      cloudCover: json['clouds'] != null ? json['clouds']['all'] : 0,
      uvIndex: json['uvi'] != null
          ? (json['uvi'] as num).toDouble()
          : 0.0, // Needs One Call API
      pressure: json['main']['pressure'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] + timezoneOffset) * 1000,
        isUtc: true,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunset'] + timezoneOffset) * 1000,
        isUtc: true,
      ),
      moonPhase: json['moon_phase'] != null
          ? _moonPhaseText((json['moon_phase'] as num).toDouble())
          : "Unknown",
      localDate: dateStr,
      localTime: timeStr,
      dayName: dayStr,
    );
  }


  static String _degreesToDirection(double degrees) {
    const directions = [
      "North",
      "North North East",
      "North East",
      "East North East",
      "East",
      "East South East",
      "South East",
      "South South East",
      "South",
      "South South West",
      "South West",
      "West South West",
      "West",
      "West North West",
      "North West",
      "North North West"
    ];
    return directions[((degrees / 22.5) + 0.5).floor() % 16];
  }

  static String _moonPhaseText(double phase) {
    if (phase == 0 || phase == 1) return "New moon";
    if (phase < 0.25) return "Waxing crescent";
    if (phase == 0.25) return "First quarter";
    if (phase < 0.5) return "Waxing gibbous";
    if (phase == 0.5) return "Full moon";
    if (phase < 0.75) return "Waning gibbous";
    if (phase == 0.75) return "Last quarter";
    return "Waning crescent";
  }

  @override
  List<Object?> get props => [
        city,
        temp,
        humidity,
        description,
        condition,
        icon,
        lat,
        lon,
        windSpeed,
        windDirection,
        tempMin,
        tempMax,
        rainProbability,
        precipitation,
        feelsLike,
        dewPoint,
        cloudCover,
        uvIndex,
        pressure,
        sunrise,
        sunset,
        moonPhase,
        localDate,
        localTime
      ];
}
