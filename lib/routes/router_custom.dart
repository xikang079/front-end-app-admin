import 'package:get/get.dart';
import '../bindings/auth_bindings.dart';
import '../bindings/user_binding.dart';
import '../controllers/crab_purchase_controller.dart';
import '../controllers/crab_type_controller.dart';
import '../pages/homePage/home_page.dart';
import '../pages/managmentUserPage/user_management_options_page.dart';
import '../pages/rootPage/root_page.dart';
import '../pages/managmentSummaryDailyPage/managment_summary_daily_page.dart';
import '../pages/managmentUserPage/managment_user_page.dart';
import '../pages/settingPage/setting_page.dart';
import '../pages/loginPage/login_page.dart';
import '../pages/invoiceManagementPage/invoice_management_page.dart';
import '../pages/crabTraderManagementPage/crab_trader_management_page.dart';
import '../pages/dailyReportManagementPage/daily_report_management_page.dart';
import '../pages/crabTypeManagementPage/crab_type_management_page.dart';
import '../controllers/trader_controller.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/',
      page: () => RootPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      bindings: [
        AuthBinding(),
        UserBinding(),
      ],
    ),
    GetPage(
      name: '/login',
      page: () => LoginPage(),
    ),
    GetPage(
      name: '/management-summary-daily',
      page: () => const ManagmentSummaryDailyPage(),
    ),
    GetPage(
      name: '/management-user',
      page: () => const ManagmentUserPage(),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingPage(),
    ),
    GetPage(
      name: '/crab-trader-management',
      page: () => const TraderManagementPage(),
    ),
    GetPage(
      name: '/invoice-management',
      page: () => InvoiceManagementPage(depotId: Get.parameters['depotId']!),
    ),
    GetPage(
      name: '/daily-report-management',
      page: () =>
          DailyReportManagementPage(depotId: Get.parameters['depotId']!),
    ),
    GetPage(
      name: '/crab-type-management',
      page: () => const CrabTypeManagementPage(),
      bindings: [
        BindingsBuilder(() {
          Get.put(CrabTypeController());
        })
      ],
    ),
    GetPage(
      name: '/user-management-options',
      page: () => UserManagementOptionsPage(),
      bindings: [
        BindingsBuilder(() {
          Get.put(TraderController());
          Get.put(CrabPurchaseController());
        })
      ],
    ),
  ];
}
