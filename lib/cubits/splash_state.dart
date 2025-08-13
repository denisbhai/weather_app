part of 'splash_cubit.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashConnected extends SplashState {}
class SplashNoInternet extends SplashState {}
