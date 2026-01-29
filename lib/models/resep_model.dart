// lib/models/resep_model.dart

class Resep {
  final String id;
  final String namaResep;
  final String kategori;
  final String waktuMasak;
  final String tingkatKesulitan;
  final String deskripsiSingkat;
  final List<String> bahan;
  final List<String> langkahMemasak;
  final String? imageUrl;

  const Resep({
    required this.id,
    required this.namaResep,
    required this.kategori,
    required this.waktuMasak,
    required this.tingkatKesulitan,
    required this.deskripsiSingkat,
    required this.bahan,
    required this.langkahMemasak,
    this.imageUrl,
  });

  // ✅ PERBAIKAN: Konversi ID dari int/String ke String
  factory Resep.fromJson(Map<String, dynamic> json) {
    return Resep(
      // ✅ FIX: MockAPI mengembalikan ID sebagai int, kita konversi ke String
      id: json['id'].toString(), // ← INI PERBAIKANNYA!
      namaResep: json['namaResep'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      waktuMasak: json['waktuMasak'] as String? ?? '',
      tingkatKesulitan: json['tingkatKesulitan'] as String? ?? '',
      deskripsiSingkat: json['deskripsiSingkat'] as String? ?? '',
      // Mapping untuk List<String> dengan null safety
      bahan: (json['bahan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      langkahMemasak: (json['langkahmemasak'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      imageUrl: json['imageUrl'] as String?,
    );
  }

  // ✅ toJson sudah benar
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaResep': namaResep,
      'kategori': kategori,
      'waktuMasak': waktuMasak,
      'tingkatKesulitan': tingkatKesulitan,
      'deskripsiSingkat': deskripsiSingkat,
      'bahan': bahan,
      'langkahmemasak': langkahMemasak,
      'imageUrl': imageUrl,
    };
  }
  
  // ✅ BONUS: Tambahkan copyWith untuk kemudahan update
  Resep copyWith({
    String? id,
    String? namaResep,
    String? kategori,
    String? waktuMasak,
    String? tingkatKesulitan,
    String? deskripsiSingkat,
    List<String>? bahan,
    List<String>? langkahMemasak,
    String? imageUrl,
  }) {
    return Resep(
      id: id ?? this.id,
      namaResep: namaResep ?? this.namaResep,
      kategori: kategori ?? this.kategori,
      waktuMasak: waktuMasak ?? this.waktuMasak,
      tingkatKesulitan: tingkatKesulitan ?? this.tingkatKesulitan,
      deskripsiSingkat: deskripsiSingkat ?? this.deskripsiSingkat,
      bahan: bahan ?? this.bahan,
      langkahMemasak: langkahMemasak ?? this.langkahMemasak,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}