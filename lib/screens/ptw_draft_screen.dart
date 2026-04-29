import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mepco_esafety_app/controllers/ptw_review_sdo_controller.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class PtwDraftScreen extends StatelessWidget {
  const PtwDraftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PtwReviewSdoController controller = Get.find<PtwReviewSdoController>();

    return Scaffold(
      body: MainLayout(
        title: 'PTW Draft',
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
            children: [
              _buildReviewCard('Basic Information', _buildBasicInfoContent(controller)),
              _buildReviewCard('Work & Team Information', _buildWorkTeamInfoContent(controller)),
              _buildReviewCard('Technical Work Details', _buildTechnicalWorkDetailsContent(controller)),
              _buildReviewCard('Checklists', _buildChecklistSection(controller)),
              _buildReviewCard('Attachments', _buildAttachmentsContent(controller)),
            ],
          );
        }),
      ),
    );
  }

  // ---------------------- HELPERS ----------------------
  String _str(dynamic v, {String fallback = '—'}) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _fmtDT(dynamic v) {
    try {
      if (v == null) return '—';
      final raw = v.toString().replaceFirst(' ', 'T');
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return _str(v);
    }
  }

  Widget _chip(String text, {Color? bg, Color? fg, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg ?? Colors.black87),
            const SizedBox(width: 6),
          ],
          Text(text, style: TextStyle(color: fg ?? Colors.black87, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------------------- REVIEW CARD WRAPPER ----------------------
  Widget _buildReviewCard(String title, Widget content) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            title,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          children: [content],
        ),
      ),
    );
  }

  // ---------------------- BASIC INFO ----------------------
  Widget _buildBasicInfoContent(PtwReviewSdoController controller) {
    final ptw = controller.ptwData;
    final type = _str(ptw['type']);
    final status = _str(ptw['current_status']);
    final miscType = _str(ptw['misc_type']);
    final estMin = ptw['estimated_duration_min'];
    final estDuration = estMin == null ? '—' : '$estMin min';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              _chip(type,
                  bg: Colors.blue.shade50,
                  fg: Colors.blue.shade700,
                  icon: Icons.category_outlined),
              const SizedBox(width: 8),
              _chip(status,
                  bg: Colors.green.shade50,
                  fg: Colors.green.shade700,
                  icon: Icons.flag_outlined),
              if (miscType != '—') ...[
                const SizedBox(width: 8),
                _chip('MISC: $miscType',
                    bg: Colors.orange.shade50,
                    fg: Colors.orange.shade700,
                    icon: Icons.info_outline),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('PTW Number', _str(ptw['ptw_code'])),
          _buildDetailRow('Work Order No', _str(ptw['work_order_no'])),
          _buildDetailRow('Scheduled Start', _fmtDT(ptw['scheduled_start_at'])),
          _buildDetailRow('Estimated Duration', estDuration),
        ],
      ),
    );
  }

  // ---------------------- TEAM INFO ----------------------
  Widget _buildWorkTeamInfoContent(PtwReviewSdoController controller) {
    final ptw = controller.ptwData;
    final team = (ptw['team_members'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('LS', _str(ptw['ls_name'] ?? ptw['ls_id'])),
          _buildDetailRow('Sub-Division', _str(ptw['sub_division'] ?? ptw['sub_division_name'])),
          const SizedBox(height: 8),
          const Text('Team Members', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          if (team.isEmpty)
            const Text('— No team members —', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: team.map((m) {
                final name = _str(m['name']);
                final avatar = _str(m['avatar_url'],
                    fallback: 'http://mepco.myflexihr.com/storage/avatars/default-neutral.png');
                return SizedBox(
                  width: 150,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          avatar,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(width: 36, height: 36, color: Colors.grey.shade200, child: const Icon(Icons.person)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------------------- TECHNICAL DETAILS ----------------------
  Widget _buildTechnicalWorkDetailsContent(PtwReviewSdoController controller) {
    final ptw = controller.ptwData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          _buildDetailRow('Feeder Name/Code',
              _str(ptw['feeder_name'] ?? ptw['feeder_code'] ?? ptw['feeder_id'])),
          _buildDetailRow('Transformer Code',
              _str(ptw['transformer_name'])),
          _buildDetailRow('Feeder Incharge', _str(ptw['feeder_incharge_name'])),
          _buildDetailRow('Place of Work', _str(ptw['place_of_work'])),
          _buildDetailRow('Location', _str(ptw['place_of_work'])),
          _buildDetailRow('Scope of Work', _str(ptw['scope_of_work'])),
          _buildDetailRow('Safety Arrangements', _str(ptw['safety_arrangements'])),
          _buildDetailRow('Close Feeder', _str(ptw['close_feeder'])),
          _buildDetailRow('Alternate Feeder', _str(ptw['alternate_feeder'])),
          _buildDetailRow('Switch-off Time', _fmtDT(ptw['switch_off_time'])),
          _buildDetailRow('Restore Time', _fmtDT(ptw['restore_time'])),
        ],
      ),
    );
  }

  // ---------------------- CHECKLISTS ----------------------
  Widget _buildChecklistSection(PtwReviewSdoController controller) {
    final raw = controller.checklists;
    if (raw.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No checklist data available'),
      );
    }

    final map = raw.map((k, v) => MapEntry(k.toString(), v));

    Widget yesNoChip(String v) {
      final isYes = v.toString().toUpperCase() == 'YES';
      return _chip(
        isYes ? 'YES' : 'NO',
        bg: (isYes ? Colors.green : Colors.red).withOpacity(0.12),
        fg: isYes ? Colors.green.shade700 : Colors.red.shade700,
        icon: isYes ? Icons.check_circle : Icons.cancel,
      );
    }

    Widget bilingualRow(String en, String ur, String v) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                en,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ur,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            yesNoChip(v),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: map.entries.map((entry) {
          final type = entry.key;
          final items = (entry.value as List?) ?? const [];

          return Card(
            color: Colors.grey[50],
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                type.replaceAll('_', ' '),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              children: items.map<Widget>((it) {
                final en = _str(it['label_en']);
                final ur = _str(it['label_ur']);
                final val = _str(it['value'], fallback: 'NO');
                return bilingualRow(en, ur, val);
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------- ATTACHMENTS ----------------------
  Widget _buildAttachmentsContent(PtwReviewSdoController controller) {
    final ptw = controller.ptwData;
    final evidences = ptw['evidences'] as List? ?? [];
    if (evidences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No attachments available')),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: evidences.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 4 / 3,
        ),
        itemBuilder: (context, index) {
          final e = evidences[index];
          final filePath = _str(e['file_path'], fallback: '');
          final baseTypeName = _str(e['type']).replaceAll('_', ' ');
          final id = _str(e['id']);

          if (filePath.isEmpty) return const SizedBox.shrink();
          final imageUrl = 'http://mepco.myflexihr.com/storage/$filePath';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$baseTypeName (ID: $id)',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------- DETAIL ROW ----------------------
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
