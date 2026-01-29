// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/resep_model.dart';
import '../services/resep_service.dart';
import 'detail_resep_screen.dart';
import 'form_resep_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ResepService _service = ResepService();
  List<Resep> _resepList = [];
  List<Resep> _filteredResepList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController(); 

  // 🔄 KATEGORI TERBARU
  final List<String> _kategoriList = [
    'Semua', 
    'Makanan Berat', 
    'Makanan Ringan', 
    'Minuman',
  ];
  String _selectedKategori = 'Semua'; 

  // ✅ MAP IKON KATEGORI TERBARU
  final Map<String, IconData> _kategoriIcons = {
    'Semua': Icons.apps,
    'Makanan Berat': Icons.rice_bowl,
    'Makanan Ringan': Icons.cookie,
    'Minuman': Icons.local_drink,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      _filterResep(_searchController.text); 
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getSemuaResep(); 
      setState(() {
        _resepList = data;
        _isLoading = false;
        _filterResep(_searchController.text); 
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e. Cek koneksi atau URL MockAPI.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterResep(String query) {
    setState(() {
      // 1. Filter berdasarkan Kategori
      List<Resep> filteredByKategori;
      if (_selectedKategori == 'Semua') {
        filteredByKategori = _resepList;
      } else {
        filteredByKategori = _resepList.where((resep) => 
          resep.kategori.toLowerCase() == _selectedKategori.toLowerCase()
        ).toList();
      }

      // 2. Filter berdasarkan Pencarian Teks (query)
      if (query.isEmpty) {
        _filteredResepList = filteredByKategori;
      } else {
        _filteredResepList = filteredByKategori
            .where((resep) =>
                resep.namaResep.toLowerCase().contains(query.toLowerCase()) ||
                resep.kategori.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onKategoriSelected(String kategori) {
    setState(() {
      _selectedKategori = kategori;
      _filterResep(_searchController.text); 
    });
  }

  Future<void> _navigateToForm({Resep? resep}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormResepScreen(resep: resep),
      ),
    );
    if (result == true || result is Resep) _loadData(); 
  }
  
  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anda telah logout.'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.orange.shade50,
    body: SafeArea(
      child: Column(
        children: [
          // Bagian Header dan Search tetap diam di atas (tidak ikut scroll)
          _buildHeader(),
          _buildSearchBar(),
          
          // Bagian yang bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Memaksa agar selalu bisa di-scroll
              child: Column(
                children: [
                  _buildKategoriGrid(),
                  
                  // Gunakan Container dengan tinggi minimal agar Grid resep muncul
                  _isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: _buildLoadingState(),
                        )
                      : _filteredResepList.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: _buildEmptyState(),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 80), // Ruang agar tidak tertutup tombol FAB
                              child: _buildResepGrid(),
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: _buildFloatingActionButton(),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}

  Widget _buildKategoriGrid() {
    if (_searchController.text.isNotEmpty && _selectedKategori == 'Semua') {
      return const SizedBox(height: 10); 
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true, 
        physics: const NeverScrollableScrollPhysics(), 
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // 4 Kolom agar sesuai dengan 4 kategori + Semua
          crossAxisCount: 4, 
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9, // sedikit lebih tinggi
        ),
        itemCount: _kategoriList.length,
        itemBuilder: (context, index) {
          final kategori = _kategoriList[index];
          final isSelected = kategori == _selectedKategori;
          final iconData = _kategoriIcons[kategori] ?? Icons.category;

          return GestureDetector(
            onTap: () => _onKategoriSelected(kategori),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepOrange.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? Colors.deepOrange.shade400 : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? Colors.deepOrange.withAlpha(50) : Colors.grey.withAlpha(20),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: 28,
                    color: isSelected ? Colors.deepOrange.shade700 : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    kategori.split(' ').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' '),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.deepOrange.shade900 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() { /* ... kode _buildHeader Anda ... */ return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Resep',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Temukan resep favoritmu 👨‍🍳',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Colors.orange.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_resepList.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 10), 
              
              InkWell(
                onTap: _handleLogout,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withAlpha(13),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ); }
  
  Widget _buildSearchBar() { /* ... kode _buildSearchBar Anda ... */ return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterResep,
        decoration: InputDecoration(
          hintText: 'Cari resep atau kategori...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.search,
              color: Colors.orange.shade700,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.orange.shade700),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                    _filterResep('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ); }

  Widget _buildLoadingState() { /* ... kode _buildLoadingState Anda ... */ return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: Colors.orange.shade700,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '🍳 Memuat resep lezat...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ); }

  Widget _buildEmptyState() { /* ... kode _buildEmptyState Anda ... */ return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.orange.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty
                ? '🍽 Belum ada resep'
                : '🔍 Resep tidak ditemukan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchController.text.isEmpty
                  ? 'Tambahkan resep pertamamu sekarang!'
                  : 'Coba kata kunci lain',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ); }

 Widget _buildResepGrid() {
  return RefreshIndicator(
    onRefresh: _loadData,
    color: Colors.orange.shade700,
    child: GridView.builder(
      shrinkWrap: true, // WAJIB: Agar GridView mengikuti panjang konten
      physics: const NeverScrollableScrollPhysics(), // WAJIB: Agar tidak bentrok dengan scroll utama
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  childAspectRatio: 0.85, // Diubah dari 0.75 ke 0.85 agar kartu tidak terlalu jenjang
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
),
      itemCount: _filteredResepList.length,
      itemBuilder: (context, index) {
        return _buildResepCard(_filteredResepList[index]);
      },
    ),
  );
}

  Widget _buildResepCard(Resep resep) {
  return GestureDetector(
    onTap: () { /* ... tetap sama ... */ },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ BAGIAN GAMBAR: Kita buat mengambil 70% ruang kartu
          Expanded(
            flex: 7, 
            child: _buildCardImage(resep),
          ),
          // 📝 BAGIAN TEKS: Mengambil sisa ruang
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    resep.namaResep,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildCategoryBadge(resep.kategori),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // 🚀 PERUBAHAN UTAMA: Menggunakan Image.asset
 Widget _buildCardImage(Resep resep) {
  final String fileName = (resep.imageUrl ?? '').trim();

  return Container(
    height: 160, // Diubah dari 140 ke 160 agar lebih tinggi
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.orange.shade100,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: _buildImageLoader(fileName), // Di sini sudah pakai BoxFit.cover jadi akan full
    ),
  );
}

// Fungsi pembantu untuk mendeteksi apakah itu URL atau File Lokal
Widget _buildImageLoader(String path) {
  if (path.isEmpty) {
    return _buildPlaceholderImage();
  }

  // JIKA diawali http, maka ambil dari INTERNET
  if (path.startsWith('http') || path.startsWith('https')) {
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange.shade300));
      },
    );
  } 
  
  // JIKA BUKAN http, maka ambil dari FOLDER ASSETS
  else {
    return Image.asset(
      'assets/images/$path',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
    );
  }
}

  Widget _buildPlaceholderImage() { /* ... kode _buildPlaceholderImage Anda ... */ return Center(
      child: Icon(
        Icons.restaurant,
        size: 60,
        color: Colors.white.withAlpha(200),
      ),
    ); }

  Widget _buildCategoryBadge(String kategori) { /* ... kode _buildCategoryBadge Anda ... */ return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category,
            size: 12,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              kategori,
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ); }

  Widget _buildCardFooter(Resep resep) { /* ... kode _buildCardFooter Anda ... */ return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 14,
          color: Colors.orange.shade600,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            resep.waktuMasak,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward,
            size: 16,
            color: Colors.orange.shade700,
          ),
        ),
      ],
    ); }

  Widget _buildFloatingActionButton() { /* ... kode _buildFloatingActionButton Anda ... */ return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade500,
            Colors.deepOrange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(13),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Resep',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ); }
}