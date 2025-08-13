// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:weather_app/screens/home_screen.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     start();
//     super.initState();
//   }
//
//   void start() async {
//     await Future.delayed(
//       const Duration(seconds: 3),
//       () {
//         Navigator.pushReplacement(
//           // ignore: use_build_context_synchronously
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return HomeScreen();
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue,
//       body: Center(
//         child: Lottie.asset(
//           'assets/images/Weathershower.json',
//           height: 300,
//           width: 300,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/screens/home_screen.dart';
import '../cubits/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..checkConnectivity(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashNoInternet) {
            _showNoInternetDialog(context);
          } else if (state is SplashConnected) {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            });
          }
        },
        child: Scaffold(
          body: Center(
            child: Lottie.asset(
              'assets/images/Weathershower.json',
              height: 300,
              width: 300,
            ),
          ),
        ),
      ),
    );
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("No Internet"),
        content: const Text("Please check your connection and try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SplashCubit>().checkConnectivity();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
