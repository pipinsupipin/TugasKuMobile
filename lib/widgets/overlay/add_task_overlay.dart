import 'package:flutter/material.dart';
import '../form/task_form.dart';
// import 'package:tugasku/models/tugas.dart';

class AddTaskOverlay extends StatelessWidget {
  const AddTaskOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return TaskForm(
      mode: TaskFormMode.add,
      onSubmit: (tugasBaru) {
        // Simpan tugasBaru ke database
        Navigator.pop(context);
      },
    );
  }
}