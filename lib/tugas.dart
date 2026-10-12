DateTime? _urai(dynamic nilai) {
  if (nilai == null) return null;
  try {
    return DateTime.parse((nilai as String).replaceFirst(' ', 'T')).toLocal();
  } catch (_) {
    return null;
  }
}

class Tugas {
  final int? id;
  final String judul;
  final String mataKuliah;
  final DateTime tenggat;
  final String prioritas; // rendah / sedang / tinggi
  final bool selesai;
  final DateTime? selesaiPada;
  final String catatan;
  final String? fotoUrl;

  const Tugas({
    this.id,
    required this.judul,
    this.mataKuliah = '',
    required this.tenggat,
    this.prioritas = 'sedang',
    this.selesai = false,
    this.selesaiPada,
    this.catatan = '',
    this.fotoUrl,
  });

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      id: json['id'],
      judul: json['judul'] ?? '',
      mataKuliah: json['mata_kuliah'] ?? '',
      // Laravel mengirim "2026-10-17 23:59:00" (waktu lokal, tanpa zona)
      tenggat: DateTime.parse((json['tenggat'] as String).replaceFirst(' ', 'T')),
      prioritas: json['prioritas'] ?? 'sedang',
      selesai: json['selesai'] == true || json['selesai'] == 1,
      selesaiPada: (json['selesai_pada'] is String &&
              (json['selesai_pada'] as String).endsWith('Z'))
          ? _urai(json['selesai_pada'])
          : (json['selesai_pada'] == null
              ? null
              : DateTime.tryParse((json['selesai_pada'] as String).replaceFirst(' ', 'T'))),
      catatan: json['catatan'] ?? '',
      fotoUrl: json['foto_url'],
    );
  }

  static String _dua(int n) => n.toString().padLeft(2, '0');

  Map<String, dynamic> toJson() => {
        'judul': judul,
        'mata_kuliah': mataKuliah,
        'tenggat':
            '${tenggat.year}-${_dua(tenggat.month)}-${_dua(tenggat.day)} ${_dua(tenggat.hour)}:${_dua(tenggat.minute)}:00',
        'prioritas': prioritas,
        'selesai': selesai,
        'catatan': catatan,
      };

  /// Belum selesai dan tenggatnya sudah lewat.
  bool get terlambat => !selesai && tenggat.isBefore(DateTime.now());

  /// Selesai sebelum atau tepat pada tenggat.
  bool get selesaiTepat =>
      selesai && selesaiPada != null && !selesaiPada!.isAfter(tenggat);

  Tugas salin({bool? selesai}) {
    final baruSelesai = selesai ?? this.selesai;
    return Tugas(
      id: id,
      judul: judul,
      mataKuliah: mataKuliah,
      tenggat: tenggat,
      prioritas: prioritas,
      selesai: baruSelesai,
      selesaiPada: baruSelesai ? (this.selesai ? selesaiPada : DateTime.now()) : null,
      catatan: catatan,
      fotoUrl: fotoUrl,
    );
  }
}

class Statistik {
  final int total;
  final int selesai;
  final int aktif;
  final int terlambat;
  final int tepatWaktu;
  final int persenTepatWaktu;
  final List<({String label, int jumlah})> harian;

  const Statistik({
    required this.total,
    required this.selesai,
    required this.aktif,
    required this.terlambat,
    required this.tepatWaktu,
    required this.persenTepatWaktu,
    required this.harian,
  });

  factory Statistik.fromJson(Map<String, dynamic> json) {
    return Statistik(
      total: json['total'] ?? 0,
      selesai: json['selesai'] ?? 0,
      aktif: json['aktif'] ?? 0,
      terlambat: json['terlambat'] ?? 0,
      tepatWaktu: json['tepat_waktu'] ?? 0,
      persenTepatWaktu: json['persen_tepat_waktu'] ?? 0,
      harian: (json['harian'] as List)
          .map((e) => (label: e['label'] as String, jumlah: e['jumlah'] as int))
          .toList(),
    );
  }
}
