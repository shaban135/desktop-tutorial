import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/ptw_list_controller.dart';

class PtwListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PtwListController());
  }
}
