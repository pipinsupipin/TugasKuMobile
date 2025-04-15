import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/kategori.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/widgets/overlay/detail_kategori_overlay.dart';
import 'package:tugasku/widgets/tugas/progress_bar_widget.dart';

class KategoriTugas extends StatelessWidget {
  final Kategori kategori;

  const KategoriTugas({
    super.key,
    required this.kategori,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final tugasDalamKategori = tugas
          .where((t) => t.kategoriTugas == kategori.namaKategori)
          .toList();

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) {
            return DetailKategoriOverlay(
              kategori: kategori,
              tugasList: tugasDalamKategori,
              onClose: () => Navigator.of(context).pop(),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(14),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.4,
                        child: Icon(
                          kategori.icon,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    kategori.namaKategori,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    kategori.tanggal,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ProgressBar(progress: kategori.progressDecimal)),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${kategori.sisaTugas}/${kategori.totalTugas} Selesai',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
