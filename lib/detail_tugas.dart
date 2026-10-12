import 'package:flutter/material.dart';

import 'bantu.dart';
import 'tugas.dart';

/// Tampilan baca: foto, catatan, tenggat. Tombol Edit menutup sheet
/// dan mengembalikan 'edit'.
class DetailTugas extends StatelessWidget {
  final Tugas t;
  const DetailTugas({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final redup = Theme.of(context).colorScheme.onSurfaceVariant;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.judul, style: Theme.of(context).textTheme.titleLarge),
          if (t.mataKuliah.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(t.mataKuliah, style: TextStyle(color: redup)),
            ),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.event, size: 18, color: redup),
            const SizedBox(width: 6),
            Text('${tglTeks(t.tenggat)} · ${jamTeks(t.tenggat)}'),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.flag, size: 18, color: warnaPrioritas(t.prioritas)),
            const SizedBox(width: 6),
            Text('Prioritas ${t.prioritas}'),
          ]),
          if (t.selesaiPada != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.check_circle, size: 18, color: Colors.green),
              const SizedBox(width: 6),
              Text('Selesai ${tglTeks(t.selesaiPada!)} · ${jamTeks(t.selesaiPada!)}'),
            ]),
          ],
          const SizedBox(height: 16),
          Text('Catatan', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(t.catatan.isEmpty ? 'Tidak ada catatan.' : t.catatan,
              style: t.catatan.isEmpty ? TextStyle(color: redup) : null),
          if (t.fotoUrl != null) ...[
            const SizedBox(height: 16),
            Text('Foto', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(child: Image.network(t.fotoUrl!)),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  t.fotoUrl!,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 80,
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, 'edit'),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}
