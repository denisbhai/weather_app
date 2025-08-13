import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkConnectivity() async {
    emit(SplashLoading());

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult[0] == ConnectivityResult.none) {
      emit(SplashNoInternet());
    } else {
      emit(SplashConnected());
    }
  }
}
