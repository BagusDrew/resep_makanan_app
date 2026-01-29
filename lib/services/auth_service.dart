import '../utils/shared_prefs_manager.dart';

class AuthService {
  // 1. Data Dummy Login (Daftar Akun)
  final List<Map<String, String>> _dummyUsers = [
    {"username": "user", "password": "password"},
    {"username": "admin", "password": "123"},
    {"username": "koki", "password": "masakjago"},
  ];

  // Fungsi login
  Future<bool> login(String username, String password) async {
    // Simulasi delay jaringan (2 detik)
    await Future.delayed(const Duration(seconds: 2)); 

    try {
      // 2. Cek apakah input ada di daftar dummyUsers
      final userExists = _dummyUsers.any((user) => 
        user['username'] == username && user['password'] == password
      );

      if (userExists) {
        // BERHASIL: Simpan status login ke storage lokal
        await SharedPrefsManager.setLoginStatus(true);
        return true;
      } else {
        // GAGAL: Kembalikan false agar UI tahu login tidak valid
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    await SharedPrefsManager.logout();
  }
}