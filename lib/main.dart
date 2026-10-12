import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'bantu.dart';
import 'detail_tugas.dart';
import 'form_tugas.dart';
import 'halaman_statistik.dart';
import 'tugas.dart';
import 'ubin_tugas.dart';

void main() => runApp(const TenggatApp());

class TenggatApp extends StatelessWidget {
  const TenggatApp({super.key});

  @override
  Widget build(BuildContext context) {
    const warna = Color(0xFF14A3A0);
    return MaterialApp(
      title: 'Tenggat',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(colorSchemeSeed: warna, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: warna,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HalamanUtama(),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  List<Tugas> _daftar = [];
  Statistik? _statistik;
  bool _memuat = true;
  String? _galat;
  int _tab = 0;

  // Tugas yang baru dicentang tetap tampil sebentar di Beranda.
  final Set<int> _baruDicentang = {};

  final AudioPlayer _pemutar = AudioPlayer();
  final _klunting = buatKlunting();

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _pemutar.dispose();
    super.dispose();
  }

  Future<void> _muat({bool diam = false}) async {
    if (!diam) {
      setState(() {
        _memuat = true;
        _galat = null;
      });
    }
    try {
      final hasil = await Future.wait([
        ApiService.ambilSemua(),
        ApiService.statistik(),
      ]);
      if (!mounted) return;
      setState(() {
        _daftar = hasil[0] as List<Tugas>;
        _statistik = hasil[1] as Statistik;
        _memuat = false;
        _galat = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _memuat = false;
        _galat = 'Tidak bisa terhubung ke server.\nPastikan Laravel sudah jalan.';
      });
    }
  }

  void _pesan(String teks, {SnackBarAction? aksi}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks), action: aksi));
  }

  Future<void> _bunyi() async {
    try {
      await _pemutar.stop();
      await _pemutar.play(BytesSource(_klunting));
    } catch (_) {}
  }

  Future<void> _lihat(Tugas t) async {
    final r = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DetailTugas(t: t),
    );
    if (r == 'edit') await _bukaForm(t);
  }

  Future<void> _bukaForm([Tugas? lama]) async {
    final hasil = await showModalBottomSheet<HasilForm>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FormTugas(lama: lama),
    );
    if (hasil == null) return;
    try {
      int id;
      if (lama == null) {
        final baru = await ApiService.tambah(hasil.tugas);
        id = baru.id!;
      } else {
        await ApiService.ubah(hasil.tugas);
        id = lama.id!;
      }
      if (hasil.fotoBaru != null) {
        await ApiService.unggahFoto(id, hasil.fotoBaru!);
      } else if (hasil.hapusFoto) {
        await ApiService.hapusFoto(id);
      }
      await _muat(diam: true);
    } catch (e) {
      _pesan('$e');
      await _muat(diam: true);
    }
  }

  Future<void> _centang(Tugas t) async {
    final baru = t.salin(selesai: !t.selesai);
    final id = t.id!;
    if (baru.selesai) {
      _bunyi();
      _baruDicentang.add(id);
    }
    setState(() {
      _daftar = _daftar.map((x) => x.id == id ? baru : x).toList();
    });
    if (baru.selesai) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _baruDicentang.remove(id));
      });
      _pesan(
        'Tugas selesai. Bagus!',
        aksi: SnackBarAction(label: 'BATAL', onPressed: () => _centang(baru)),
      );
    }
    try {
      await ApiService.ubah(baru);
      await _muat(diam: true); // segarkan statistik
    } catch (e) {
      _pesan('$e');
      await _muat(diam: true);
    }
  }

  Future<void> _hapus(Tugas t) async {
    setState(() => _daftar = _daftar.where((x) => x.id != t.id).toList());
    try {
      await ApiService.hapus(t.id!);
      await _muat(diam: true);
    } catch (e) {
      _pesan('$e');
      await _muat(diam: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const judul = ['Tenggat', 'Riwayat', 'Statistik'];
    return Scaffold(
      appBar: AppBar(
        title: Text(judul[_tab], style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _bukaForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Statistik'),
        ],
      ),
      body: _isi(),
    );
  }

  Widget _isi() {
    if (_memuat) return const Center(child: CircularProgressIndicator());
    if (_galat != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_galat!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => _muat(), child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }
    switch (_tab) {
      case 1:
        return _riwayat();
      case 2:
        return HalamanStatistik(
          statistik: _statistik,
          daftar: _daftar,
          onMuat: () => _muat(diam: true),
          onBuka: _lihat,
          onCentang: _centang,
          onHapus: _hapus,
        );
      default:
        return _beranda();
    }
  }

  Widget _ubin(Tugas t) => UbinTugas(
        t: t,
        onTap: () => _lihat(t),
        onCentang: () => _centang(t),
        onHapus: () => _hapus(t),
      );

  Widget _beranda() {
    final tampil =
        _daftar.where((t) => !t.selesai || _baruDicentang.contains(t.id)).toList();
    final aktif = tampil.where((t) => !t.selesai).toList();
    final mendesak = aktif
        .where((t) => !t.terlambat && t.tenggat.difference(DateTime.now()).inHours < 24)
        .length;
    final terlambat = aktif.where((t) => t.terlambat).length;
    return RefreshIndicator(
      onRefresh: () => _muat(diam: true),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _Ringkasan(menunggu: aktif.length, mendesak: mendesak, terlambat: terlambat),
          if (tampil.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Belum ada tugas.\nKetuk "Tambah" untuk mulai.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          for (final t in tampil) _ubin(t),
        ],
      ),
    );
  }

  Widget _riwayat() {
    final selesai = _daftar.where((t) => t.selesai).toList()
      ..sort((a, b) => (b.selesaiPada ?? b.tenggat).compareTo(a.selesaiPada ?? a.tenggat));
    return RefreshIndicator(
      onRefresh: () => _muat(diam: true),
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          if (selesai.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Belum ada tugas yang selesai.\nCentang tugas di Beranda.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          for (final t in selesai) _ubin(t),
        ],
      ),
    );
  }
}

class _Ringkasan extends StatelessWidget {
  final int menunggu;
  final int mendesak;
  final int terlambat;
  const _Ringkasan({
    required this.menunggu,
    required this.mendesak,
    required this.terlambat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hari ini', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$menunggu tugas',
                  style: const TextStyle(
                    color: Color(0xFFF2B134),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: ' menunggu',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          if (mendesak > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '$mendesak mendesak (kurang dari 24 jam)',
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
              ),
            ),
          if (terlambat > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$terlambat terlambat',
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
