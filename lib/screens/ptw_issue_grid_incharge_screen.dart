import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class PtwIssueGridInchargeScreen extends StatefulWidget {
  const PtwIssueGridInchargeScreen({super.key});

  @override
  State<PtwIssueGridInchargeScreen> createState() =>
      _PtwIssueGridInchargeScreenState();
}

class _PtwIssueGridInchargeScreenState
    extends State<PtwIssueGridInchargeScreen> {
  // Data for the checklist
  final Map<String, bool> _checklistItems = {
    'PTW received and available at site': true,
    'PDC/Control room informed of shutdown': true,
    'All protective relays are blocked/disabled': true,
    'All isolators/sectionalizers are opened and...': true,
    '0 bus earthed (if applicable)': true,
    '2 points earthed (if applicable)': true,
    '4 points earthed (if applicable)': true,
    'Line/feeder interlinking removed/secured': true,
    'Safety banners/barricades applied at contr...': true,
    'Worksite handover completed, LS Informed': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomNavigationButtons(
        onBackPressed: () => Get.back(),
        onNextPressed: () {
          Get.toNamed(AppRoutes.ptwIssuerInstructions);
        },
      ),
      body: MainLayout(
        title: 'PTW Issue - Grid Incharge',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
          children: [
            _buildBilingualText(
                'Feeder Name / Feeder No. (auto)', 'فیڈر کا نام/فیڈر نمبر (خودکار)'),
            const CustomTextFormField(
                labelText: 'FEEDER-01',
                readOnly: true,
                suffixIcon: Icons.lock_outline),
            const SizedBox(height: 16),
            _buildBilingualText('Grid Incharge Name (auto)', 'گرڈ انچارج کا نام (خودکار)'),
            const CustomTextFormField(
                labelText: 'Humayun Zafar',
                readOnly: true,
                suffixIcon: Icons.lock_outline),
            const SizedBox(height: 16),
            _buildBilingualText('Mobile Number (auto)', 'موبائل نمبر (خودکار)'),
            const CustomTextFormField(
                labelText: '+92 300 1234567',
                readOnly: true,
                suffixIcon: Icons.lock_outline),
            const SizedBox(height: 16),
            _buildTimestampSection(),
            const SizedBox(height: 16),
            ..._checklistItems.keys
                .map((key) => _buildChecklistItem(key, _checklistItems[key]!))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildBilingualText(String english, String urdu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            english,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const Text(' | ', style: TextStyle(color: Colors.grey)),
          Text(
            urdu,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Issue Timestamp',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('  |  '),
            Text('اجراء کا ٹائم اسٹیمپ', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('GPS',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildChecklistItem(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) {
              setState(() {
                _checklistItems[title] = newValue!;
              });
            },
            activeColor: Colors.red,
            checkColor: Colors.white,
            side: const BorderSide(color: Colors.grey, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
