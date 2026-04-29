import 'package:flutter/material.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class CompletionConfirmationScreen extends StatefulWidget {
  const CompletionConfirmationScreen({super.key});

  @override
  State<CompletionConfirmationScreen> createState() =>
      _CompletionConfirmationScreenState();
}

class _CompletionConfirmationScreenState
    extends State<CompletionConfirmationScreen> {
  // Data for the checklist
  final Map<String, bool> _checklistItems = {
    'Site has been made tidy and tools removed': true,
    'All workers signed out of work': true,
    'All supplies energized': true,
    'Safety measures have been followed prior to completion': false,
    'Equipment has been left in a safe state': false,
    'Safety devices installed prior to job discontinued or removed only after testing or on-energization of equipment':
        false,
    'Permit is handed back to Line Superintendent': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        title: 'Completion Confirmation',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _checklistItems.length,
                  itemBuilder: (context, index) {
                    String key = _checklistItems.keys.elementAt(index);
                    return _buildChecklistItem(key, _checklistItems[key]!);
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildLsNameSection(),
              const SizedBox(height: 14),
              SafeArea(child: GradientButton(text: 'Submit', onPressed: () {})),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 16),
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
        ],
      ),
    );
  }

  Widget _buildLsNameSection() {
    return const Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LS Name', style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 4),
            Text('Humayun Zafar',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ],
        )
      ],
    );
  }
}
