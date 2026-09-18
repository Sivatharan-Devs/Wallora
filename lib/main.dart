import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/wallpaper_provider.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  // Required whenever you do async work (dotenv.load) before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Loads key=value pairs from the .env asset into memory. If this file
  // is missing, the app should fail loudly here rather than silently
  // sending empty-string API keys to Pexels later.
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider creates ONE WallpaperProvider instance and
    // makes it available to every widget below it via context.
    // `create` runs exactly once (not on every rebuild), and Provider
    // automatically calls dispose() on the provider when this widget
    // leaves the tree — we don't have to manage that lifecycle ourselves.
    return ChangeNotifierProvider(
      create: (_) => WallpaperProvider(
        apiService: ApiService(apiKey: dotenv.env['PEXELS_API_KEY'] ?? ''),
      )..loadInitial(), // the cascade (..) kicks off the first fetch immediately
      child: MaterialApp(
        title: 'Wallpapers',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
