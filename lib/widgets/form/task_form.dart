// task_form.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/widgets/common/button_widget.dart';
import '../../models/tugas.dart';

enum TaskFormMode { add, edit }

class TaskForm extends StatefulWidget {
  final TaskFormMode mode;
  final Tugas? initialTugas;
  final void Function(Tugas) onSubmit;

  const TaskForm({
    super.key,
    required this.mode,
    this.initialTugas,
    required this.onSubmit,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  List<String> categories = ["Tugas", "Proyek", "Rapat", "Quiz / Ujian", "Les Rutin"];
  String? _selectedCategory = "Tugas";
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.mode == TaskFormMode.edit && widget.initialTugas != null) {
      _titleController.text = widget.initialTugas!.namaTugas;
      _noteController.text = widget.initialTugas!.catatan ?? '';
      _startDateTime = widget.initialTugas!.waktuMulai;
      _endDateTime = widget.initialTugas!.waktuSelesai;
      _selectedCategory = widget.initialTugas!.kategoriTugas;
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(primary: primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!);
      },
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: primaryColor,
              colorScheme: ColorScheme.light(primary: primaryColor),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          final selectedDateTime = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute,
          );
          if (isStart) {
            _startDateTime = selectedDateTime;
          } else {
            _endDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _validateAndSubmit() {
    if (_startDateTime == null && _endDateTime == null) {
      setState(() {
        _errorText = "Pilih waktu mulai atau selesai";
      });
      return;
    }
    if (_startDateTime != null && _endDateTime != null && _endDateTime!.isBefore(_startDateTime!)) {
      setState(() {
        _errorText = "Waktu selesai harus setelah waktu mulai";
      });
      return;
    }
    setState(() => _errorText = null);

    final tugasBaru = Tugas(
      namaTugas: _titleController.text,
      waktuMulai: _startDateTime,
      waktuSelesai: _endDateTime,
      kategoriTugas: _selectedCategory ?? "Tugas",
      catatan: _noteController.text,
      isCompleted: widget.initialTugas?.isCompleted ?? false,
    );

    widget.onSubmit(tugasBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Judul"),
            _buildTextField(_titleController, "Masukkan judul tugas..."),
            _buildLabel("Waktu"),
            Row(
              children: [
                _buildDateTimePicker("Mulai", _startDateTime, () => _pickDateTime(true)),
                SizedBox(width: 16),
                _buildDateTimePicker("Selesai", _endDateTime, () => _pickDateTime(false)),
              ],
            ),
            if (_errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(_errorText!, style: GoogleFonts.inter(color: Colors.red, fontSize: 14)),
              ),
            _buildLabel("Kategori"),
            Wrap(
              spacing: 8,
              children: categories.map((c) => _buildCategoryChip(c)).toList(),
            ),
            _buildLabel("Catatan"),
            _buildTextField(_noteController, "Tambahkan catatan...", maxLines: 4),
            SizedBox(height: 24),
            ButtonWidget(
              text: widget.mode == TaskFormMode.add ? 'Tambahkan Tugas' : 'Simpan Perubahan',
              onTap: _validateAndSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 3, offset: Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: blackColor.withAlpha(120)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(String label, DateTime? dateTime, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 45,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: fullWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 3, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dateTime != null
                    ? "${dateTime.day}/${dateTime.month} ${TimeOfDay.fromDateTime(dateTime).format(context)}"
                    : label,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: blackColor.withAlpha(120)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(LucideIcons.chevronDown, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(category, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedCategory = selected ? category : null),
      selectedColor: primaryColor,
      backgroundColor: fullWhite,
      labelStyle: GoogleFonts.inter(color: isSelected ? fullWhite : blackColor.withAlpha(120)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? primaryColor : backgroundColor, width: 0),
      ),
      showCheckmark: false,
    );
  }
}
