import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'bantu.dart';
import 'tugas.dart';

/// Pengingat tenggat lewat notifikasi lokal (tanpa server).
/// Tiap tugas yang belum selesai dijadwalkan tiga pengingat:
/// H-3, H-1, dan 1 jam sebelum tenggat. Pengingat yang waktunya sudah lewat dilewati.
class LayananNotifikasi {
  LayananNotifikasi._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _siap = false;

  static const _idKanal = 'pengingat_tugas';

  static const _rincian = NotificationDetails(
    android: AndroidNotificationDetails(
      _idKanal,
      'Pengingat tugas',
      channelDescription: 'Pengingat sebelum tenggat tugas',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  // kode dipakai menyusun ID notifikasi: id tugas x 10 + kode.
  static const _jadwal = <({int kode, Duration sebelum, String judul})>[
    (kode: 1, sebelum: Duration(days: 3), judul: 'Tenggat 3 hari lagi (H-3)'),
    (kode: 2, sebelum: Duration(days: 1), judul: 'Tenggat besok (H-1)'),
    (kode: 3, sebelum: Duration(hours: 1), judul: 'Tenggat 1 jam lagi'),
  ];

  /// Panggil sekali saat aplikasi mulai. Meminta izin notifikasi (Android 13+).
  static Future<void> mulai() async {
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      _siap = true;
    } catch (_) {
      _siap = false; // aplikasi tetap jalan tanpa notifikasi
    }
  }

  /// Susun ulang semua pengingat sesuai daftar tugas terbaru.
  static Future<void> jadwalkan(List<Tugas> daftar) async {
    if (!_siap) return;
    try {
      await _plugin.cancelAll();
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final tepat = await android?.canScheduleExactNotifications() ?? false;
      final mode = tepat
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
      final sekarang = DateTime.now();

      for (final t in daftar) {
        if (t.selesai || t.id == null) continue;
        for (final p in _jadwal) {
          final waktu = t.tenggat.subtract(p.sebelum);
          if (!waktu.isAfter(sekarang)) continue;
          final mk = t.mataKuliah.isEmpty ? '' : ' · ${t.mataKuliah}';
          await _plugin.zonedSchedule(
            t.id! * 10 + p.kode,
            p.judul,
            '${t.judul}$mk\n${tglTeks(t.tenggat)} · ${jamTeks(t.tenggat)}',
            // Waktu mutlak: UTC dipakai hanya sebagai penampung, jam bunyinya tetap tepat.
            tz.TZDateTime.from(waktu, tz.UTC),
            _rincian,
            androidScheduleMode: mode,
          );
        }
      }
    } catch (_) {
      // Gagal menjadwalkan tidak boleh mengganggu aplikasi.
    }
  }

  /// Notifikasi percobaan, untuk memastikan izin dan kanal berfungsi.
  /// Mengembalikan false jika notifikasi tidak tersedia.
  static Future<bool> uji() async {
    if (!_siap) return false;
    try {
      await _plugin.show(
        0,
        'Tenggat',
        'Notifikasi berfungsi. Pengingat akan muncul H-3, H-1, dan 1 jam sebelum tenggat.',
        _rincian,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
