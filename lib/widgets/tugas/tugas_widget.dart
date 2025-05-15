import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/tugas.dart';
// import 'package:tugasku/widgets/common/button_widget.dart';
import 'package:tugasku/services/crud_service.dart';
import 'package:tugasku/widgets/overlay/detail_task_overlay.dart';

class TugasWidget extends StatefulWidget {
  final Tugas tugas;
  final void Function(Tugas) onTugasUpdated;

  const TugasWidget({
    required this.tugas,
    required this.onTugasUpdated,
  });

  @override
  State<TugasWidget> createState() => _TugasWidgetState();
}

class _TugasWidgetState extends State<TugasWidget> {
  late bool isChecked;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    isChecked = widget.tugas.isCompleted;
  }

  Future<void> getTugasById(int id) async {
    try {
      // Tugas detailTugas = await _apiService.getTugasById(id);

      // Buka overlay dengan data yang diambil
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: const EdgeInsets.only(top: 60),
          child: TaskDetailOverlay(tugasId: widget.tugas.id),
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  String formatWaktu(DateTime waktu) {
    // List nama hari dalam bahasa Indonesia
    List<String> hari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];

    // List nama bulan dalam bahasa Indonesia
    List<String> bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    // Ambil nama hari, tanggal, bulan, dan waktu
    String namaHari = hari[waktu.weekday % 7];
    String tanggal = waktu.day.toString().padLeft(2, '0');
    String namaBulan = bulan[waktu.month - 1];
    String jam = waktu.hour.toString().padLeft(2, '0');
    String menit = waktu.minute.toString().padLeft(2, '0');

    return '$namaHari, $tanggal $namaBulan - $jam.$menit';
  }

  @override
  Widget build(BuildContext context) {
    String waktu = '';

    if (widget.tugas.waktuMulai != null && widget.tugas.waktuSelesai != null) {
      waktu =
          '${formatWaktu(widget.tugas.waktuMulai!)} - ${formatWaktu(widget.tugas.waktuSelesai!)}';
    } else if (widget.tugas.waktuMulai != null) {
      waktu = formatWaktu(widget.tugas.waktuMulai!);
    } else if (widget.tugas.waktuSelesai != null) {
      waktu = formatWaktu(widget.tugas.waktuSelesai!);
    } else {
      waktu = '-';
    }

    return GestureDetector(
      onTap: () {
        getTugasById(widget.tugas.id);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: blackColor.withValues(alpha: 0.15),
              offset: const Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isChecked
                    ? greenColor
                    : primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isChecked ? fullWhite : primaryColor,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        isChecked ? Icons.check : null,
                        color: isChecked
                            ? blackColor.withValues(alpha: 0.5)
                            : null,
                        size: 20,
                      ),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        bool newStatus = !isChecked;
                        Tugas updatedTugas =
                            widget.tugas.copyWith(isCompleted: newStatus);
                        try {
                          Tugas result =
                              await _apiService.updateTugas(updatedTugas);
                          widget.onTugasUpdated(result);
                        } catch (e) {
                          print('Error updating task: $e');
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                    ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tugas.judul,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock4,
                            size: 14,
                            color: blackColor.withValues(alpha: 0.5),
                          ),
                          const Gap(5),
                          Text(
                            waktu,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: blackColor.withValues(alpha: 0.5),
                              decoration:
                                  isChecked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const Gap(15),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.tugas.kategori.namaKategori,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: blackColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
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
