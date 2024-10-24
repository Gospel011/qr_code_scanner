import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrious/app_pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
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
            textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 18.sp)),

            //* Input decoration theme
            inputDecorationTheme: InputDecorationTheme(
                //* padding
                contentPadding: EdgeInsets.only(left: 16.w, top: 10.h),
                //* for normal border
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r)),
                //* for focused border
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade600),
                    borderRadius: BorderRadius.circular(8.r)),

                //* for enabled border
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r))),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(1.0),
                minimumSize: WidgetStatePropertyAll(
                    Size(MediaQuery.sizeOf(context).width - 32.w, 48.h)),
                textStyle: WidgetStatePropertyAll(TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                )),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
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

            //* Input decoration theme
            inputDecorationTheme: InputDecorationTheme(
                //* padding
                contentPadding: EdgeInsets.only(left: 16.w, top: 10.h),
                //* for normal border
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.r)),
                //* for focused border
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(8.r)),

                //* for enabled border
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.r))),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(1.0),
                minimumSize: WidgetStatePropertyAll(
                    Size(MediaQuery.sizeOf(context).width - 32.w, 48.h)),
                textStyle: WidgetStatePropertyAll(TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                )),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
            ),
            textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 18.sp)),
          ),
          home: child!,
        );
      },
      child: const Home(),
    );
  }
}
