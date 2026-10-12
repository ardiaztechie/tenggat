import 'package:flutter/material.dart';
import 'bantu.dart';
import 'tugas.dart';

/// Satu baris tugas: centang, judul, mata kuliah, tenggat, chip sisa waktu.
/// Geser ke kiri untuk menghapus.
class UbinTugas extends StatelessWidget {
  final Tugas t;
  final VoidCallback onTap;
  final VoidCallback onCentang;
  final VoidCallback onHapus;

  const UbinTugas({
    super.key,
    required this.t,
    required this.onTap,
    required this.onCentang,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final redup = Theme.of(context).colorScheme.onSurfaceVariant;
    final sp = t.selesaiPada;
    final baris3 = (t.selesai && sp != null)
        ? 'Selesai ${tglTeks(sp)} · ${jamTeks(sp)}'
        : '${tglTeks(t.tenggat)} · ${jamTeks(t.tenggat)}';

    final ({String teks, Color warna}) chip;
    if (t.selesai) {
      chip = t.selesaiTepat
          ? (teks: 'Tepat waktu', warna: Colors.green)
          : (teks: 'Terlambat', warna: Colors.orange);
    } else {
      chip = sisaWaktu(t.tenggat);
    }

    return Dismissible(
      key: ValueKey('tugas-${t.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onHapus(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: warnaPrioritas(t.prioritas)),
                Checkbox(value: t.selesai, onChanged: (_) => onCentang()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                t.judul,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      t.selesai ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            if (t.fotoUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(Icons.photo_camera_outlined, size: 15, color: redup),
                              ),
                            if (t.catatan.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(Icons.notes, size: 15, color: redup),
                              ),
                          ],
                        ),
                        if (t.mataKuliah.isNotEmpty)
                          Text(t.mataKuliah, style: TextStyle(fontSize: 12, color: redup)),
                        Text(baris3, style: TextStyle(fontSize: 12, color: redup)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: chip.warna.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        chip.teks,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: chip.warna,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
