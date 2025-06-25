// home_page.dart (enhanced professional version)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/kategori.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/pages/main/kalender_page.dart';
import 'package:tugasku/services/crud_service.dart';
import 'package:tugasku/widgets/common/bottom_tab_bar.dart';
import 'package:tugasku/widgets/common/custom_app_bar.dart';
import 'package:tugasku/widgets/common/drawer.dart';
import 'package:tugasku/widgets/common/streak.dart';
import 'package:tugasku/widgets/tugas/add_kategori.dart';
import 'package:tugasku/widgets/tugas/kategori_tugas.dart';
import 'package:tugasku/widgets/tugas/tugas_widget.dart';

// Static helper class untuk refresh data
class HomePageState {
  static _HomePageState? _instance;

  static void refreshData() {
    if (_instance != null) {
      _instance!._loadData();
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Kategori> _kategoriList = [];
  List<Tugas> _tugasList = [];
  bool _isLoading = true;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    HomePageState._instance = this;
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    if (HomePageState._instance == this) {
      HomePageState._instance = null;
    }
    super.dispose();
  }

  void loadData() {
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final kategoriData = await _apiService.getKategoriTugas();
      final tugasData = await _apiService.getTugas();

      if (!mounted) return;

      setState(() {
        _kategoriList = kategoriData;
        _tugasList = tugasData;
        _isLoading = false;
      });
      
      // Start animations when data loads
      _fadeController.forward();
      _slideController.forward();
      
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _kategoriList = [];
        _tugasList = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
              const Gap(8),
              Expanded(
                child: Text('Gagal memuat data: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void handleTugasUpdated(Tugas updatedTugas) async {
    if (updatedTugas.isCompleted) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      setState(() {
        _tugasList.removeWhere((t) => t.id == updatedTugas.id);
      });

      KalenderPageState.refreshData();
    } else {
      if (!mounted) return;

      setState(() {
        int index = _tugasList.indexWhere((tugas) => tugas.id == updatedTugas.id);
        if (index != -1) {
          _tugasList[index] = updatedTugas;
        }
      });

      KalenderPageState.refreshData();
    }
  }

  // Helper untuk mendapatkan quick stats
  Map<String, int> _getQuickStats() {
    final today = DateTime.now();
    final todayTasks = _tugasList.where((t) {
      final date = t.waktuMulai ?? t.waktuSelesai;
      return date != null &&
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();
    
    final pendingTasks = _tugasList.where((t) => !t.isCompleted).length;
    final completedToday = todayTasks.where((t) => t.isCompleted).length;
    
    return {
      'today': todayTasks.length,
      'pending': pendingTasks,
      'completed_today': completedToday,
      'categories': _kategoriList.length,
    };
  }

  Widget _buildQuickStatsCard() {
    final stats = _getQuickStats();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Tugas Hari Ini',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: LucideIcons.calendar,
                  label: 'Hari Ini',
                  value: '${stats['today']}',
                  color: primaryColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: LucideIcons.clock,
                  label: 'Pending',
                  value: '${stats['pending']}',
                  color: Colors.orange,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: LucideIcons.checkCircle,
                  label: 'Selesai',
                  value: '${stats['completed_today']}',
                  color: Colors.green,
                ),
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
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const Gap(6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            if (subtitle != null) ...[
              const Gap(2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildEmptyKategoriState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.folderPlus,
              size: 32,
              color: primaryColor,
            ),
          ),
          const Gap(16),
          Text(
            'Belum Ada Kategori',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const Gap(8),
          Text(
            'Tambahkan kategori untuk mengorganisir tugas dengan lebih baik',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final sisaTugas = _tugasList.where((t) => t.isCompleted == false).toList()
      ..sort((a, b) {
        final aTime = a.waktuMulai ?? DateTime(9999);
        final bTime = b.waktuMulai ?? DateTime(9999);
        return aTime.compareTo(bTime);
      });

    return Scaffold(
      backgroundColor: fullWhite,
      appBar: const CustomAppBar(),
      drawer: const SideMenu(currentIndex: 0),
      body: _isLoading
          ? Container(
              color: backgroundColor,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3),
                    Gap(16),
                    Text(
                      'Memuat data...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: primaryColor,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              backgroundColor,
                            ],
                            stops: const [0.0, 0.3],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(24),
                              
                              // ===== STREAK SECTION =====
                              Center(
                                child: const Streak(),
                              ),
                              
                              const Gap(24),
                              
                              // ===== QUICK STATS =====
                              _buildQuickStatsCard(),
                              
                              const Gap(32),
                              
                              // ===== KATEGORI TUGAS SECTION =====
                              _buildSectionHeader(
                                title: 'Kategori Tugas',
                                subtitle: _kategoriList.isEmpty 
                                    ? 'Belum ada kategori tersedia'
                                    : '${_kategoriList.length} kategori tersedia',
                              ),
                              
                              const Gap(16),
                              
                              _kategoriList.isEmpty
                                  ? _buildEmptyKategoriState()
                                  : Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListView.separated(
                                        itemBuilder: (BuildContext context, int index) {
                                          if (index == _kategoriList.length) {
                                            return Container(
                                              margin: const EdgeInsets.symmetric(vertical: 10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.06),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: AddKategoriButton(
                                                onKategoriAdded: () {
                                                  HapticFeedback.lightImpact();
                                                  loadData();
                                                },
                                              ),
                                            );
                                          }

                                          return Container(
                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.06),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: KategoriTugas(
                                              kategori: _kategoriList[index],
                                              onTugasUpdated: handleTugasUpdated,
                                            ),
                                          );
                                        },
                                        separatorBuilder: (BuildContext context, int index) {
                                          return const Gap(16);
                                        },
                                        itemCount: _kategoriList.length + 1,
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                    ),
                              
                              const Gap(32),
                              
                              // ===== SISA TUGAS SECTION =====
                              _buildSectionHeader(
                                title: 'Sisa Tugas',
                                subtitle: sisaTugas.isEmpty 
                                    ? 'Semua tugas telah selesai!' 
                                    : '${sisaTugas.length} tugas tersisa',
                                action: sisaTugas.isNotEmpty ? Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return BottomTabBar(selectedIndex: 1);
                                      }));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: primaryColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Lihat Semua",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const Gap(4),
                                          Icon(
                                            LucideIcons.arrowRight,
                                            size: 12,
                                            color: primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ) : null,
                              ),
                              
                              const Gap(16),
                              
                              sisaTugas.isEmpty
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(40),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.05),
                                            offset: const Offset(0, 4),
                                            blurRadius: 16,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              LucideIcons.partyPopper,
                                              size: 32,
                                              color: Colors.green.shade600,
                                            ),
                                          ),
                                          const Gap(16),
                                          Text(
                                            'Semua Tugas Selesai! 🎉',
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                          const Gap(8),
                                          Text(
                                            'Hebat! Anda telah menyelesaikan semua tugas.\nWaktunya istirahat atau buat tugas baru!',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.green.shade600,
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                    itemBuilder: (BuildContext context, int index) {
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        child: TugasWidget(
                                          tugas: sisaTugas[index],
                                          onTugasUpdated: (updatedTugas) {
                                            setState(() {
                                              int mainIndex = _tugasList.indexWhere(
                                                  (t) => t.id == updatedTugas.id);
                                              if (mainIndex != -1) {
                                                _tugasList[mainIndex] = updatedTugas;
                                              }
                                            });
                                            KalenderPageState.refreshData();
                                          },
                                        ),
                                      );
                                    },
                                    separatorBuilder: (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Divider(
                                          color: Colors.grey.shade200,
                                          thickness: 1,
                                          height: 1,
                                        ),
                                      );
                                    },
                                    itemCount: sisaTugas.length,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                  ),
                              
                              const Gap(80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}