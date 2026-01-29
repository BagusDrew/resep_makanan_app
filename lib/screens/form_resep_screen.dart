// lib/screens/form_resep_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../models/resep_model.dart';
import '../services/resep_service.dart';

class FormResepScreen extends StatefulWidget {
  final Resep? resep;

  const FormResepScreen({super.key, this.resep});

  @override
  State<FormResepScreen> createState() => _FormResepScreenState();
}

class _FormResepScreenState extends State<FormResepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ResepService();

  // TextEditingControllers
  late final TextEditingController _namaController;
  late final TextEditingController _waktuMasakController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _bahanController;
  late final TextEditingController _langkahController;

  // Variabel untuk Dropdown Kategori
  String? _selectedKategori;
  final List<String> _daftarKategori = [
    'Makanan Berat',
    'Makanan Ringan',
    'Minuman'
  ];

  // Variabel untuk Dropdown Tingkat Kesulitan
  String? _selectedKesulitan;
  final List<String> _daftarKesulitan = [
    'Mudah',
    'Sedang',
    'Sulit Banget', 
  ];

  // --- BAGIAN BARU: DAFTAR GAMBAR DARI ASSETS ---
  String? _selectedImage;
  final List<String> _daftarGambar = [
    'placeholder.png',
    'sate_ayam.jpeg',
    'sate_padang.jpeg',
    'ayam_bakar.jpeg',
    'jus_mangga.jpeg',
    'kentang_goreng.jpeg',
    'ubilumer_coklat.jpeg',
    'piscok.jpeg',
    'esdoger.jpeg',
    'jus_alpukat.jpeg',
    'escream.jpeg',
    'roti_bakar.jpeg',
    'nasi_tumpeng.jpeg',
    'ikan_bakar_mas.jpeg',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final resep = widget.resep;
    final isEdit = resep != null;

    _namaController = TextEditingController(
      text: isEdit ? resep.namaResep : '',
    );
    
    if (isEdit && _daftarKategori.contains(resep.kategori)) {
      _selectedKategori = resep.kategori;
    } else {
      _selectedKategori = null;
    }
    
    _waktuMasakController = TextEditingController(
      text: isEdit ? resep.waktuMasak : '',
    );
    
    if (isEdit && _daftarKesulitan.contains(resep.tingkatKesulitan)) {
      _selectedKesulitan = resep.tingkatKesulitan;
    } else {
      _selectedKesulitan = null;
    }
    
    _deskripsiController = TextEditingController(
      text: isEdit ? resep.deskripsiSingkat : '',
    );
    _bahanController = TextEditingController(
      text: isEdit && resep.bahan.isNotEmpty ? resep.bahan.join('\n') : '',
    );
    _langkahController = TextEditingController(
      text: isEdit && resep.langkahMemasak.isNotEmpty
          ? resep.langkahMemasak.join('\n')
          : '',
    );

    // --- LOGIKA BARU UNTUK INITIAL VALUE GAMBAR ---
    if (isEdit && _daftarGambar.contains(resep.imageUrl)) {
      _selectedImage = resep.imageUrl;
    } else {
      _selectedImage = 'placeholder.png'; // Default jika tidak ada
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _waktuMasakController.dispose();
    _deskripsiController.dispose();
    _bahanController.dispose();
    _langkahController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('⚠️ Mohon isi semua kolom yang wajib diisi.', isError: true);
      return; 
    }
    
    setState(() => _isLoading = true);

    final isEdit = widget.resep != null;
    
    final resepData = Resep(
      id: isEdit ? widget.resep!.id : '', 
      namaResep: _namaController.text.trim(),
      kategori: _selectedKategori!, 
      waktuMasak: _waktuMasakController.text.trim(),
      tingkatKesulitan: _selectedKesulitan!, 
      deskripsiSingkat: _deskripsiController.text.trim(),
      bahan: _bahanController.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      langkahMemasak: _langkahController.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      // MENGGUNAKAN NILAI DARI DROPDOWN GAMBAR
      imageUrl: _selectedImage, 
    );

    try {
      if (isEdit) {
        await _service.updateResep(resepData);
        _showSnackBar('Resep berhasil diperbarui!');
        if (mounted) Navigator.pop(context, resepData); 
        
      } else {
        await _service.tambahResep(resepData);
        _showSnackBar('Resep berhasil ditambahkan!');
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Gagal menyimpan resep: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- (Method _hapusResep, _showDeleteDialog, _showSnackBar, dll tetap sama) ---
  // --- Saya skip ke bagian widget untuk mempersingkat tampilan kode ---

  Future<void> _hapusResep() async {
    if (widget.resep == null) return;
    final confirm = await _showDeleteDialog();
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await _service.hapusResep(widget.resep!.id); 
      _showSnackBar('Resep berhasil dihapus!');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Gagal menghapus resep: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: const Text('Apakah Anda yakin ingin menghapus resep ini secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.deepOrange),
      filled: true,
      fillColor: Colors.deepOrange.withAlpha(13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      errorStyle: const TextStyle(height: 0, fontSize: 0), 
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepOrange, width: 2)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isRequired = true, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: _buildInputDecoration(label),
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: (value) => isRequired && (value == null || value.trim().isEmpty) ? ' ' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? selectedValue, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: _buildInputDecoration(label),
        items: items.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? ' ' : null,
      ),
    );
  }

  // --- WIDGET DROPDOWN GAMBAR DENGAN PREVIEW KECIL ---
  Widget _buildImageDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedImage,
        decoration: _buildInputDecoration('Pilih Gambar Produk'),
        items: _daftarGambar.map((String imgName) {
          return DropdownMenuItem<String>(
            value: imgName,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset('assets/images/$imgName', width: 30, height: 30, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 30)),
                ),
                const SizedBox(width: 12),
                Text(imgName, style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedImage = val),
        validator: (value) => value == null ? ' ' : null,
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditMode) {
    if (_isLoading) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    return ElevatedButton.icon(
      onPressed: _submitForm,
      icon: Icon(isEditMode ? Icons.save : Icons.add),
      label: Text(isEditMode ? 'PERBARUI RESEP' : 'SIMPAN RESEP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  Widget _buildDeleteButton() {
    return OutlinedButton.icon(
      onPressed: _hapusResep,
      icon: const Icon(Icons.delete_forever),
      label: const Text('HAPUS RESEP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.red, side: const BorderSide(color: Colors.red, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.resep != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Resep' : 'Tambah Resep Baru'), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_namaController, 'Nama Resep'),
              _buildDropdownField('Kategori', _daftarKategori, _selectedKategori, (val) => setState(() => _selectedKategori = val)),
              _buildTextField(_waktuMasakController, 'Waktu Masak (Menit)', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              _buildDropdownField('Tingkat Kesulitan', _daftarKesulitan, _selectedKesulitan, (val) => setState(() => _selectedKesulitan = val)),
              _buildTextField(_deskripsiController, 'Deskripsi Singkat', maxLines: 3),
              _buildTextField(_bahanController, 'Bahan-bahan (Pisahkan dengan Enter)', maxLines: 5),
              _buildTextField(_langkahController, 'Langkah Memasak (Pisahkan dengan Enter)', maxLines: 8),
              
              // MENGGANTI URL GAMBAR DENGAN DROPDOWN ASSETS
              _buildImageDropdown(), 
              
              const SizedBox(height: 24),
              _buildSubmitButton(isEditMode),
              if (isEditMode && !_isLoading) ...[
                const SizedBox(height: 12),
                _buildDeleteButton(),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}