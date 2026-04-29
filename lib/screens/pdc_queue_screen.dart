import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/black_gradient_button.dart';
import 'package:mepco_esafety_app/widgets/blue_gradient_button.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class PdcQueueScreen extends StatelessWidget {
  const PdcQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        title: 'PDC Queue',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          children: [
            _buildPtwDetailsSection(context),
            const SizedBox(height: 24),
            _buildDecisionSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildRulesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPtwDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PTW Detail - PDC (پی ٹی ڈبلیو تفصیل - پی ڈی سی)',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Details',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _buildDetailItem('1', 'Basic Information'),
        _buildDetailItem('2', 'Work & Team Information'),
        _buildDetailItem('3', 'Work Area & Line Clearance'),
        _buildDetailItem('4', 'Safety Measures'),
      ],
    );
  }

  Widget _buildDetailItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12))),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDecisionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Decision',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        const Row(
          children: [
            Text('Decision Notes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('  |  '),
            Text('فیصلہ نوٹس', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        const CustomTextFormField(labelText: 'Reason / Instructions...', maxLines: 3),
      ],
    );
  }

  Widget _buildActionButtons() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.8, // Adjust aspect ratio for button shape
      children: [
        GradientButton(
            text: 'Issue PTW',
            onPressed: () {
              Get.toNamed(AppRoutes.ptwIssueGridIncharge);
            }),
        BlueGradientButton(text: 'Hold', onPressed: () {}),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Return to XEN',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
        BlackGradientButton(text: 'Cancel', onPressed: () {}),
      ],
    );
  }

  Widget _buildRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rules', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _buildRuleItem('Notes required for reject and request changes.'),
        _buildRuleItem(
            'Approve forwards to PDC; Reject returns to SDO; Request changes goes to LS.'),
        _buildRuleItem(
            'Lorem ipsum dolor sit amet consectetur. Mauris justo enim malesuada neque.'),
      ],
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: CircleAvatar(radius: 3, backgroundColor: Colors.grey),
          ),
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.grey, fontSize: 14))),
        ],
      ),
    );
  }
}
