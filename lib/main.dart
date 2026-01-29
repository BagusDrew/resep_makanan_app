import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/shared_prefs_manager.dart';

void main() {
  // Wajib: Inisialisasi binding sebelum memanggil SharedPreferences
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resep Makanan App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      // Definisikan routes untuk navigasi
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      // Gunakan FutureBuilder untuk menentukan halaman awal
      home: FutureBuilder<bool>(
        future: SharedPrefsManager.getLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan layar loading saat SharedPreferences dibaca
            return const Center(child: CircularProgressIndicator());
          }
          final isLoggedIn = snapshot.data ?? false;
          // Logika Tiket Masuk
          return isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}