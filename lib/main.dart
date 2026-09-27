import 'package:climapp_cc20262/src/controller/list_city_controller.dart';
import 'package:climapp_cc20262/src/screens/welcome_screen.dart';
import 'package:climapp_cc20262/src/services/device_info_service.dart';
import 'package:climapp_cc20262/src/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WeatherService>(create: (_) => WeatherService()),
        Provider<DeviceInfoService>(create: (_) => DeviceInfoService()),
        ChangeNotifierProvider(
          create: (context) => ListCityController(
            weatherService: context.read<WeatherService>(),
            deviceInfoService: context.read<DeviceInfoService>(),
          )..loadCities(),
        ),
      ],
      child: MaterialApp(
        title: 'Climapp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
