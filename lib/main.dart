import 'package:flutter/material.dart';
import 'package:qrious/app_pages/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7F50),
          primary: const Color(0xFFFF7F50),
          onPrimary: Colors.white,
          surface: const Color(0xFFFFFFFF),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 18)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(
                Size(MediaQuery.sizeOf(context).width - 32, 48)),
            textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 18)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFFF7F50),
          primary: const Color(0xFFFF7F50),
          onPrimary: Colors.white,
          surface: const Color(0xFF121212),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 24)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(
                Size(MediaQuery.sizeOf(context).width - 32, 48)),
            textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 18)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
      home: const Home(),
    );
  }
}
