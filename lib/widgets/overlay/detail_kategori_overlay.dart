// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:tugasku/constants.dart';
// import 'package:tugasku/models/kategori.dart';
// import 'package:tugasku/models/tugas.dart';
// import 'package:tugasku/widgets/overlay/add_task_overlay.dart';
// import 'package:tugasku/widgets/tugas/tugas_widget.dart';
// import 'package:tugasku/widgets/tugas/progress_bar_widget.dart';

// class DetailKategoriOverlay extends StatelessWidget {
//   final Kategori kategori;
//   final List<Tugas> tugasList;
//   final VoidCallback onClose;
//   final void Function(Tugas) onTugasUpdated;

//   const DetailKategoriOverlay({
//     super.key,
//     required this.kategori,
//     required this.tugasList,
//     required this.onClose,
//     required this.onTugasUpdated,
//   });
  

//   // Calculate the progress
//   double get _progressDecimal {
//     if (tugasList.isEmpty) return 0.0;
//     int completed = tugasList.where((t) => t.isCompleted).length;
//     return completed / tugasList.length;
//   }

//   // Get the deadline of the nearest task
//   String get _nearestDeadlineText {
//     if (tugasList.isEmpty) return 'Tidak ada tenggat';
    
//     DateTime? nearest;
//     for (var task in tugasList) {
//       if (task.waktuSelesai != null && !task.isCompleted) {
//         if (nearest == null || task.waktuSelesai!.isBefore(nearest)) {
//           nearest = task.waktuSelesai;
//         }
//       }
//     }
    
//     if (nearest == null) return 'Tidak ada tenggat';
//     return '${nearest.day}/${nearest.month}/${nearest.year}';
//   }

//   // Icons for categories
//   IconData get _categoryIcon {
//     switch (kategori.namaKategori.toLowerCase()) {
//       case 'tugas':
//         return Icons.assignment;
//       case 'proyek':
//         return Icons.work;
//       case 'rapat':
//         return Icons.people;
//       case 'quiz / ujian':
//         return Icons.school;
//       case 'les rutin':
//         return Icons.book;
//       default:
//         return Icons.folder;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Count completed tasks
//     int completedTasks = tugasList.where((t) => t.isCompleted).length;
//     int totalTasks = tugasList.length;

//     return Dialog(
//       insetPadding: EdgeInsets.all(24),
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ===== HEADER KATEGORI =====
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: onClose,
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 90,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 75,
//                         height: 75,
//                         decoration: BoxDecoration(
//                           color: primaryColor.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Center(
//                           child: Opacity(
//                             opacity: 0.4,
//                             child: Icon(
//                               _categoryIcon,
//                               size: 40,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Gap(16),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Kategori Tugas',
//                             style: GoogleFonts.inter(
//                               fontSize: 14,
//                               color: blackColor.withOpacity(0.5),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           Text(
//                             kategori.namaKategori,
//                             style: GoogleFonts.inter(
//                               fontSize: 24,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Gap(28),
//                 // ===== BATAS WAKTU TERDEKAT =====
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Batas Waktu Terdekat',
//                       style: GoogleFonts.inter(
//                         fontSize: 14,
//                         color: blackColor.withOpacity(0.5),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Gap(6),
//                     Row(
//                       children: [
//                         Icon(Icons.access_time, size: 16, color: blackColor.withOpacity(0.5)),
//                         const SizedBox(width: 6),
//                         Text(
//                           _nearestDeadlineText,
//                           style: GoogleFonts.inter(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Gap(28),
//                 ProgressBar(progress: _progressDecimal),
//                 Gap(12),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     '$completedTasks/$totalTasks Selesai',
//                     style: GoogleFonts.inter(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Gap(24),
//             // ===== HEADER DAFTAR TUGAS =====
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   'Daftar Tugas',
//                   style: GoogleFonts.inter(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                       builder: (context) => AddTaskOverlay(
//                         kategoriId: kategori.id ?? 0,
//                       ),
//                     );
//                   },
//                   style: TextButton.styleFrom(
//                     backgroundColor: primaryColor.withOpacity(0.4),
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Text(
//                     'Tambah Tugas',
//                     style: GoogleFonts.inter(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: blackColor.withOpacity(0.5),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Gap(16),
//             // ===== DAFTAR TUGAS =====
//             Expanded(
//               child: tugasList.isEmpty
//                   ? Center(
//                       child: Text(
//                         'Tidak ada tugas dalam kategori ini.',
//                         style: GoogleFonts.inter(fontSize: 14),
//                       ),
//                     )
//                   : ListView.separated(
//                       itemBuilder: (context, index) {
//                         return TugasWidget(
//                           tugas: tugasList[index],
//                           onTugasUpdated: onTugasUpdated,
//                         );
//                       },
//                       separatorBuilder: (context, index) => SizedBox(height: 8),
//                       itemCount: tugasList.length,
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }