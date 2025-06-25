import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
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

class _TaskFormState extends State<TaskForm> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  List<Kategori> _kategoris = [];
  Kategori? _selectedKategori;
  String? _errorText;
  bool _isLoading = true;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadCategories();

    if (widget.mode == TaskFormMode.edit && widget.initialTugas != null) {
      _titleController.text = widget.initialTugas!.judul;
      _noteController.text = widget.initialTugas!.deskripsi ?? '';
      _startDateTime = widget.initialTugas!.waktuMulai;
      _endDateTime = widget.initialTugas!.waktuSelesai;
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final authService = ApiService();
      final token = await authService.getToken();

      if (token == null) {
        if (mounted) {
          _showError("Token tidak ditemukan, silakan login kembali");
        }
        return;
      }

      final List<Kategori> kategoriList = await authService.getKategoriTugas();

      if (mounted) {
        setState(() {
          _kategoris = kategoriList;
          if (_kategoris.isNotEmpty) {
            if (widget.mode == TaskFormMode.edit &&
                widget.initialTugas != null) {
              _selectedKategori = _kategoris.firstWhere(
                  (k) => k.id == widget.initialTugas!.kategoriId,
                  orElse: () => _kategoris.first);
            } else {
              _selectedKategori = _kategoris.first;
            }
          }
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError("Gagal memuat kategori: $e");
      }
    }
  }

  void _showError(String message) {
    showCustomSnackbar(
      context: context,
      message: "❌ $message",
      isSuccess: false,
    );
  }

  void _pickDateTime(bool isStart) async {
    HapticFeedback.lightImpact();
    
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
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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
              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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
            // Clear error when start time is set
            _errorText = null;
          } else {
            // SAFETY CHECK: Only allow end time if start time exists
            if (_startDateTime != null) {
              if (selectedDateTime.isAfter(_startDateTime!)) {
                _endDateTime = selectedDateTime;
                _errorText = null;
              } else {
                _showError("Waktu selesai harus setelah waktu mulai");
              }
            } else {
              _showError("Harap pilih waktu mulai terlebih dahulu");
              // Don't set end time without start time
            }
          }
        });
      }
    }
  }

  bool _validateForm() {
    setState(() => _errorText = null);

    // Check title
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorText = "Judul tugas harus diisi");
      return false;
    }

    // CRITICAL: Must have start time (end time is optional)
    if (_startDateTime == null) {
      setState(() => _errorText = "Waktu mulai harus diisi");
      return false;
    }

    // SAFETY: If both times exist, validate order
    if (_startDateTime != null && _endDateTime != null) {
      if (_endDateTime!.isBefore(_startDateTime!) || _endDateTime!.isAtSameMomentAs(_startDateTime!)) {
        setState(() => _errorText = "Waktu selesai harus setelah waktu mulai");
        return false;
      }
    }

    // Check category
    if (_selectedKategori == null) {
      setState(() => _errorText = "Kategori belum dipilih");
      return false;
    }

    return true;
  }

  void _handleSubmit() {
    HapticFeedback.mediumImpact();
    
    setState(() => _isSubmitting = true);

    // Validate form with safety checks
    if (!_validateForm()) {
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      // SAFE data preparation
      final tugasData = <String, dynamic>{
        "kategori_id": _selectedKategori!.id,
        "judul": _titleController.text.trim(),
        "deskripsi": _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        "waktu_mulai": _startDateTime!.toIso8601String(), // Always required
        "waktu_selesai": _endDateTime?.toIso8601String(), // Optional
        "is_completed": widget.initialTugas?.isCompleted ?? false,
        "completed_at": widget.initialTugas?.completedAt?.toIso8601String(),
      };

      // Add ID for edit mode
      if (widget.mode == TaskFormMode.edit && widget.initialTugas?.id != null) {
        tugasData["id"] = widget.initialTugas!.id;
      }

      // Double check data integrity before submitting
      if (tugasData["kategori_id"] == null || 
          tugasData["judul"] == null || 
          tugasData["judul"].toString().isEmpty ||
          tugasData["waktu_mulai"] == null) {
        throw Exception("Data tidak lengkap");
      }

      // Submit the form
      widget.onSubmit(tugasData);

      // Note: Don't show snackbar here - let the overlay handle it
      // The overlay will close and show the success message

    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorText = "Terjadi kesalahan: $e";
      });
      _showError("Gagal menyimpan tugas: $e");
    }

    // Reset submitting state after delay (if still mounted)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? _buildLoadingState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildTitleField(),
                    const SizedBox(height: 20),
                    _buildTimeSection(),
                    const SizedBox(height: 20),
                    _buildCategorySection(),
                    const SizedBox(height: 20),
                    _buildNoteField(),
                    if (_errorText != null) _buildErrorMessage(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text('Memuat form...'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.mode == TaskFormMode.add ? LucideIcons.plus : LucideIcons.edit,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.mode == TaskFormMode.add ? 'Tambah Tugas Baru' : 'Edit Tugas',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Judul Tugas", isRequired: true),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _titleController,
          hint: "Masukkan judul tugas...",
          icon: LucideIcons.fileText,
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Waktu", isRequired: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateTimePicker(
                "Waktu Mulai",
                _startDateTime,
                () => _pickDateTime(true),
                isRequired: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimePicker(
                "Waktu Selesai",
                _endDateTime,
                () => _pickDateTime(false),
                isRequired: false,
                isEnabled: _startDateTime != null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Kategori", isRequired: true),
        const SizedBox(height: 8),
        _kategoris.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertTriangle, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Tidak ada kategori tersedia",
                      style: GoogleFonts.inter(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kategoris.map((kategori) => _buildCategoryChip(kategori)).toList(),
              ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Catatan"),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _noteController,
          hint: "Tambahkan catatan (opsional)...",
          icon: LucideIcons.messageSquare,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            "*",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
    String label,
    DateTime? dateTime,
    VoidCallback onTap, {
    bool isRequired = false,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? Colors.grey.shade200 : Colors.grey.shade300,
          ),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.calendar,
              color: isEnabled ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 2),
                        Text("*", style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateTime != null
                        ? "${dateTime.day}/${dateTime.month}/${dateTime.year} ${TimeOfDay.fromDateTime(dateTime).format(context)}"
                        : "Pilih ${label.toLowerCase()}",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: dateTime != null 
                          ? Colors.black87 
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronDown,
              color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Kategori kategori) {
    bool isSelected = _selectedKategori?.id == kategori.id;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedKategori = kategori;
            _errorText = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            kategori.namaKategori,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertCircle, color: Colors.red.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorText!,
              style: GoogleFonts.inter(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
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
          elevation: _isSubmitting ? 0 : 2,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.mode == TaskFormMode.add ? LucideIcons.plus : LucideIcons.check,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.mode == TaskFormMode.add ? 'Tambah Tugas' : 'Simpan Perubahan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}