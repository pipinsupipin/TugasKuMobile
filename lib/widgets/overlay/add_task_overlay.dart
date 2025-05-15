// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:tugasku/pages/main/home_page.dart';
import 'package:tugasku/pages/main/kalender_page.dart';
import 'package:tugasku/services/crud_service.dart';
import '../form/task_form.dart';
import 'package:tugasku/utils/flushbar_helper.dart';

class AddTaskOverlay extends StatelessWidget {
  final int? kategoriId;
  final ApiService _apiService = ApiService();
  final VoidCallback? onTaskAdded;

  AddTaskOverlay({
    super.key,
    this.kategoriId,
    this.onTaskAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: TaskForm(
        mode: TaskFormMode.add,
        onSubmit: (dynamic tugasData) async {
          try {
            if (kategoriId != null) {
              tugasData['kategori_id'] = kategoriId;
            }
            
            final response = await _apiService.createTugas(tugasData);
            
            // Tutup dialog
            Navigator.pop(context, true);
            
            if (response['success'] == true) {
              showCustomSnackbar(
                context: context,
                message: "Tugas berhasil ditambahkan",
                isSuccess: true,
              );

              KalenderPageState.refreshData();
              HomePageState.refreshData();

              if (onTaskAdded != null) {
                onTaskAdded!();
              }
            } else {
              showCustomSnackbar(
                context: context,
                message: "Gagal menambahkan tugas: ${response['message']}",
                isSuccess: false,
              );
            }
          } catch (e) {
            // Tutup dialog jika error
            Navigator.pop(context, false);
            showCustomSnackbar(
              context: context,
              message: "Gagal menambahkan tugas: $e",
              isSuccess: false,
            );
          }
        },
      ),
    );
  }
}