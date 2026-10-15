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

Dalam pengembangan/rencana: notifikasi pengingat, mode offline (SQLite), kalender.

## Menjalankan
1. Jalankan backend (lihat README `tenggat-api`).
2. `flutter pub get`
3. Ubah `baseUrl` di `lib/api_service.dart` (emulator: `http://10.0.2.2:8000/api`; HP asli dengan `adb reverse tcp:8000 tcp:8000`: `http://127.0.0.1:8000/api`).
4. `flutter run`
