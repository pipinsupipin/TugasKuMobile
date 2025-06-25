import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/kategori.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/services/crud_service.dart';
import 'package:tugasku/widgets/overlay/detail_kategori_overlay.dart';
import 'package:tugasku/widgets/tugas/progress_bar_widget.dart';

class KategoriTugas extends StatefulWidget {
  final Kategori kategori;
  final ValueChanged<Tugas> onTugasUpdated;
  
  const KategoriTugas({
    super.key,
    required this.kategori,
    required this.onTugasUpdated,
  });
  
  @override
  State<KategoriTugas> createState() => _KategoriTugasState();
}

class _KategoriTugasState extends State<KategoriTugas> {
  final ApiService _apiService = ApiService();
  List<Tugas> _tugas = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadTugas();
  }
  
  Future<void> _loadTugas() async {
    try {
      final allTugas = await _apiService.getTugas();
      if (mounted) {
        setState(() {
          _tugas = allTugas.where((t) => t.kategoriId == widget.kategori.id).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tugas = [];
          _isLoading = false;
        });
      }
      debugPrint('Error loading tasks: $e');
    }
  }
  
  // Calculate the progress
  double get _progressDecimal {
    if (_tugas.isEmpty) return 0.0;
    int completed = _tugas.where((t) => t.isCompleted).length;
    return completed / _tugas.length;
  }
  
  // Get the deadline of the nearest task
  String get _nearestDeadlineText {
    if (_tugas.isEmpty) return 'Tidak ada tenggat';
    
    // Filter tugas yang belum selesai
    final uncompletedTasks = _tugas.where((t) => !t.isCompleted).toList();
    if (uncompletedTasks.isEmpty) return 'Semua selesai';
    
    // Cari waktu mulai terdekat dari tugas yang belum selesai
    DateTime? nearestStart;
    for (var task in uncompletedTasks) {
      if (task.waktuMulai != null) {
        if (nearestStart == null || task.waktuMulai!.isBefore(nearestStart)) {
          nearestStart = task.waktuMulai;
        }
      }
    }
    
    if (nearestStart != null) {
      return '${nearestStart.day}/${nearestStart.month}/${nearestStart.year}';
    }
    
    return 'Tidak ada tenggat';
  }
  
  // Icons for categories (you can customize this based on your needs)
  IconData get _categoryIcon {
    switch (widget.kategori.namaKategori.toLowerCase()) {
      case 'tugas':
        return Icons.assignment;
      case 'proyek':
        return Icons.work;
      case 'rapat':
        return Icons.people;
      case 'quiz / ujian':
        return Icons.school;
      case 'les rutin':
        return Icons.book;
      default:
        return Icons.folder;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Count completed tasks
    int completedTasks = _tugas.where((t) => t.isCompleted).length;
    int totalTasks = _tugas.length;
    
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) {
            return DetailKategoriOverlay(
              kategori: widget.kategori,
              tugasList: _tugas, // Daftar tugas yang ada
              onClose: () => Navigator.of(context).pop(),
              onTugasUpdated: (updatedTugas) {
                setState(() {
                  // Cari tugas yang sudah diperbarui dan update satu tugas tersebut
                  int index = _tugas.indexWhere((tugas) => tugas.id == updatedTugas.id);
                  if (index != -1) {
                    _tugas[index] = updatedTugas; // Ganti tugas yang diperbarui
                  }
                });
                // Panggil callback parent
                widget.onTugasUpdated(updatedTugas);
              },
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                            color: primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: 0.4,
                              child: Icon(
                                _categoryIcon,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          widget.kategori.namaKategori,
                          style: GoogleFonts.inter(
                            fontSize: 20, 
                            fontWeight: FontWeight.w500
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time, 
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _nearestDeadlineText,
                                style: GoogleFonts.inter(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w500
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ProgressBar(progress: _progressDecimal)
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$completedTasks/$totalTasks Selesai',
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