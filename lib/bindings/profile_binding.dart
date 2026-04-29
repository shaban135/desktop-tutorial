import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController(), permanent: true);
  }
}
