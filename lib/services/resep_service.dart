import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resep_model.dart';

class ResepService {
  // ✅ 1. BASE URL DIKOREKSI menggunakan URL yang Anda berikan
  static const String _baseUrl = 'https://69284a73b35b4ffc50150c12.mockapi.io/resep'; 
  
  // Ambil Semua Resep (GET)
  Future<List<Resep>> getSemuaResep() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Resep.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data resep: Status ${response.statusCode}');
    }
  }

  // Tambah Resep (POST)
  Future<Resep> tambahResep(Resep resep) async {
    final url = Uri.parse(_baseUrl); // POST ke BASE URL
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(resep.toJson()),
    );

    if (response.statusCode == 201) { // 201 Created
      return Resep.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal menambahkan resep: Status ${response.statusCode}');
    }
  }

  // ✅ 2. PERBARUI Resep (PUT) - MENGATASI STATUS 404
  Future<void> updateResep(Resep resep) async {
    // URL PUT HARUS menyertakan ID: /resep/{ID}
    final url = Uri.parse('$_baseUrl/${resep.id}'); 
    
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(resep.toJson()), 
    );

    if (response.statusCode == 200) {
      return; // Sukses Update
    } else {
      throw Exception('Gagal memperbarui resep: Status ${response.statusCode}');
    }
  }

  // ✅ 3. HAPUS Resep (DELETE) - Juga perlu ID
  Future<void> hapusResep(String id) async {
    // URL DELETE HARUS menyertakan ID: /resep/{ID}
    final url = Uri.parse('$_baseUrl/$id');
    
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus resep: Status ${response.statusCode}');
    }
  }
}