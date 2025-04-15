import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/widgets/common/button_widget.dart';
import 'package:tugasku/widgets/overlay/edit_task_overlay.dart';

class TaskDetailOverlay extends StatelessWidget {
  final Tugas tugas;

  const TaskDetailOverlay({
    super.key,
    required this.tugas,
  });

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return "-";
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    return "${dt.day} ${_getMonthName(dt.month)} ${dt.year}, $jam:$menit";
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    tugas.namaTugas,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Gap(24),
                Chip(
                  label: Text(
                    tugas.kategoriTugas,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: fullWhite,
                    ),
                  ),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: primaryColor,
                      width: 0,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),

            if (tugas.catatan != null && tugas.catatan!.trim().isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tugas.catatan!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const Gap(24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Waktu Mulai",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 12, color: blackColor.withValues(alpha: 0.5)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDateTime(tugas.waktuMulai),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: blackColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Waktu Selesai",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 12, color: blackColor.withValues(alpha: 0.5)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDateTime(tugas.waktuSelesai),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: blackColor.withValues(alpha: 0.6),
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

            const Gap(32),
            ButtonWidget(
              text: "Edit Tugas",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: fullWhite,
                  builder: (_) => EditTaskOverlay(tugas: tugas),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}