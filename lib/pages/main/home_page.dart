// home_page.dart (fixed version)
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/kategori.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/pages/main/kalender_page.dart';
import 'package:tugasku/services/crud_service.dart';
import 'package:tugasku/widgets/common/bottom_tab_bar.dart';
import 'package:tugasku/widgets/common/custom_app_bar.dart';
import 'package:tugasku/widgets/common/drawer.dart';
import 'package:tugasku/widgets/common/streak.dart';
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
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  List<Kategori> _kategoriList = [];
  List<Tugas> _tugasList = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // Untuk menyimpan state saat pindah tab

  @override
  void initState() {
    super.initState();
    HomePageState._instance = this;
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali halaman ini muncul kembali
    _loadData();
  }

  @override
  void dispose() {
    if (HomePageState._instance == this) {
      HomePageState._instance = null;
    }
    super.dispose();
  }

  // Public method untuk di-panggil dari luar
  void loadData() {
    _loadData();
  }

  // Private method untuk implementasi internal
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
    } catch (e) {
      // Handle error
      if (!mounted) return;

      setState(() {
        _kategoriList = [];
        _tugasList = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
      );
    }
  }

  // Method untuk update tugas
  void handleTugasUpdated(Tugas updatedTugas) async {
    if (updatedTugas.isCompleted) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      setState(() {
        // Hapus dari list utama
        _tugasList.removeWhere((t) => t.id == updatedTugas.id);
      });

      // Refresh KalenderPage juga
      KalenderPageState.refreshData();
    } else {
      if (!mounted) return;

      setState(() {
        // Update data di list
        int index =
            _tugasList.indexWhere((tugas) => tugas.id == updatedTugas.id);
        if (index != -1) {
          _tugasList[index] = updatedTugas;
        }
      });

      // Refresh KalenderPage juga
      KalenderPageState.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Diperlukan untuk AutomaticKeepAliveClientMixin

    final sisaTugas = _tugasList.where((t) => t.isCompleted == false).toList()
      ..sort((a, b) {
        final aTime = a.waktuMulai ?? DateTime(9999);
        final bTime = b.waktuMulai ?? DateTime(9999);
        return aTime.compareTo(bTime);
      });

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const SideMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Gap(32),
                      // ===== STREAK COUNT =====
                      const Streak(),
                      const Gap(21),
                      // ===== JUDUL KATEGORI TUGAS =====
                      Row(
                        children: [
                          Text(
                            'Kategori Tugas',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      // ===== KATEGORI TUGAS =====
                      _kategoriList.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada kategori',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 200,
                              child: ListView.separated(
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: KategoriTugas(
                                      kategori: _kategoriList[index],
                                      onTugasUpdated: handleTugasUpdated,
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const Gap(8);
                                },
                                itemCount: _kategoriList.length,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                      const Gap(24),
                      // ===== JUDUL SISA TUGAS =====
                      Row(
                        children: [
                          Text(
                            'Sisa Tugas',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return BottomTabBar(selectedIndex: 1);
                                }));
                              },
                              child: Text(
                                "Lihat Semua Tugas",
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: blackColor.withValues(alpha: 0.7)),
                              ))
                        ],
                      ),
                      const Gap(8),
                      // ===== SISA TUGAS =====
                      sisaTugas.isEmpty
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  'Tidak ada tugas tersisa',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                return TugasWidget(
                                  tugas: sisaTugas[index],
                                  onTugasUpdated: (updatedTugas) {
                                    setState(() {
                                      // Update tugas dalam list utama
                                      int mainIndex = _tugasList.indexWhere(
                                          (t) => t.id == updatedTugas.id);
                                      if (mainIndex != -1) {
                                        _tugasList[mainIndex] = updatedTugas;
                                      }
                                    });

                                    // Refresh KalenderPage juga
                                    KalenderPageState.refreshData();
                                  },
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Gap(12);
                              },
                              itemCount: sisaTugas.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                            ),
                      const Gap(50),
                    ],
                  ),
                ),
              ),
            )),
    );
  }
}
