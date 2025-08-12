// search_cubit.dart
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app/cubits/search_state.dart';
import 'dart:async';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  void clearResults() {
    emit(SearchInitial());
  }


  Future<void> searchCity(String query) async {
    if (query.isEmpty) return;
    final apiKey = dotenv.env['OWM_API_KEY'] ?? '';
    emit(SearchLoading());
    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/find?q=$query&appid=$apiKey&units=metric',
      );
      final res = await http.get(url);
      print("==resdata===resdata=${query}====${apiKey}=${res.body}");

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        emit(SearchLoaded(data['list']));
      } else {
        emit(SearchError("Error: ${res.reasonPhrase}"));
      }
    } catch (e) {
      emit(SearchError("Something went wrong"));
    }
  }
}


class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
