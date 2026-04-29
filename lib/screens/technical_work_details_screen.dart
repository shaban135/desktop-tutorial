import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/upload_button.dart';

class TechnicalWorkDetailsScreen extends StatefulWidget {
  const TechnicalWorkDetailsScreen({super.key});

  @override
  State<TechnicalWorkDetailsScreen> createState() =>
      _TechnicalWorkDetailsScreenState();
}

class _TechnicalWorkDetailsScreenState
    extends State<TechnicalWorkDetailsScreen> {
  // State for image attachments
  XFile? _earthingPointPhoto;
  XFile? _earthingRodPhoto;

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
          Get.toNamed(AppRoutes.safetyChecklistLineLoad);
        },
      ),
      body: MainLayout(
        title: 'Technical Work Details',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
          children: [
            _buildFieldWithTitle(
                'Where will the line be earthed?',
                'لائن کو کہاں ارتھ کیا جائے گا؟',
                const CustomTextFormField(
                    labelText: 'Select', suffixIcon: Icons.arrow_drop_down)),
            const SizedBox(height: 16),
            _buildFieldWithTitle(
                'How many earth rods and where?',
                'کتنے ارتھ راڈ اور کہاں؟',
                const CustomTextFormField(
                    labelText: '00', suffixIcon: Icons.unfold_more)),
            const SizedBox(height: 16),
            _buildFieldWithTitle(
                'Location',
                'جگہ شامل کریں',
                const CustomTextFormField(
                  labelText: '',
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Chip(
                      label: Text('Multan, Pakistan'),
                      onDeleted: null,
                      deleteIcon: Icon(Icons.close, size: 18),
                    ),
                  ),
                ),
                trailing: const Text("+ Add Location",
                    style: TextStyle(color: Colors.blue))),
            const SizedBox(height: 16),
            _buildFieldWithTitle(
              'Estimated Shutdown Duration',
              'متوقع بندش کا دورانیہ',
              const Row(
                children: [
                  Expanded(
                      child: CustomTextFormField(
                          labelText: '00', suffixIcon: Icons.unfold_more)),
                  SizedBox(width: 16),
                  Expanded(
                      child: CustomTextFormField(
                          labelText: '00', suffixIcon: Icons.unfold_more)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFieldWithTitle('LS Mobile Number', 'ایل ایس کا موبائل نمبر',
                const CustomTextFormField(labelText: '0300 123456789')),
            const SizedBox(height: 24),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWithTitle(String title, String urduTitle, Widget field,
      {Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87)),
                    const Text('  |  '),
                    Text(urduTitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 8),
        field,
      ],
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
          'Earthing point photo',
          'ارتھنگ پوائنٹ کی تصویر',
          _earthingPointPhoto,
          () => _pickImage((img) => _earthingPointPhoto = img),
          () => setState(() => _earthingPointPhoto = null),
        ),
        const SizedBox(height: 16),
        _buildUploadItem(
          'Earthing rod placement photo',
          'ارتھنگ راڈ پلیسمنٹ کی تصویر',
          _earthingRodPhoto,
          () => _pickImage((img) => _earthingRodPhoto = img),
          () => setState(() => _earthingRodPhoto = null),
        ),
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
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 14)),
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
