import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/ptw_review_sdo_controller.dart';

class PtwReviewSdoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PtwReviewSdoController());
  }
}
