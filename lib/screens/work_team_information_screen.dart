import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/upload_button.dart';

class WorkTeamInformationScreen extends StatefulWidget {
  const WorkTeamInformationScreen({super.key});
  @override
  State<WorkTeamInformationScreen> createState() =>
      _WorkTeamInformationScreenState();
}

class _WorkTeamInformationScreenState extends State<WorkTeamInformationScreen> {
  // Dummy controllers
  final _lineSuperintendentController =
      TextEditingController(text: 'Humayun Zafar');
  final _safetySupervisorController =
      TextEditingController(text: 'Humayun Zafar');
  final _detailsController = TextEditingController();
  final _contractorNameController = TextEditingController();

  // State for image attachments
  XFile? _sitePhoto;
  XFile? _equipmentPhoto;

  Future<void> _pickImage(Function(XFile?) setImage) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        setImage(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomNavigationButtons(
        onBackPressed: () => Get.back(),
        onNextPressed: () {
          Get.toNamed(AppRoutes.technicalWorkDetails);
        },
      ),
      body: MainLayout(
        title: 'Work & Team Information',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
          children: [
            CustomTextFormField(
                controller: _lineSuperintendentController,
                labelText: 'Line Superintendent | لائن سپرنٹنڈنٹ',
                suffixIcon: Icons.lock_outline),
            const SizedBox(height: 16),
            CustomTextFormField(
                controller: _safetySupervisorController,
                labelText: 'Safety Supervisor | سیفٹی سپروائزر',
                suffixIcon: Icons.lock_outline),
            const SizedBox(height: 16),
            CustomTextFormField(
                controller: _detailsController,
                labelText: 'Details of Worksite | کام کی جگہ کی تفصیل',
                maxLines: 3),
            const SizedBox(height: 24),
            _buildAddWorkerButton(),
            const SizedBox(height: 24),
            CustomTextFormField(
                controller: _contractorNameController,
                labelText: 'Contractor Name (optional) | کونٹریکٹر کا نام (اختیاری)'),
            const SizedBox(height: 14),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWorkerButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Add Worker (کارکن شامل کریں)',
          style: TextStyle(color: Colors.white, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFED1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Attachments (Mandatory)',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('  |  '),
            Text('منسلکات (لازمی)', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        _buildUploadItem(
          'Site photo before shutdown',
          'بندش سے پہلے سائٹ کی تصویر',
          _sitePhoto,
          () => _pickImage((img) => _sitePhoto = img),
          () => setState(() => _sitePhoto = null),
        ),
        const SizedBox(height: 16),
        _buildUploadItem(
          'Equipment / Area photo',
          'سامان / علاقہ کی تصویر',
          _equipmentPhoto,
          () => _pickImage((img) => _equipmentPhoto = img),
          () => setState(() => _equipmentPhoto = null),
        ),
        const SizedBox(height: 30),

      ],
    );
  }

  Widget _buildUploadItem(String title, String subtitle, XFile? imageFile,
      VoidCallback onUpload, VoidCallback onRemove) {
    return Row(
      children: [
        if (imageFile == null)
          UploadButton(onPressed: onUpload)
        else
          _buildImagePreview(imageFile, onRemove),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black87)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildImagePreview(XFile imageFile, VoidCallback onRemove) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.file(
            File(imageFile.path),
            width: 100,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: InkWell(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

