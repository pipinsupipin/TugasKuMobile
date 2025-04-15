import 'package:flutter/material.dart';
import '../form/task_form.dart';
import 'package:tugasku/models/tugas.dart';

class EditTaskOverlay extends StatelessWidget {
  final Tugas tugas;

  const EditTaskOverlay({super.key, required this.tugas});

  @override
  Widget build(BuildContext context) {
    return TaskForm(
      mode: TaskFormMode.edit,
      initialTugas: tugas,
      onSubmit: (tugasUpdate) {
        // Update tugas di database
        Navigator.pop(context);
      },
    );
  }
}