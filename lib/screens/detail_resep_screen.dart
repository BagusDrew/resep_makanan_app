// lib/screens/detail_resep_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import '../models/resep_model.dart';
import 'form_resep_screen.dart';
import '../services/resep_service.dart';

class DetailResepScreen extends StatefulWidget {
  final Resep resep;

  const DetailResepScreen({super.key, required this.resep});

  @override
  State<DetailResepScreen> createState() => _DetailResepScreenState();
}

class _DetailResepScreenState extends State<DetailResepScreen> {
  late Resep _currentResep;
  final ResepService _service = ResepService();

  @override
  void initState() {
    super.initState();
    _currentResep = widget.resep;
    
    // 🔍 DEBUG - CEK ID RESEP SAAT DETAIL SCREEN DIBUKA
    if (kDebugMode) {
      debugPrint('=========================');
      debugPrint('📱 DETAIL SCREEN OPENED');
      debugPrint('🔍 ID Resep: "${_currentResep.id}"');
      debugPrint('🔍 Nama: ${_currentResep.namaResep}');
      debugPrint('🔍 Gambar: ${_currentResep.imageUrl}');
      debugPrint('=========================');
    }
  }

  Future<void> _navigateToEdit() async {
    if (kDebugMode) {
      debugPrint('✏ NAVIGASI KE EDIT: "${_currentResep.id}"');
    }
    
    if (!mounted) return;
    
    final updatedResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormResepScreen(resep: _currentResep),
      ),
    );

    if (!mounted) return;

    if (updatedResult is Resep) {
      if (kDebugMode) debugPrint('✅ Update berhasil, resep baru diterima');
      setState(() {
        _currentResep = updatedResult;
      });
    } else if (updatedResult == true) {
      if (kDebugMode) debugPrint('🗑 Resep dihapus, kembali ke home');
      Navigator.pop(context, true);
    }
  }
  
  Future<void> _hapusResep() async {
    if (!mounted) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _service.hapusResep(_currentResep.id);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil dihapus!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ ERROR HAPUS: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMetadataItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepOrange, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Colors.deepOrange,
            ),
          ),
          const Divider(color: Colors.deepOrange),
          if (items.isEmpty)
            const Text('Belum ada data.')
          else
            ...items.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              String val = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '$idx. $val',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resep = _currentResep;
    final waktuMasakDisplay = resep.waktuMasak.isNotEmpty 
        ? '${resep.waktuMasak} menit' 
        : 'N/A';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(resep.namaResep),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
            tooltip: 'Edit Resep',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _hapusResep,
            tooltip: 'Hapus Resep',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ PERBAIKAN: Menggunakan Image.asset untuk mengambil gambar dari folder assets lokal
                if (resep.imageUrl != null && resep.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/${resep.imageUrl}',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      // Penanganan jika file gambar tidak ditemukan di folder assets
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.deepOrange.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.food_bank,
                      size: 60,
                      color: Colors.deepOrange,
                    ),
                  ),
                
                const SizedBox(width: 16),
                
                // Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resep.deskripsiSingkat,
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      _buildMetadataItem(
                        'Kategori',
                        resep.kategori,
                        Icons.category,
                      ),
                      _buildMetadataItem(
                        'Waktu Masak',
                        waktuMasakDisplay,
                        Icons.schedule,
                      ),
                      _buildMetadataItem(
                        'Kesulitan',
                        resep.tingkatKesulitan,
                        Icons.star,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            _buildListSection('Bahan-bahan', resep.bahan),
            _buildListSection('Langkah Memasak', resep.langkahMemasak),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}