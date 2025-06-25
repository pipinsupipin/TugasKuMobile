// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/services/crud_service.dart';
import '../form/task_form.dart';

class EditTaskOverlay extends StatelessWidget {
  final Tugas tugas;
  final ApiService _apiService = ApiService();
  final VoidCallback? onTaskUpdated;

  EditTaskOverlay({
    super.key,
    required this.tugas,
    this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: TaskForm(
        mode: TaskFormMode.edit,
        initialTugas: tugas,
        onSubmit: (dynamic updatedData) async {
          try {
            // Buat tugas baru berdasarkan data yang ada dengan copyWith
            Tugas updatedTugas;
            
            if (updatedData is Map<String, dynamic>) {
              // Jika data dari form adalah Map
              updatedTugas = tugas.copyWith(
                judul: updatedData['judul'],
                deskripsi: updatedData['deskripsi'],
                kategoriId: updatedData['kategori_id'],
                waktuMulai: updatedData['waktu_mulai'] != null 
                    ? DateTime.parse(updatedData['waktu_mulai']) 
                    : null,
                waktuSelesai: updatedData['waktu_selesai'] != null 
                    ? DateTime.parse(updatedData['waktu_selesai']) 
                    : null,
                isCompleted: updatedData['is_completed'] ?? tugas.isCompleted,
                completedAt: updatedData['completed_at'] != null 
                    ? DateTime.parse(updatedData['completed_at']) 
                    : tugas.completedAt,
              );
            } else if (updatedData is Tugas) {
              // Jika data sudah berupa Tugas
              updatedTugas = updatedData;
            } else {
              throw Exception("Format data tidak valid");
            }
            
            // Kirim ke API
            final response = await _apiService.updateTugas(updatedTugas);
            
            // Jika berhasil, tutup overlay dan panggil callback
            if (response != null && context.mounted) {
              Navigator.of(context).pop(true); // Return true sebagai tanda sukses
            } else if (context.mounted) {
              Navigator.of(context).pop(false); // Return false sebagai tanda gagal
            }
            
          } catch (e) {
            debugPrint('Error updating task: $e');
            if (context.mounted) {
              Navigator.of(context).pop(false); // Return false sebagai tanda gagal
            }
          }
        },
      ),
    );
  }
}