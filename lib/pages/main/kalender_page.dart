// kalender_page.dart (final version)
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
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

// Membuat static instance dari state untuk akses global
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

class _KalenderPageState extends State<KalenderPage> with AutomaticKeepAliveClientMixin {
  DateTime selectedDate = DateTime.now();
  final DatePickerController _controller = DatePickerController();
  final ApiService _apiService = ApiService();
  List<Tugas> tugasList = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // Untuk menyimpan state saat pindah tab

  @override
  void initState() {
    super.initState();
    
    // Set instance static untuk akses global
    KalenderPageState.instance = this;

    // Pastikan date picker menampilkan tanggal yang dipilih
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpToSelection();
    });

    // Fetch data tugas dari API
    _fetchTugas();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali halaman ini muncul kembali
    _fetchTugas();
  }

  @override
  void dispose() {
    // Clear instance saat widget di-dispose
    if (KalenderPageState.instance == this) {
      KalenderPageState.instance = null;
    }
    super.dispose();
  }

  // Fungsi untuk mengambil data tugas
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
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data tugas: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Callback ketika tugas diperbarui
  void _updateTugas(Tugas updatedTugas) {
    setState(() {
      final index = tugasList.indexWhere((t) => t.id == updatedTugas.id);
      if (index != -1) {
        tugasList[index] = updatedTugas;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Diperlukan untuk AutomaticKeepAliveClientMixin
    
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

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const SideMenu(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            // ===== BULAN, TAHUN =====
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  DateFormat("MMMM, yyyy", 'id').format(selectedDate),
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // ===== DATE PICKER =====
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: DatePicker(
                DateTime.now().subtract(const Duration(days: 30)),
                initialSelectedDate: DateTime.now(),
                locale: 'id',
                height: 90,
                width: 55,
                controller: _controller,
                selectionColor: primaryColor,
                selectedTextColor: fullWhite,
                dateTextStyle: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w500),
                monthTextStyle: GoogleFonts.inter(
                    fontSize: 12, color: blackColor.withValues(alpha: 0.5)),
                dayTextStyle: GoogleFonts.inter(
                    fontSize: 12, color: blackColor.withValues(alpha: 0.5)),
                onDateChange: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
                daysCount: 60, // Show two months of dates
              ),
            ),
            const Gap(16),
            // ===== HEADER FOR TASKS =====
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Tugas pada ${DateFormat("EEEE, d MMMM", 'id').format(selectedDate)}',
                    style: GoogleFonts.inter(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Text(
                  '${tugasHariIni.length} tugas',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: blackColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const Gap(12),
            // ===== LIST TUGAS =====
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchTugas,
                      child: tugasHariIni.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: tugasHariIni.length,
                              separatorBuilder: (context, index) =>
                                  const Gap(12),
                              itemBuilder: (context, index) {
                                final t = tugasHariIni[index];
                                return TugasWidget(
                                  tugas: t,
                                  onTugasUpdated: _updateTugas,
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan ketika tidak ada tugas
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.pencil,
                  size: 48,
                  color: blackColor.withValues(alpha: 0.3),
                ),
                const Gap(12),
                Text(
                  'Hari ini belum ada tugas nih, yuk catat!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: blackColor.withValues(alpha: 0.7),
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