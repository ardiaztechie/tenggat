import 'package:flutter/material.dart';

import 'tugas.dart';
import 'ubin_tugas.dart';

enum _Saring { terlambat, tepat, selesaiTelat }

class HalamanStatistik extends StatefulWidget {
  final Statistik? statistik;
  final List<Tugas> daftar;
  final Future<void> Function() onMuat;
  final void Function(Tugas) onBuka;
  final void Function(Tugas) onCentang;
  final void Function(Tugas) onHapus;

  const HalamanStatistik({
    super.key,
    required this.statistik,
    required this.daftar,
    required this.onMuat,
    required this.onBuka,
    required this.onCentang,
    required this.onHapus,
  });

  @override
  State<HalamanStatistik> createState() => _HalamanStatistikState();
}

class _HalamanStatistikState extends State<HalamanStatistik> {
  _Saring _saring = _Saring.terlambat;

  List<Tugas> get _hasilSaring {
    switch (_saring) {
      case _Saring.terlambat:
        return widget.daftar.where((t) => t.terlambat).toList();
      case _Saring.tepat:
        return widget.daftar.where((t) => t.selesaiTepat).toList();
      case _Saring.selesaiTelat:
        return widget.daftar.where((t) => t.selesai && !t.selesaiTepat).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.statistik;
    if (s == null) return const Center(child: CircularProgressIndicator());

    final nTerlambat = widget.daftar.where((t) => t.terlambat).length;
    final nTepat = widget.daftar.where((t) => t.selesaiTepat).length;
    final nSelesaiTelat =
        widget.daftar.where((t) => t.selesai && !t.selesaiTepat).length;
    final hasil = _hasilSaring;

    return RefreshIndicator(
      onRefresh: widget.onMuat,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _judul(context, 'Ringkasan'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(children: [
                  _Angka('Total', s.total, Colors.blueGrey),
                  _Angka('Selesai', s.selesai, Colors.green),
                ]),
                Row(children: [
                  _Angka('Aktif', s.aktif, Colors.teal),
                  _Angka('Terlambat', nTerlambat, Colors.red),
                ]),
              ],
            ),
          ),
          _judul(context, 'Ketepatan waktu'),
          _KartuPersen(persen: s.persenTepatWaktu, tepat: s.tepatWaktu, selesai: s.selesai),
          _judul(context, 'Tugas selesai 7 hari terakhir'),
          _GrafikHarian(data: s.harian),
          _judul(context, 'Per mata kuliah'),
          _PerMatkul(daftar: widget.daftar),
          _judul(context, 'Saring tugas'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text('Terlambat ($nTerlambat)'),
                  selected: _saring == _Saring.terlambat,
                  onSelected: (_) => setState(() => _saring = _Saring.terlambat),
                ),
                ChoiceChip(
                  label: Text('Selesai tepat waktu ($nTepat)'),
                  selected: _saring == _Saring.tepat,
                  onSelected: (_) => setState(() => _saring = _Saring.tepat),
                ),
                ChoiceChip(
                  label: Text('Selesai terlambat ($nSelesaiTelat)'),
                  selected: _saring == _Saring.selesaiTelat,
                  onSelected: (_) => setState(() => _saring = _Saring.selesaiTelat),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (hasil.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Tidak ada tugas pada kategori ini.')),
            ),
          for (final t in hasil)
            UbinTugas(
              t: t,
              onTap: () => widget.onBuka(t),
              onCentang: () => widget.onCentang(t),
              onHapus: () => widget.onHapus(t),
            ),
        ],
      ),
    );
  }

  Widget _judul(BuildContext context, String teks) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Text(teks, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Angka extends StatelessWidget {
  final String label;
  final int nilai;
  final Color warna;
  const _Angka(this.label, this.nilai, this.warna);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$nilai',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: warna)),
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuPersen extends StatelessWidget {
  final int persen;
  final int tepat;
  final int selesai;
  const _KartuPersen({required this.persen, required this.tepat, required this.selesai});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: persen / 100,
                      strokeWidth: 8,
                      color: Colors.green,
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                    ),
                  ),
                  Text('$persen%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                selesai == 0
                    ? 'Belum ada tugas selesai.'
                    : '$tepat dari $selesai tugas selesai dikumpulkan tepat waktu.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrafikHarian extends StatelessWidget {
  final List<({String label, int jumlah})> data;
  const _GrafikHarian({required this.data});

  @override
  Widget build(BuildContext context) {
    final maks = data.fold<int>(1, (m, e) => e.jumlah > m ? e.jumlah : m);
    final warna = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final e in data)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${e.jumlah}', style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 2),
                      Container(
                        height: 4 + 80.0 * e.jumlah / maks,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: e.jumlah == 0 ? warna.withValues(alpha: 0.2) : warna,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(e.label, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerMatkul extends StatelessWidget {
  final List<Tugas> daftar;
  const _PerMatkul({required this.daftar});

  @override
  Widget build(BuildContext context) {
    final total = <String, int>{};
    final selesai = <String, int>{};
    for (final t in daftar) {
      final k = t.mataKuliah.isEmpty ? 'Tanpa mata kuliah' : t.mataKuliah;
      total[k] = (total[k] ?? 0) + 1;
      if (t.selesai) selesai[k] = (selesai[k] ?? 0) + 1;
    }
    if (total.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Belum ada data.'),
      );
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final k in total.keys)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(k, overflow: TextOverflow.ellipsis)),
                        Text('${selesai[k] ?? 0}/${total[k]}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (selesai[k] ?? 0) / total[k]!,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
