import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/hse_field_check_controller.dart';

class HseFieldCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HseFieldCheckController>(() => HseFieldCheckController());
  }
}
