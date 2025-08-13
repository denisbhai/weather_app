import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/cubits/weather_cubit.dart';
import 'package:weather_app/screens/map_screen.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_icons/weather_icons.dart';
import 'forecastchart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<void> _getLocationAndFetch() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.lightBlue,
          content: Text('Location permission denied'),
        ),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // ignore: use_build_context_synchronously
    context.read<WeatherCubit>().fetchByCoords(pos.latitude, pos.longitude);
  }

  String getWeatherBackground(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'https://media.istockphoto.com/id/1007768414/photo/blue-sky-with-bright-sun-and-clouds.jpg?s=612x612&w=0&k=20&c=MGd2-v42lNF7Ie6TtsYoKnohdCfOPFSPQt5XOz4uOy4=';
      case 'clouds':
        return 'https://images.pexels.com/photos/16998574/pexels-photo-16998574/free-photo-of-beautiful-clouds-at-sunset.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';
      case 'rain':
        return 'https://thumbs.dreamstime.com/b/blue-color-tone-close-up-rain-water-drop-falling-to-floor-rainy-season-56849111.jpg';
      case 'drizzle':
        return 'https://i1.sndcdn.com/artworks-X2RtUWfUHLw3yAtn-QXCITA-t1080x1080.jpg';
      case 'thunderstorm':
        return 'https://images.stockcake.com/public/9/6/3/9634730f-f496-4560-8d50-eecb69ef6a4b_large/thunderous-city-night-stockcake.jpg';
      case 'snow':
        return 'https://plus.unsplash.com/premium_photo-1685977494926-d1f8efd44c3c?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8c25vdyUyMG5pZ2h0fGVufDB8fDB8fHww';
      case 'mist':
        return 'https://media.istockphoto.com/id/1007768414/photo/blue-sky-with-bright-sun-and-clouds.jpg?s=612x612&w=0&k=20&c=MGd2-v42lNF7Ie6TtsYoKnohdCfOPFSPQt5XOz4uOy4=';
      case 'fog':
        return 'https://media.istockphoto.com/id/1007768414/photo/blue-sky-with-bright-sun-and-clouds.jpg?s=612x612&w=0&k=20&c=MGd2-v42lNF7Ie6TtsYoKnohdCfOPFSPQt5XOz4uOy4=';
      case 'haze':
        return 'https://media.istockphoto.com/id/1007768414/photo/blue-sky-with-bright-sun-and-clouds.jpg?s=612x612&w=0&k=20&c=MGd2-v42lNF7Ie6TtsYoKnohdCfOPFSPQt5XOz4uOy4=';
      default:
        return 'https://media.istockphoto.com/id/1007768414/photo/blue-sky-with-bright-sun-and-clouds.jpg?s=612x612&w=0&k=20&c=MGd2-v42lNF7Ie6TtsYoKnohdCfOPFSPQt5XOz4uOy4=';
    }
  }

  @override
  void initState() {
    context.read<WeatherCubit>().fetchByCoords(20.5937, 78.9629);
    _getLocationAndFetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<WeatherCubit, WeatherState>(
              builder: (context, state) {
                if (state is WeatherLoaded) {
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Image.network(
                      getWeatherBackground(state.current?.weather[0]['main']),
                      // getWeatherBackground('clouds'),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                if (state is WeatherLoading) {
                  return Stack(
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Image.asset(
                          "assets/images/cloud.jpg",
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Center(
                          child: CircularProgressIndicator()),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                      BlocBuilder<WeatherCubit, WeatherState>(
                          builder: (context, state) {
                        if (state is WeatherLoaded) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Center(
                              child: Text(
                                "${state.current?.city}",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Row(
                        children: [
                          GestureDetector(
                            child: const Icon(
                              Icons.search_rounded,
                              size: 25,
                              color: Colors.white,
                            ),
                            onTap: () async {
                              final selectedCity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CitySearchScreen(),
                                ),
                              );

                              if (selectedCity != null) {
                                context
                                    .read<WeatherCubit>()
                                    .fetchByCity(selectedCity['name']);
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: _getLocationAndFetch,
                            child: const Icon(
                              Icons.my_location,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 15),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<WeatherCubit, WeatherState>(
                      builder: (context, state) {
                        if (state is WeatherInitial) {
                          return const Center(
                              child: Text('Search or use location'));
                        }
                        if (state is WeatherError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        if (state is WeatherLoaded) {
                          final w = state.current;
                          return SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withOpacity(0.4),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${w?.dayName}, ${w?.localDate}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${w?.localTime}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "${w?.temp.toStringAsFixed(1)}°C",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .arrow_upward_outlined,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      Text(
                                                        "${w?.tempMax.toStringAsFixed(0)}°C",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.arrow_downward,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      Text(
                                                        "${w?.tempMin.toStringAsFixed(0)}°C",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                            top: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.05,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Wind: ${w?.windSpeed} mph, ${w?.windDirection}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Rain probability: (Rain) ${w?.rainProbability}%",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Humidity: ${w?.humidity}%",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Precipitations: ${w?.precipitation.toStringAsFixed(0)} mm",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Wind chill: ${w?.feelsLike.toStringAsFixed(0)}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Dew point: ${w?.dewPoint}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Cloud cover: ${w?.cloudCover.toStringAsFixed(0)}%",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "UV index: ${w?.uvIndex.toStringAsFixed(0)}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Pressure: ${w?.pressure.toStringAsFixed(0)} mbar",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Sunrise: ${DateFormat('HH:mm').format(w?.sunrise ?? DateTime.now())}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Sunset: ${DateFormat('HH:mm').format(w?.sunset ?? DateTime.now())}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Column(
                                                    children: [
                                                      Image.network(
                                                          'https://openweathermap.org/img/wn/${w?.icon}@2x.png',
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.08),
                                                      Text(
                                                        "${w?.weather[0]['description']}",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Today Forecast',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.44,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.hourly?.length,
                                      itemBuilder: (context, index) {
                                        final h = state.hourly?[index];
                                        return Container(
                                          margin: EdgeInsets.only(right: 8),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color:
                                                Colors.black.withOpacity(0.4),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${h?.time.hour}:00",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Image.network(
                                                  "https://openweathermap.org/img/wn/${h?.icon}@2x.png",
                                                  width: 40),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    WeatherIcons.raindrops,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    "${h?.chanceOfRain}%",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                "${h?.temperature.toStringAsFixed(0)}°",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Spacer(),
                                              Row(
                                                children: [
                                                  Icon(
                                                    WeatherIcons.raindrops,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    "Chance Of Rain",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Day Forecast',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      )),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.58,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.forecast?.length ?? 0,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, i) {
                                        final d = state.forecast?[i];
                                        return Card(
                                          color: Colors.black.withOpacity(0.4),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    DateFormat('EEE\ndd MMM')
                                                        .format(d?.date ??
                                                            DateTime.now()),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    )),
                                                Image.network(
                                                    'https://openweathermap.org/img/wn/${d?.icon}@2x.png',
                                                    width: 48,
                                                    height: 48),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      WeatherIcons.raindrops,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "${d?.chanceOfRain}%",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                    'H ${d?.maxTemp.toStringAsFixed(0)}°',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    )),
                                                Text(
                                                    'L ${d?.minTemp.toStringAsFixed(0)}°',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    )),
                                                Spacer(),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      WeatherIcons.raindrops,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "Chance Of Rain",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Weather Map',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.33,
                                    padding: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            "https://thumbs.dreamstime.com/b/dresden-germany-february-world-map-windy-weather-web-service-showing-global-heat-waves-extreme-high-temperature-south-268969909.jpg",
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              icon: Icon(Icons.zoom_out_map,
                                                  color: Colors.white),
                                              label: Text(
                                                "Weather Map",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => MapScreen(
                                                      lat: w?.lat ?? 0.00,
                                                      lon: w?.lon ?? 0.00,
                                                      temp: w?.temp ?? 0.00,
                                                      humidity: w?.humidity ?? 0,
                                                      city: w?.city ?? "",
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ForecastChart(forecast: state.forecast ?? []),
                                  const SizedBox(height: 20),
                                ]),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}