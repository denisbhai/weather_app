import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/search_cubit.dart';
import '../cubits/search_state.dart';

class CitySearchScreen extends StatelessWidget {
  CitySearchScreen({super.key});

  final TextEditingController _controller = TextEditingController();
  final DeBouncer _deBouncer = DeBouncer(milliseconds: 500); // 0.5s delay

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Image.network(
                "https://images.pexels.com/photos/16998574/pexels-photo-16998574/free-photo-of-beautiful-clouds-at-sunset.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    cursorColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,      // Text color
                      fontSize: 15,           // Optional: change font size
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search Location',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white, width: 2.0), // Normal state
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white, width: 2.0), // When focused
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.trim().length < 3) {
                        // Clear results if less than 3 characters
                        context.read<SearchCubit>().clearResults();
                        return;
                      } else {
                        _deBouncer.run(() {
                          context.read<SearchCubit>().searchCity(value);
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      if (state is SearchLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SearchLoaded) {
                        if(state.cities.isEmpty){
                          return Center(
                              child: Text(
                                "The city with this name is not available.",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ));
                        }
                        return ListView.builder(
                          itemCount: state.cities.length,
                          itemBuilder: (context, index) {
                            final city = state.cities[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    "${city['name']}, ${city['sys']['country']}",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Temp: ${city['main']['temp']}°C, ${city['weather'][0]['description']}",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    context.read<SearchCubit>().clearResults();
                                    Navigator.pop(context, city);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Divider(color: Colors.white, thickness: 1),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (state is SearchError) {
                        return Center(
                            child: Text(
                          state.message,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ));
                      }
                      return Center(
                        child: Text(
                          "Type at least 3 characters to search",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
