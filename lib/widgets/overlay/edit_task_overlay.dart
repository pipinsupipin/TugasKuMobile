// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/services/crud_service.dart';
import '../form/task_form.dart';
import 'package:tugasku/utils/flushbar_helper.dart';

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
            showCustomSnackbar(
              context: context,
              message: "Sedang memperbarui tugas...",
              isSuccess: true,
            );

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

            // Kirim ke API (karena updateTugas mungkin hanya menggunakan toJson)
            final response = await _apiService.updateTugas(updatedTugas);

            // Tutup dialog dengan future (untuk menghindari erro Navigator)
            Future.microtask(() {
              Navigator.of(context).pop(true);

              // Tampilkan pesan sukses setelah pop selesai
              if (response != null) {
                showCustomSnackbar(
                  context: context,
                  message: "Tugas berhasil diperbarui",
                  isSuccess: true,
                );
                if (onTaskUpdated != null) {
                  onTaskUpdated!();
                }
              } else {
                showCustomSnackbar(
                  context: context,
                  message: "Gagal memperbarui tugas",
                  isSuccess: false,
                );
              }
            });
          } catch (e) {
            // Tampilkan error
            showCustomSnackbar(
              context: context,
              message: "Gagal memperbarui tugas: $e",
              isSuccess: false,
            );

            // Tutup dialog dengan future (untuk menghindari error Navigator)
            Future.microtask(() {
              Navigator.of(context).pop(false);
            });
          }
        },
      ),
    );
  }
}
