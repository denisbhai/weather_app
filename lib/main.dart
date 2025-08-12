import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubits/weather_cubit.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/services/weather_repository.dart';

import 'cubits/search_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final repo = WeatherRepository();
  runApp(MyApp(weatherRepository: repo));
}

class MyApp extends StatelessWidget {
  final WeatherRepository weatherRepository;
  const MyApp({required this.weatherRepository, super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: weatherRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => WeatherCubit(weatherRepository),
          ),
          BlocProvider(
            create: (_) => SearchCubit(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weather App',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
