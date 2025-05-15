import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/kategori.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/services/crud_service.dart';
// import 'package:tugasku/widgets/overlay/detail_kategori_overlay.dart';
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
      setState(() {
        _tugas = allTugas.where((t) => t.kategoriId == widget.kategori.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _tugas = [];
        _isLoading = false;
      });
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
    
    DateTime? nearest;
    for (var task in _tugas) {
      if (task.waktuSelesai != null && !task.isCompleted) {
        if (nearest == null || task.waktuSelesai!.isBefore(nearest)) {
          nearest = task.waktuSelesai;
        }
      }
    }
    
    if (nearest == null) return 'Tidak ada tenggat';
    return '${nearest.day}/${nearest.month}/${nearest.year}';
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
        // showDialog(
        //   context: context,
        //   barrierDismissible: true,
        //   builder: (_) {
        //     return DetailKategoriOverlay(
        //       kategori: widget.kategori,
        //       tugasList: _tugas, // Daftar tugas yang ada
        //       onClose: () => Navigator.of(context).pop(),
        //       onTugasUpdated: (updatedTugas) {
        //         setState(() {
        //           // Cari tugas yang sudah diperbarui dan update satu tugas tersebut
        //           int index = _tugas.indexWhere((tugas) => tugas.id == updatedTugas.id);
        //           if (index != -1) {
        //             _tugas[index] = updatedTugas; // Ganti tugas yang diperbarui
        //           }
        //         });
        //       },
        //     );
        //   },
        // );
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
              color: Colors.black.withOpacity(0.2),
              offset: Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: _isLoading 
            ? Center(child: CircularProgressIndicator())
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
                        ),
                        Text(
                          _nearestDeadlineText,
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
                    child: ProgressBar(progress: _progressDecimal)),
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