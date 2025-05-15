import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
// import 'package:tugasku/widgets/common/button_widget.dart';
import 'package:tugasku/services/crud_service.dart';
import '../../models/tugas.dart';
import '../../models/kategori.dart';
import 'package:tugasku/utils/flushbar_helper.dart';

enum TaskFormMode { add, edit }

class TaskForm extends StatefulWidget {
  final TaskFormMode mode;
  final Tugas? initialTugas;
  final void Function(Map<String, dynamic>) onSubmit;

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
  List<Kategori> _kategoris = [];
  Kategori? _selectedKategori;
  String? _errorText;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.mode == TaskFormMode.edit && widget.initialTugas != null) {
      _titleController.text = widget.initialTugas!.judul;
      _noteController.text = widget.initialTugas!.deskripsi ?? '';
      _startDateTime = widget.initialTugas!.waktuMulai;
      _endDateTime = widget.initialTugas!.waktuSelesai;
      // Kategori akan diset setelah kategori dimuat
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final authService = ApiService();
      final token = await authService.getToken();

      if (token == null) {
        if (mounted) {
          showCustomSnackbar(
            context: context,
            message: "❌ Token tidak ditemukan, silakan login kembali",
            isSuccess: false,
          );
        }
        return;
      }

      // Ambil kategori dari API - ini sudah berupa List<Kategori>
      final List<Kategori> kategoriList = await authService.getKategoriTugas();

      if (mounted) {
        setState(() {
          _kategoris = kategoriList;
          // Set kategori default
          if (_kategoris.isNotEmpty) {
            if (widget.mode == TaskFormMode.edit &&
                widget.initialTugas != null) {
              // Cari kategori yang sesuai dengan initialTugas
              _selectedKategori = _kategoris.firstWhere(
                  (k) => k.id == widget.initialTugas!.kategoriId,
                  orElse: () => _kategoris.first);
            } else {
              _selectedKategori = _kategoris.first;
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showCustomSnackbar(
          context: context,
          message: "❌ Gagal memuat kategori: $e",
          isSuccess: false,
        );
      }
    }
  }

  void _pickDateTime(bool isStart) async {
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
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: primaryColor,
              colorScheme: ColorScheme.light(primary: primaryColor),
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
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

  void _handleSubmit() {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    // Validasi terlebih dahulu
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _errorText = "Judul tugas harus diisi";
        _isSubmitting = false;
      });
      return;
    }

    if (_startDateTime == null && _endDateTime == null) {
      setState(() {
        _errorText = "Pilih waktu mulai atau selesai";
        _isSubmitting = false;
      });
      return;
    }

    if (_startDateTime != null &&
        _endDateTime != null &&
        _endDateTime!.isBefore(_startDateTime!)) {
      setState(() {
        _errorText = "Waktu selesai harus setelah waktu mulai";
        _isSubmitting = false;
      });
      return;
    }

    if (_selectedKategori == null) {
      setState(() {
        _errorText = "Kategori belum dipilih";
        _isSubmitting = false;
      });
      return;
    }

    // Buat Map data sesuai format API
    final tugasData = {
      "kategori_id": _selectedKategori!.id,
      "judul": _titleController.text,
      "deskripsi": _noteController.text,
      "waktu_mulai": _startDateTime?.toIso8601String(),
      "waktu_selesai": _endDateTime?.toIso8601String(),
      "is_completed": widget.initialTugas?.isCompleted ?? false,
      "completed_at": widget.initialTugas?.completedAt?.toIso8601String()
    };

    if (widget.mode == TaskFormMode.edit && widget.initialTugas?.id != null) {
      tugasData["id"] = widget.initialTugas!.id;
    }

    // Panggil callback dengan tugas yang sudah dibuat
    widget.onSubmit(tugasData);

    // Kita biarkan overlay yang menutup dialog
    // Tetapi kita reset status submitting untuk berjaga-jaga
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 36),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Judul"),
                  _buildTextField(_titleController, "Masukkan judul tugas..."),
                  _buildLabel("Waktu"),
                  Row(
                    children: [
                      _buildDateTimePicker(
                          "Mulai", _startDateTime, () => _pickDateTime(true)),
                      const SizedBox(width: 16),
                      _buildDateTimePicker(
                          "Selesai", _endDateTime, () => _pickDateTime(false)),
                    ],
                  ),
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorText!,
                        style:
                            GoogleFonts.inter(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  _buildLabel("Kategori"),
                  _kategoris.isEmpty
                      ? Text("Tidak ada kategori tersedia",
                          style: GoogleFonts.inter(
                              color: Colors.red, fontSize: 14))
                      : Wrap(
                          spacing: 8,
                          children: _kategoris
                              .map((kategori) => _buildCategoryChip(kategori))
                              .toList(),
                        ),
                  _buildLabel("Catatan"),
                  _buildTextField(_noteController, "Tambahkan catatan...",
                      maxLines: 4),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: primaryColor.withOpacity(0.5),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.mode == TaskFormMode.add
                                  ? 'Tambahkan Tugas'
                                  : 'Simpan Perubahan',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 3,
              offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: blackColor.withAlpha(120)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
      String label, DateTime? dateTime, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: fullWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 3,
                  offset: const Offset(0, 3)),
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
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: blackColor.withAlpha(120)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(LucideIcons.chevronDown, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Kategori kategori) {
    bool isSelected = _selectedKategori?.id == kategori.id;
    return ChoiceChip(
      label: Text(
        kategori.namaKategori,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      selected: isSelected,
      onSelected: (selected) =>
          setState(() => _selectedKategori = selected ? kategori : null),
      selectedColor: primaryColor,
      backgroundColor: fullWhite,
      labelStyle: GoogleFonts.inter(
          color: isSelected ? fullWhite : blackColor.withAlpha(120)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isSelected ? primaryColor : backgroundColor, width: 0),
      ),
      showCheckmark: false,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
