import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/services/crud_service.dart';
import 'package:tugasku/widgets/common/button_widget.dart';
import 'package:tugasku/widgets/overlay/edit_task_overlay.dart';

class TaskDetailOverlay extends StatefulWidget {
  final int tugasId;

  const TaskDetailOverlay({required this.tugasId, Key? key}) : super(key: key);

  @override
  _TaskDetailOverlayState createState() => _TaskDetailOverlayState();
}

class _TaskDetailOverlayState extends State<TaskDetailOverlay> {
  final ApiService _apiService = ApiService();
  Tugas? _tugas;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetailTugas(widget.tugasId);
  }

  Future<void> _fetchDetailTugas(int id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detailTugas = await _apiService.getTugasById(id);
      setState(() {
        _tugas = detailTugas;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Tidak ditentukan';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _tugas?.judul ?? 'Judul tidak ditemukan',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Gap(24),
                          // KATEGORI CHIP
                          Chip(
                            label: Text(
                              _tugas?.kategori.namaKategori ?? 'Tanpa Kategori',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: blackColor.withValues(alpha: 0.5),
                              ),
                            ),
                            backgroundColor:
                                primaryColor.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: primaryColor,
                                  width: 0,
                                )),
                          ),
                        ],
                      ),
                      Gap(16),
                      // DESKRIPSI / KETERANGAN
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _tugas?.deskripsi ?? '-',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: blackColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      Gap(24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Waktu Mulai', _tugas?.waktuMulai),
                          _buildDetailRow(
                              'Waktu Selesai', _tugas?.waktuSelesai),
                        ],
                      ),
                      Gap(32),
                      ButtonWidget(
                        text: "Edit Tugas",
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.only(
                                  top: 60), // Perbaiki typo onlay -> only
                              child: EditTaskOverlay(
                                tugas: _tugas!,
                                onTaskUpdated: () {
                                  // Kembali ke halaman sebelumnya dengan hasil true
                                  Navigator.pop(context, true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Tugas berhasil diubah')),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String title, DateTime? time) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 12,
                color: blackColor.withValues(alpha: 0.5),
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  time != null ? _formatDateTime(time) : '-',
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
    );
  }
}
