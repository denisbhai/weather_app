// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';
import '../services/weather_repository.dart';
part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository repository;
  WeatherCubit(this.repository) : super(WeatherInitial());

  Future<void> fetchByCoords(double lat, double lon) async {
    try {
      emit(WeatherLoading());
      final current = await repository.fetchCurrentByCoords(lat, lon);
      final forecast = await repository.fetch5DayForecastByCoords(lat, lon);
      final fetchHourlyForecast = await repository.fetchHourlyForecastByCoords(lat, lon);

      emit(WeatherLoaded(current: current, forecast: forecast,hourly: fetchHourlyForecast));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }

  Future<void> fetchByCity(String city) async {
    try {
      emit(WeatherLoading());
      final current = await repository.fetchCurrentByCity(city);
      final forecast = await repository.fetch5DayForecastByCity(city);
      final fetchHourlyForecast = await repository.fetchHourlyForecastByCity(city);
      emit(WeatherLoaded(current: current, forecast: forecast,hourly: fetchHourlyForecast));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }

}
