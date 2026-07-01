import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_tabs_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase.
  // IMPORTANT: Replace with your actual credentials!
  await Supabase.initialize(
    url: 'https://vaxoawqrlcmgbvwwrpii.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZheG9hd3FybGNtZ2J2d3dycGlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIzOTA3MDIsImV4cCI6MjA5Nzk2NjcwMn0.8LmwriVqI_Cy2XBwthI6dv8RrdZ7XcNFrai9CGdAtBw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca Batatinha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme(
    brightness: Brightness.light,

    primary: const Color(0xFF1E4738),
    onPrimary: Colors.white,

    secondary: const Color(0xFFC8A04B),
    onSecondary: Colors.white,

    error: Colors.red,
    onError: Colors.white,

    surface: const Color(0xFFBFCDBB),
    onSurface: const Color(0xFF262626),
  ),

  scaffoldBackgroundColor: const Color.fromARGB(255, 246, 243, 237),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E4738),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
  ),

  cardTheme: const CardThemeData(
    color: Color(0xFFBFCDBB),
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1E4738),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: Color(0xFFBFCDBB),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: Color(0xFFC8A04B),
        width: 2,
      ),
    ),

    labelStyle: TextStyle(
      color: Color(0xFF262626),
    ),
  ),
),
      home: const MainTabsContainer(),
    );
  }
}
