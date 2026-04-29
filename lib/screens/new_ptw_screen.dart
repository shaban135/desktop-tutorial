import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class NewPtwScreen extends StatefulWidget {
  const NewPtwScreen({super.key});

  @override
  State<NewPtwScreen> createState() => _NewPtwScreenState();
}

class _NewPtwScreenState extends State<NewPtwScreen> {
  // Dummy controllers for the form fields
  final _ptwNumberController = TextEditingController(text: 'PTW-20250930-001');
  final _dateController = TextEditingController(text: 'Sep 30, 2025');
  final _workNumberController = TextEditingController();
  final _feederNameController = TextEditingController();
  final _natureOfWorkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomNavigationButtons(
        onBackPressed: () => Get.back(),
        onNextPressed: () {
          Get.toNamed(AppRoutes.workTeamInformation);
        },
      ),
      body: MainLayout(
        // title: 'New PTW-Basic Information',
        title: 'PTW Information & Details',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
          children: [
            CustomTextFormField(
              controller: _ptwNumberController,
              labelText: 'PTW Number | نئی پی ٹی ڈبلیو - بنیادی معلومات',
              readOnly: true,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _dateController,
              labelText: 'Date | تاریخ',
              suffixIcon: Icons.calendar_today_outlined,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
                controller: _workNumberController,
                labelText: 'Work Number | ورک نمبر'),
            const SizedBox(height: 16),
            CustomTextFormField(
                controller: _feederNameController,
                labelText: 'Feeder Name / Code | فیڈر کا نام/کوڈ',
                suffixIcon: Icons.search,
                readOnly: true),
            const SizedBox(height: 16),
            CustomTextFormField(
                controller: _natureOfWorkController,
                labelText: 'Nature of Work | کام کی نوعیت'),
            const SizedBox(height: 16),
            _buildGeoFencingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeoFencingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Geo-Fencing & Location',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('  |  '),
            Text('جیو فینسنگ اور مقام', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300], // Placeholder color
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'Map Placeholder',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
