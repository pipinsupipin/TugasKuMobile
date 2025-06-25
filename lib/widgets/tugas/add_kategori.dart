import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/widgets/overlay/add_kategori_overlay.dart';

class AddKategoriButton extends StatelessWidget {
  final VoidCallback? onKategoriAdded;
  
  const AddKategoriButton({
    super.key,
    this.onKategoriAdded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Tampilkan dialog tambah kategori
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AddKategoriOverlay(
            onKategoriAdded: () {
              // Jangan panggil Navigator.pop disini, biarkan AddKategoriOverlay yang menangani
              
              // Panggil callback setelah kategori berhasil ditambahkan
              if (onKategoriAdded != null) {
                onKategoriAdded!();
              }
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 30,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tambah Kategori",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}