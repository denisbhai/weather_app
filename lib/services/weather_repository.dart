import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';

class WeatherRepository {
  final String _apiKey = dotenv.env['OWM_API_KEY'] ?? '';
  final http.Client httpClient;

  WeatherRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  final String _baseUrl = "https://api.openweathermap.org/data/2.5/";

  Future<Weather> fetchCurrentByCoords(double lat, double lon) async {
    final uri = Uri.parse(
      '${_baseUrl}weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey',
    );
    final res = await httpClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load weather: ${res.body}');
    }
    return Weather.fromJson(json.decode(res.body));
  }

  Future<List<DailyForecast>> fetch5DayForecastByCoords(
      double lat, double lon) async {
    final uri = Uri.parse(
      '${_baseUrl}forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey',
    );
    final res = await httpClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load forecast: ${res.body}');
    }
    return Forecast.fromJson(json.decode(res.body)).daily;
  }

  Future<List<HourlyForecast>> fetchHourlyForecastByCoords(double lat, double lon) async {
    final uri = Uri.parse(
      '${_baseUrl}forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey',
    );
    final res = await httpClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load hourly forecast: ${res.body}');
    }
    final data = json.decode(res.body);
    final timezoneOffset = data['city']['timezone'] as int;
    final nowUtc = DateTime.now().toUtc();
    final nowLocal = nowUtc.add(Duration(seconds: timezoneOffset));
    final endOfTodayLocal = DateTime.utc(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
      23,
      59,
    );

    final List list = data['list'];
    return list.map((item) => HourlyForecast.fromJson(item)).where((hour) {
      final sameHour = hour.time.year == nowLocal.year &&
          hour.time.month == nowLocal.month &&
          hour.time.day == nowLocal.day &&
          hour.time.hour == nowLocal.hour;

      return sameHour ||
          (hour.time.isAfter(nowLocal) && hour.time.isBefore(endOfTodayLocal));
    }).toList();
  }

  Future<Weather> fetchCurrentByCity(String city) async {
    final uri = Uri.parse(
      '${_baseUrl}weather?q=$city&units=metric&appid=$_apiKey',
    );
    final res = await httpClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load weather: ${res.body}');
    }
    return Weather.fromJson(json.decode(res.body));
  }

  Future<List<DailyForecast>> fetch5DayForecastByCity(String city) async {
    final uri = Uri.parse(
      '${_baseUrl}forecast?q=$city&units=metric&appid=$_apiKey',
    );
    final res = await httpClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load forecast: ${res.body}');
    }
    return Forecast.fromJson(json.decode(res.body)).daily;
  }

  Future<List<HourlyForecast>> fetchHourlyForecastByCity(String city) async {
    final uri = Uri.parse(
      '${_baseUrl}forecast?q=$city&units=metric&appid=$_apiKey',
    );
    final res = await httpClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load hourly forecast: ${res.body}');
    }
    final data = json.decode(res.body);
    final timezoneOffset = data['city']['timezone'] as int;
    final nowUtc = DateTime.now().toUtc();
    final nowLocal = nowUtc.add(Duration(seconds: timezoneOffset));
    final endOfTodayLocal = DateTime.utc(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
      23,
      59,
    );
    final List list = data['list'];
    return list.map((item) => HourlyForecast.fromJson(item)).where((hour) {
      final sameHour = hour.time.year == nowLocal.year &&
          hour.time.month == nowLocal.month &&
          hour.time.day == nowLocal.day &&
          hour.time.hour == nowLocal.hour;

      return sameHour ||
          (hour.time.isAfter(nowLocal) && hour.time.isBefore(endOfTodayLocal));
    }).toList();
  }
}