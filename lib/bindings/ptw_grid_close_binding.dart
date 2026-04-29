import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/ptw_grid_close_controller.dart';

class PtwGridCloseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PtwGridCloseController>(() => PtwGridCloseController());
  }
}
