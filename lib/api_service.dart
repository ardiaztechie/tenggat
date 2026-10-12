import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tugas.dart';

class ApiService {
  // Emulator Android: 10.0.2.2 = localhost laptop.
  // HP asli: lihat petunjuk (adb reverse atau IP laptop).
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Future<List<Tugas>> ambilSemua() async {
    final res = await http.get(Uri.parse('$baseUrl/tugas'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Gagal memuat data');
    final body = jsonDecode(res.body);
    return (body['data'] as List).map((e) => Tugas.fromJson(e)).toList();
  }

  static Future<Statistik> statistik() async {
    final res = await http.get(Uri.parse('$baseUrl/tugas/statistik'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Gagal memuat statistik');
    return Statistik.fromJson(jsonDecode(res.body));
  }

  static Future<Tugas> tambah(Tugas t) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tugas'),
      headers: _headers,
      body: jsonEncode(t.toJson()),
    );
    if (res.statusCode != 201) throw Exception('Gagal menambah tugas');
    return Tugas.fromJson(jsonDecode(res.body));
  }

  static Future<void> ubah(Tugas t) async {
    final res = await http.put(
      Uri.parse('$baseUrl/tugas/${t.id}'),
      headers: _headers,
      body: jsonEncode(t.toJson()),
    );
    if (res.statusCode != 200) throw Exception('Gagal mengubah tugas');
  }

  static Future<void> hapus(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/tugas/$id'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Gagal menghapus tugas');
  }

  /// Unggah (atau ganti) foto lampiran.
  static Future<void> unggahFoto(int id, String jalurFile) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/tugas/$id/foto'));
    req.headers['Accept'] = 'application/json';
    req.files.add(await http.MultipartFile.fromPath('foto', jalurFile));
    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode != 200) throw Exception('Gagal mengunggah foto');
  }

  static Future<void> hapusFoto(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/tugas/$id/foto'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Gagal menghapus foto');
  }
}
