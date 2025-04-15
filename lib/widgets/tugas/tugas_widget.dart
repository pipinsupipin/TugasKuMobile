import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/widgets/overlay/detail_task_overlay.dart';

class TugasWidget extends StatefulWidget {
  final Tugas tugas;

  const TugasWidget({
    required this.tugas,
  });

  @override
  State<TugasWidget> createState() => _TugasWidgetState();
}

class _TugasWidgetState extends State<TugasWidget> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.tugas.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    String formatWaktu(int hour, int minute) {
      String jam = hour.toString().padLeft(2, '0');
      String menit = minute.toString().padLeft(2, '0');
      return '$jam:$menit';
    }

    String waktu = '';
    if (widget.tugas.waktuMulai != null && widget.tugas.waktuSelesai != null) {
      waktu =
          '${formatWaktu(widget.tugas.waktuMulai!.hour, widget.tugas.waktuMulai!.minute)} - ${formatWaktu(widget.tugas.waktuSelesai!.hour, widget.tugas.waktuSelesai!.minute)}';
    } else if (widget.tugas.waktuMulai != null) {
      waktu = formatWaktu(widget.tugas.waktuMulai!.hour, widget.tugas.waktuMulai!.minute);
    } else if (widget.tugas.waktuSelesai != null) {
      waktu = formatWaktu(widget.tugas.waktuSelesai!.hour, widget.tugas.waktuSelesai!.minute);
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: const EdgeInsets.only(top: 60),
            child: TaskDetailOverlay(tugas: widget.tugas),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: blackColor.withValues(alpha: 0.15),
              offset: Offset(2, 2),
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
                color: isChecked ? greenColor : primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  isChecked ? Icons.check : null,
                  color: isChecked ? blackColor.withValues(alpha: 0.5) : null,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isChecked = !isChecked;
                    // Update status ke database (MENYUSUL)
                  });
                },
              ),
            ),
            Gap(12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tugas.namaTugas,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.clock4,
                        size: 14,
                        color: blackColor.withValues(alpha: 0.5),
                      ),
                      Gap(5),
                      Text(
                        waktu,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: blackColor.withValues(alpha: 0.5),
                          decoration: isChecked ? TextDecoration.lineThrough : null,
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