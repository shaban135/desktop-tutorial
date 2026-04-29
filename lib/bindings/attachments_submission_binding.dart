import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/ls_ptw_execution_controller.dart';

class AttachmentsSubmissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LsPtwExecutionController>(
      () => LsPtwExecutionController(),
    );
  }
}
