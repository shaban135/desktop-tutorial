import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/ptw_completed_controller.dart';

class PtwCompletedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PtwCompletedController>(() => PtwCompletedController());
  }
}
