import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/widgets/common/drawer.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/widgets/tugas/tugas_widget.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime selectedDate = DateTime.now();
  final DatePickerController _controller = DatePickerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpToSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tugasHariIni = tugas.where((t) {
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
      appBar: AppBar(
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 25),
            child: IconButton(
              icon: Icon(LucideIcons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Halo, Kevin!',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(16),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    'assets/profile.jpg'
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: SideMenu(),
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
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // ===== DATE PICKER =====
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: DatePicker(
                DateTime.now().subtract(const Duration(days: 30)),
                initialSelectedDate: DateTime.now(),
                locale: 'id',
                height: 90,
                width: 55,
                controller: _controller,
                selectionColor: primaryColor,
                selectedTextColor: fullWhite,
                dateTextStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                monthTextStyle: GoogleFonts.inter(fontSize: 12, color: blackColor.withValues(alpha: 0.5)),
                dayTextStyle: GoogleFonts.inter(fontSize: 12, color: blackColor.withValues(alpha: 0.5)),
                onDateChange: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ),
            Gap(16),
            // ===== LIST TUGAS =====
            Expanded(
              child: tugasHariIni.isEmpty ? Center(
                child: Text(
                  'Hari ini belum ada tugas nih, yuk catat!',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ) 
              : ListView.separated(
                itemCount: tugasHariIni.length,
                separatorBuilder: (context, index) => Gap(12),
                itemBuilder: (context, index) {
                  final t = tugasHariIni[index];
                  return TugasWidget(tugas: t);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}