import 'package:flutter/material.dart';
import 'splash.dart';
import 'home_page.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// Pastikan file ini ada dan sudah benar

late Interpreter interpreter;

Future<void> loadModel() async {
  interpreter = await Interpreter.fromAsset('assets/models/expresi.tflite');
  print('Model loaded!');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadModel();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deteksi Ekspresi Wajah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6B46C1)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home_page': (context) => const FaceExpressionDetectorPage(), // route ini penting
      },
    );
  }
}
