part of 'weather_cubit.dart';

abstract class WeatherState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}
class WeatherLoading extends WeatherState {}
class WeatherLoaded extends WeatherState {
  final Weather? current;
  final List<DailyForecast>? forecast;
  final List<HourlyForecast>? hourly;    // ⬅ Rename forecast to daily for clarity

  WeatherLoaded({this.current, this.forecast, this.hourly});
  @override
  List<Object?> get props => [current, forecast, hourly];
}
class WeatherError extends WeatherState {
  final String message;
  WeatherError({required this.message});
  @override
  List<Object?> get props => [message];
}
