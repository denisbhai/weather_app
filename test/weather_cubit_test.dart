import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_repository.dart';

// Mock class for http.Client
class MockHttpClient extends Mock implements http.Client {}

// Fake Uri needed for mocktail argument matching
class FakeUri extends Fake implements Uri {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // Register fallback value for Uri to fix mocktail errors
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  late MockHttpClient mockHttpClient;
  late WeatherRepository repo;

  setUp(() {
    mockHttpClient = MockHttpClient();
    repo = WeatherRepository(httpClient: mockHttpClient);
  });

  group('fetchCurrentByCoords', () {
    final lat = 10.0;
    final lon = 20.0;

    final weatherJson = {
      "name": "Test City",
      "main": {"temp": 25, "humidity": 80},
      "weather": [
        {"description": "clear sky", "icon": "01d"}
      ],
      "coord": {"lat": lat, "lon": lon}
    };

    test('returns Weather on successful response', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
            (_) async => http.Response(json.encode(weatherJson), 200),
      );

      final weather = await repo.fetchCurrentByCoords(lat, lon);

      expect(weather, isA<Weather>());
      expect(weather.city, "Test City");
      expect(weather.temp, 25);
      expect(weather.humidity, 80);
      expect(weather.description, "clear sky");
      expect(weather.icon, "01d");
    });

    test('throws Exception on non-200 response', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
            (_) async => http.Response('Error', 404),
      );

      expect(
            () async => await repo.fetchCurrentByCoords(lat, lon),
        throwsException,
      );
    });
  });

  // Add more test groups for other methods if you want...
}
