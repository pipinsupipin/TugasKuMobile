import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/kategori.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/services/crud_service.dart';
import 'package:tugasku/widgets/tugas/tugas_widget.dart';
import 'package:tugasku/widgets/tugas/progress_bar_widget.dart';
import 'package:tugasku/utils/flushbar_helper.dart';

class DetailKategoriOverlay extends StatefulWidget {
  final Kategori kategori;
  final List<Tugas> tugasList;
  final VoidCallback onClose;
  final ValueChanged<Tugas> onTugasUpdated;
  final VoidCallback? onKategoriUpdated;

  const DetailKategoriOverlay({
    super.key,
    required this.kategori,
    required this.tugasList,
    required this.onClose,
    required this.onTugasUpdated,
    this.onKategoriUpdated,
  });

  @override
  State<DetailKategoriOverlay> createState() => _DetailKategoriOverlayState();
}

class _DetailKategoriOverlayState extends State<DetailKategoriOverlay>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late String _currentKategoriName;
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentKategoriName = widget.kategori.namaKategori;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Calculate the progress
  double get _progressDecimal {
    if (widget.tugasList.isEmpty) return 0.0;
    int completed = widget.tugasList.where((t) => t.isCompleted).length;
    return completed / widget.tugasList.length;
  }

  // Get the deadline of the nearest task
  String get _nearestDeadlineText {
    if (widget.tugasList.isEmpty) return 'Tidak ada tugas';
    
    final uncompletedTasks = widget.tugasList.where((t) => !t.isCompleted).toList();
    if (uncompletedTasks.isEmpty) return 'Semua tugas selesai';
    
    DateTime? nearestStart;
    for (var task in uncompletedTasks) {
      if (task.waktuMulai != null) {
        if (nearestStart == null || task.waktuMulai!.isBefore(nearestStart)) {
          nearestStart = task.waktuMulai;
        }
      }
    }
    
    if (nearestStart != null) {
      final now = DateTime.now();
      final difference = nearestStart.difference(now).inDays;
      
      if (difference == 0) {
        return 'Hari ini';
      } else if (difference == 1) {
        return 'Besok';
      } else if (difference > 0) {
        return '$difference hari lagi';
      } else {
        return 'Terlambat ${-difference} hari';
      }
    }
    
    return 'Tidak ada tenggat';
  }

  // Icons for categories
  IconData get _categoryIcon {
    switch (_currentKategoriName.toLowerCase()) {
      case 'tugas':
        return LucideIcons.clipboard;
      case 'proyek':
        return LucideIcons.briefcase;
      case 'rapat':
        return LucideIcons.users;
      case 'quiz / ujian':
        return LucideIcons.graduationCap;
      case 'les rutin':
        return LucideIcons.book;
      case 'pekerjaan':
        return LucideIcons.laptop;
      case 'personal':
        return LucideIcons.user;
      default:
        return LucideIcons.folder;
    }
  }

  Color get _categoryColor {
    return primaryColor; // Always use primaryColor for consistency
  }

  Future<void> _editKategori() async {
    HapticFeedback.lightImpact();
    
    final nameController = TextEditingController(text: _currentKategoriName);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.edit,
                color: primaryColor,
                size: 20,
              ),
            ),
            const Gap(12),
            Text(
              'Edit Kategori',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: GoogleFonts.inter(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                labelStyle: GoogleFonts.inter(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, nameController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result != null && result != _currentKategoriName) {
      await _updateKategori(result);
    }
  }

  Future<void> _updateKategori(String newName) async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.updateKategori(widget.kategori.id, newName);
      
      if (response['success'] == true) {
        setState(() {
          _currentKategoriName = newName;
          _isLoading = false;
        });
        
        showCustomSnackbar(
          context: context,
          message: "Kategori berhasil diperbarui",
          isSuccess: true,
        );
        
        widget.onKategoriUpdated?.call();
      } else {
        setState(() => _isLoading = false);
        showCustomSnackbar(
          context: context,
          message: "${response['message']}",
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showCustomSnackbar(
        context: context,
        message: "Gagal memperbarui kategori: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> _deleteKategori() async {
    HapticFeedback.mediumImpact();
    
    // Check if category has tasks
    if (widget.tugasList.isNotEmpty) {
      showCustomSnackbar(
        context: context,
        message: "Tidak dapat menghapus kategori yang masih memiliki tugas",
        isSuccess: false,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.trash2,
                color: Colors.red,
                size: 20,
              ),
            ),
            const Gap(12),
            Text(
              'Hapus Kategori',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus kategori "$_currentKategoriName"?',
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: Colors.red.shade600, size: 16),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performDelete();
    }
  }

  Future<void> _performDelete() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.deleteKategori(widget.kategori.id);
      
      if (response['success'] == true) {
        // Close overlay FIRST before showing snackbar and refreshing
        widget.onClose();
        
        // Use Future.microtask to avoid navigation conflicts
        Future.microtask(() {
          showCustomSnackbar(
            context: context,
            message: "Kategori berhasil dihapus",
            isSuccess: true,
          );
          
          widget.onKategoriUpdated?.call();
        });
      } else {
        setState(() => _isLoading = false);
        showCustomSnackbar(
          context: context,
          message: "${response['message']}",
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showCustomSnackbar(
        context: context,
        message: "Gagal menghapus kategori: $e",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int completedTasks = widget.tugasList.where((t) => t.isCompleted).length;
    int totalTasks = widget.tugasList.length;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ===== ENHANCED HEADER =====
                      _buildHeader(),
                      
                      const Gap(24),
                      
                      // ===== STATS SECTION =====
                      _buildStatsSection(completedTasks, totalTasks),
                      
                      const Gap(24),
                      
                      // ===== TASK LIST HEADER =====
                      _buildTaskListHeader(totalTasks),
                      
                      const Gap(16),
                      
                      // ===== TASK LIST =====
                      Expanded(
                        child: _buildTaskList(),
                      ),
                    ],
                  ),
                ),
                
                // Loading overlay
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Close button and actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40), // Balance the close button
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _editKategori,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.edit,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: widget.tugasList.isEmpty ? _deleteKategori : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.tugasList.isEmpty 
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.trash2,
                        color: widget.tugasList.isEmpty 
                            ? Colors.red 
                            : Colors.grey.shade400,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onClose();
                    },
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
            ),
          ],
        ),
        
        const Gap(20),
        
        // Category info
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.8),
                    primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _categoryIcon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const Gap(20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    _currentKategoriName,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const Gap(6),
                      Text(
                        _nearestDeadlineText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(int completedTasks, int totalTasks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$completedTasks/$totalTasks Selesai',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const Gap(12),
          ProgressBar(progress: _progressDecimal),
          const Gap(12),
          Row(
            children: [
              _buildStatItem(
                icon: LucideIcons.checkCircle,
                label: 'Selesai',
                value: '$completedTasks',
                color: Colors.green,
              ),
              const Gap(16),
              _buildStatItem(
                icon: LucideIcons.clock,
                label: 'Pending',
                value: '${totalTasks - completedTasks}',
                color: Colors.orange,
              ),
              const Gap(16),
              _buildStatItem(
                icon: LucideIcons.list,
                label: 'Total',
                value: '$totalTasks',
                color: _categoryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const Gap(4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListHeader(int totalTasks) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Tugas',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        if (totalTasks > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$totalTasks tugas',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTaskList() {
    if (widget.tugasList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.inbox,
                size: 32,
                color: Colors.grey.shade400,
              ),
            ),
            const Gap(16),
            Text(
              'Belum ada tugas',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const Gap(4),
            Text(
              'Kategori ini belum memiliki tugas',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        return TugasWidget(
          tugas: widget.tugasList[index],
          onTugasUpdated: widget.onTugasUpdated,
        );
      },
      separatorBuilder: (context, index) => const Gap(12),
      itemCount: widget.tugasList.length,
    );
  }
}
