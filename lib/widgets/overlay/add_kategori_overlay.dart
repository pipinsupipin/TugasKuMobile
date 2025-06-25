import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/services/crud_service.dart';
import 'package:tugasku/utils/flushbar_helper.dart';

class AddKategoriOverlay extends StatefulWidget {
  final VoidCallback? onKategoriAdded;

  const AddKategoriOverlay({
    super.key,
    this.onKategoriAdded,
  });

  @override
  State<AddKategoriOverlay> createState() => _AddKategoriOverlayState();
}

class _AddKategoriOverlayState extends State<AddKategoriOverlay>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaKategoriController = TextEditingController();
  final _focusNode = FocusNode();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Auto focus pada text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _namaKategoriController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveKategori() async {
    HapticFeedback.lightImpact();
    
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _apiService.createKategori(_namaKategoriController.text.trim());

        if (!mounted) return;

        if (response['success'] == true) {
          // Tutup dialog dengan animation
          _animationController.reverse().then((_) {
            if (mounted) {
              Navigator.of(context).pop();
              
              // Tampilkan snackbar sukses
              showCustomSnackbar(
                context: context,
                message: "✅ ${response['message'] ?? 'Kategori berhasil dibuat'}",
                isSuccess: true,
              );
              
              // Panggil callback
              widget.onKategoriAdded?.call();
            }
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          
          showCustomSnackbar(
            context: context,
            message: "❌ ${response['message'] ?? 'Gagal menambahkan kategori'}",
            isSuccess: false,
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        
        showCustomSnackbar(
          context: context,
          message: "❌ Terjadi kesalahan: $e",
          isSuccess: false,
        );
      }
    }
  }

  void _closeDialog() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon and title
                    _buildHeader(),
                    
                    const SizedBox(height: 24),
                    
                    // Form field
                    _buildFormField(),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            LucideIcons.folderPlus,
            color: primaryColor,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Text(
            "Tambah Kategori",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _isLoading ? null : _closeDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.x,
                color: Colors.grey.shade600,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField() {
    return TextFormField(
      controller: _namaKategoriController,
      focusNode: _focusNode,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: "Nama Kategori",
        labelStyle: GoogleFonts.inter(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        hintText: "Contoh: Pekerjaan, Kuliah, Personal",
        hintStyle: GoogleFonts.inter(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          LucideIcons.tag,
          color: Colors.grey.shade500,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama kategori tidak boleh kosong';
        }
        if (value.trim().length < 2) {
          return 'Nama kategori minimal 2 karakter';
        }
        if (value.trim().length > 30) {
          return 'Nama kategori maksimal 30 karakter';
        }
        return null;
      },
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _saveKategori(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : _closeDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Batal",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveKategori,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _isLoading ? 0 : 2,
              disabledBackgroundColor: primaryColor.withOpacity(0.5),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.plus, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Tambah",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}