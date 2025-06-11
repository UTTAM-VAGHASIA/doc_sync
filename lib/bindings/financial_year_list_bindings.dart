import 'package:doc_sync/features/masters/controllers/financial_year_list_controller.dart';
import 'package:get/get.dart';

class FinancialYearListBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FinancialYearListController>()) {
      Get.put(FinancialYearListController());
    }
  }
}
