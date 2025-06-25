// kalender_page.dart
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/widgets/common/custom_app_bar.dart';
import 'package:tugasku/widgets/common/drawer.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/services/crud_service.dart';
import 'package:tugasku/widgets/tugas/tugas_widget.dart';

class KalenderPageState {
  static _KalenderPageState? instance;

  static void refreshData() {
    if (instance != null) {
      instance!._fetchTugas();
    }
  }
}

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  final DatePickerController _controller = DatePickerController();
  final ApiService _apiService = ApiService();
  List<Tugas> tugasList = [];
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    KalenderPageState.instance = this;

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpToSelection();
    });

    _fetchTugas();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchTugas();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    if (KalenderPageState.instance == this) {
      KalenderPageState.instance = null;
    }
    super.dispose();
  }

  Future<void> _fetchTugas() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedTugas = await _apiService.getTugas();

      if (!mounted) return;

      setState(() {
        tugasList = fetchedTugas;
        _isLoading = false;
      });

      // Start animations
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
              const Gap(8),
              Expanded(
                child: Text('Gagal memuat data tugas: ${e.toString()}'),
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

  void _updateTugas(Tugas updatedTugas) {
    setState(() {
      final index = tugasList.indexWhere((t) => t.id == updatedTugas.id);
      if (index != -1) {
        tugasList[index] = updatedTugas;
      }
    });
  }

  void _onDateChanged(DateTime date) {
    HapticFeedback.selectionClick();
    setState(() {
      selectedDate = date;
    });
  }

  void _goToToday() {
    HapticFeedback.lightImpact();
    final today = DateTime.now();
    setState(() {
      selectedDate = today;
    });
    _controller.animateToDate(today);
  }

  // Helper untuk mendapatkan statistik tugas
  Map<String, int> _getTaskStats(List<Tugas> tasks) {
    int completed = tasks.where((t) => t.isCompleted).length;
    int pending = tasks.where((t) => !t.isCompleted).length;
    int overdue = tasks.where((t) {
      if (t.isCompleted) return false;
      final deadline = t.waktuSelesai;
      return deadline != null && deadline.isBefore(DateTime.now());
    }).length;

    return {
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'total': tasks.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Filter tugas berdasarkan tanggal yang dipilih
    final List<Tugas> tugasHariIni = _isLoading
        ? []
        : tugasList.where((t) {
            final date = t.waktuMulai ?? t.waktuSelesai;
            return date != null &&
                date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;
          }).toList()
      ..sort((a, b) {
        final waktuA = a.waktuMulai ?? a.waktuSelesai ?? DateTime(9999);
        final waktuB = b.waktuMulai ?? b.waktuSelesai ?? DateTime(9999);
        return waktuA.compareTo(waktuB);
      });

    final stats = _getTaskStats(tugasHariIni);
    final isToday = selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(),
      drawer: const SideMenu(currentIndex: 1),
      body: Column(
        children: [
          // ===== HEADER SECTION =====
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 16),
              child: Column(
                children: [
                  // Month/Year header dengan today button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat("MMMM yyyy", 'id').format(selectedDate),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (!isToday)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _goToToday,
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
                                  Icon(
                                    LucideIcons.calendar,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                  const Gap(4),
                                  Text(
                                    'Hari Ini',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Gap(16),

                  // Date picker
                  DatePicker(
                    DateTime.now().subtract(const Duration(days: 30)),
                    initialSelectedDate: selectedDate,
                    locale: 'id',
                    height: 90,
                    width: 60,
                    controller: _controller,
                    selectionColor: primaryColor,
                    selectedTextColor: Colors.white,
                    deactivatedColor: Colors.grey.shade300,
                    dateTextStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    monthTextStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                    dayTextStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                    onDateChange: _onDateChanged,
                    daysCount: 60,
                  ),
                ],
              ),
            ),
          ),

          // ===== CONTENT SECTION =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // Header dengan statistik
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          offset: const Offset(0, 2),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isToday
                                        ? 'Tugas Hari Ini'
                                        : 'Tugas pada ${DateFormat("EEEE, d MMMM", 'id').format(selectedDate)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    '${stats['total']} tugas total',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (stats['total']! > 0) ...[
                          const Gap(16),
                          Row(
                            children: [
                              _buildStatChip(
                                icon: LucideIcons.checkCircle,
                                label: 'Selesai',
                                count: stats['completed']!,
                                color: Colors.green,
                              ),
                              const Gap(8),
                              _buildStatChip(
                                icon: LucideIcons.clock,
                                label: 'Pending',
                                count: stats['pending']!,
                                color: Colors.orange,
                              ),
                              if (stats['overdue']! > 0) ...[
                                const Gap(8),
                                _buildStatChip(
                                  icon: LucideIcons.alertTriangle,
                                  label: 'Terlambat',
                                  count: stats['overdue']!,
                                  color: Colors.red,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Gap(20),

                  // Task list
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: RefreshIndicator(
                                onRefresh: _fetchTugas,
                                color: primaryColor,
                                backgroundColor: Colors.white,
                                child: tugasHariIni.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.separated(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemCount: tugasHariIni.length,
                                        separatorBuilder: (context, index) =>
                                            const Gap(12),
                                        itemBuilder: (context, index) {
                                          final tugas = tugasHariIni[index];
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            child: TugasWidget(
                                              tugas: tugas,
                                              onTugasUpdated: _updateTugas,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const Gap(4),
          Text(
            '$count $label',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isToday = selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isToday ? LucideIcons.coffee : LucideIcons.calendar,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const Gap(20),
              Text(
                isToday ? 'Hari Ini Bebas Tugas! ☕' : 'Tidak Ada Tugas',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                isToday
                    ? 'Waktunya santai atau mungkin ada tugas baru yang perlu ditambahkan?'
                    : 'Belum ada tugas yang dijadwalkan untuk tanggal ini',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
