import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'bantu.dart';
import 'tugas.dart';

/// Hasil form: data tugas + keputusan soal foto.
class HasilForm {
  final Tugas tugas;
  final String? fotoBaru; // jalur file foto yang baru dipilih
  final bool hapusFoto; // true jika foto lama dihapus

  const HasilForm({required this.tugas, this.fotoBaru, this.hapusFoto = false});
}

class FormTugas extends StatefulWidget {
  final Tugas? lama;
  const FormTugas({super.key, this.lama});

  @override
  State<FormTugas> createState() => _FormTugasState();
}

class _FormTugasState extends State<FormTugas> {
  final _kunci = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _matkul;
  late final TextEditingController _catatan;
  late String _prioritas;
  late DateTime _tenggat;
  String? _fotoBaru;
  bool _hapusFoto = false;

  @override
  void initState() {
    super.initState();
    final l = widget.lama;
    _judul = TextEditingController(text: l?.judul ?? '');
    _matkul = TextEditingController(text: l?.mataKuliah ?? '');
    _catatan = TextEditingController(text: l?.catatan ?? '');
    _prioritas = l?.prioritas ?? 'sedang';
    if (l != null) {
      _tenggat = l.tenggat;
    } else {
      final b = DateTime.now().add(const Duration(days: 1));
      _tenggat = DateTime(b.year, b.month, b.day, 23, 59);
    }
  }

  @override
  void dispose() {
    _judul.dispose();
    _matkul.dispose();
    _catatan.dispose();
    super.dispose();
  }

  bool get _adaFoto => _fotoBaru != null || (widget.lama?.fotoUrl != null && !_hapusFoto);

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tenggat,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() {
      _tenggat = DateTime(d.year, d.month, d.day, _tenggat.hour, _tenggat.minute);
    });
  }

  Future<void> _pilihJam() async {
    final j = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_tenggat),
    );
    if (j == null) return;
    setState(() {
      _tenggat = DateTime(_tenggat.year, _tenggat.month, _tenggat.day, j.hour, j.minute);
    });
  }

  Future<void> _ambilFoto(ImageSource sumber) async {
    try {
      final f = await ImagePicker().pickImage(
        source: sumber,
        maxWidth: 1600,
        imageQuality: 75,
      );
      if (f == null) return;
      setState(() {
        _fotoBaru = f.path;
        _hapusFoto = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Foto tidak bisa diambil')));
    }
  }

  void _buangFoto() {
    setState(() {
      _fotoBaru = null;
      _hapusFoto = widget.lama?.fotoUrl != null;
    });
  }

  void _simpan() {
    if (!_kunci.currentState!.validate()) return;
    Navigator.pop(
      context,
      HasilForm(
        tugas: Tugas(
          id: widget.lama?.id,
          judul: _judul.text.trim(),
          mataKuliah: _matkul.text.trim(),
          tenggat: _tenggat,
          prioritas: _prioritas,
          selesai: widget.lama?.selesai ?? false,
          selesaiPada: widget.lama?.selesaiPada,
          catatan: _catatan.text.trim(),
          fotoUrl: widget.lama?.fotoUrl,
        ),
        fotoBaru: _fotoBaru,
        hapusFoto: _hapusFoto && _fotoBaru == null,
      ),
    );
  }

  Widget _pratinjauFoto() {
    final Widget gambar;
    if (_fotoBaru != null) {
      gambar = Image.file(File(_fotoBaru!), fit: BoxFit.cover);
    } else {
      gambar = Image.network(
        widget.lama!.fotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(height: 180, width: double.infinity, child: gambar),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _kunci,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.lama == null ? 'Tambah Tugas' : 'Edit Tugas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(
                labelText: 'Judul tugas',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _matkul,
              decoration: const InputDecoration(
                labelText: 'Mata kuliah',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pilihTanggal,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(tglTeks(_tenggat)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pilihJam,
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(jamTeks(_tenggat)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'rendah', label: Text('Rendah')),
                ButtonSegment(value: 'sedang', label: Text('Sedang')),
                ButtonSegment(value: 'tinggi', label: Text('Tinggi')),
              ],
              selected: {_prioritas},
              onSelectionChanged: (s) => setState(() => _prioritas = s.first),
            ),
            const SizedBox(height: 16),
            Text('Lampiran', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_adaFoto) ...[
              _pratinjauFoto(),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _ambilFoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _ambilFoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Galeri'),
                  ),
                ),
                if (_adaFoto)
                  IconButton(
                    onPressed: _buangFoto,
                    tooltip: 'Hapus foto',
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _catatan,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
