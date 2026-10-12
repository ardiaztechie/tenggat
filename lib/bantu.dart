import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

String tglTeks(DateTime d) => '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';

String jamTeks(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

Color warnaPrioritas(String p) {
  switch (p) {
    case 'tinggi':
      return Colors.red;
    case 'sedang':
      return Colors.orange;
    default:
      return Colors.blueGrey;
  }
}

/// Teks dan warna chip sisa waktu: H-3, 5 jam, Terlambat.
({String teks, Color warna}) sisaWaktu(DateTime tenggat) {
  final selisih = tenggat.difference(DateTime.now());
  if (selisih.isNegative) return (teks: 'Terlambat', warna: Colors.red);
  if (selisih.inHours < 1) return (teks: '${selisih.inMinutes} mnt', warna: Colors.deepOrange);
  if (selisih.inHours < 24) return (teks: '${selisih.inHours} jam', warna: Colors.deepOrange);
  final hari = selisih.inDays;
  return (teks: 'H-$hari', warna: hari <= 3 ? Colors.orange : Colors.teal);
}

/// Membuat bunyi "klunting" (dua nada lonceng) langsung dari kode,
/// jadi tidak perlu file suara tambahan.
Uint8List buatKlunting() {
  const laju = 22050;
  const detik = 0.7;
  final n = (laju * detik).round();
  final data = ByteData(44 + n * 2);

  void teks(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  teks(0, 'RIFF');
  data.setUint32(4, 36 + n * 2, Endian.little);
  teks(8, 'WAVE');
  teks(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, laju, Endian.little);
  data.setUint32(28, laju * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  teks(36, 'data');
  data.setUint32(40, n * 2, Endian.little);

  double lonceng(double t, double f) {
    if (t < 0) return 0;
    return math.exp(-8 * t) *
        (math.sin(2 * math.pi * f * t) + 0.35 * math.sin(2 * math.pi * f * 2.0 * t));
  }

  for (var i = 0; i < n; i++) {
    final t = i / laju;
    final s = lonceng(t, 1175) + lonceng(t - 0.11, 1568);
    data.setInt16(44 + i * 2, (s * 0.45 * 32767).round(), Endian.little);
  }
  return data.buffer.asUint8List();
}
