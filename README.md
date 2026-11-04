# Tenggat

Aplikasi pengingat tugas dan jadwal kuliah untuk mahasiswa.
Tugas-1 · Praktikum Pemrograman Bergerak (TIF-2024) · BK19

**Penyusun:** Ardiaz Agust Sujatmiko · NIM 2305101145

## Isi repository
- `docs/` : dokumen analisis kebutuhan pengguna dan karakteristik perangkat bergerak (PDF dan Word).
- `lib/` : kode aplikasi Flutter (Android).
- Backend (Laravel REST API + MySQL): https://github.com/ardiaztechie/tenggat-api

## Fitur pada prototipe
- Tambah, ubah, hapus tugas (judul, mata kuliah, tenggat, prioritas)
- Lampiran foto (kamera/galeri) dan catatan
- Centang selesai dengan bunyi "klunting"
- Riwayat tugas selesai
- Statistik ketepatan waktu dan filter tugas terlambat
- Mode gelap mengikuti tema sistem
- Notifikasi pengingat H-3, H-1, dan 1 jam sebelum tenggat (notifikasi lokal, tetap bunyi walau aplikasi ditutup)
- Cari tugas (judul, mata kuliah, catatan) dan filter prioritas serta mata kuliah di Beranda

Dalam pengembangan/rencana: mode offline (SQLite), kalender.

## Izin Android
| Izin | Dipakai untuk |
|---|---|
| `INTERNET` | Terhubung ke API Laravel |
| `POST_NOTIFICATIONS` | Menampilkan pengingat (Android 13+, diminta saat pertama dibuka) |
| `SCHEDULE_EXACT_ALARM` | Pengingat tepat waktu; jika tidak diberikan, aplikasi memakai jadwal hemat daya |
| `RECEIVE_BOOT_COMPLETED` | Pengingat tetap aktif setelah HP dinyalakan ulang |
| Kamera / galeri | Lampiran foto lewat `image_picker` (izin kamera diminta saat dipakai) |

## Menjalankan
1. Jalankan backend (lihat README `tenggat-api`).
2. `flutter pub get`
3. Ubah `baseUrl` di `lib/api_service.dart` (emulator: `http://10.0.2.2:8000/api`; HP asli dengan `adb reverse tcp:8000 tcp:8000`: `http://127.0.0.1:8000/api`).
4. `flutter run`
