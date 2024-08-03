import 'package:get/get.dart';
import '../bindings/auth_bindings.dart';
import '../bindings/crab_purchase_bindings.dart';
import '../bindings/crab_type_bindings.dart';
import '../bindings/daily_summary_bindings.dart';
import '../bindings/trader_bindings.dart';
import '../bindings/user_binding.dart';
import '../pages/CrabPurchaseManagementPage/crab_purchase_management_page.dart';
import '../pages/crabTraderManagementPage/crab_trader_management_page.dart';
import '../pages/crabTypeManagementPage/crab_type_management_page.dart';
import '../pages/dailyReportManagementPage/daily_summary_management_page.dart';
import '../pages/homePage/home_page.dart';
import '../pages/loginPage/login_page.dart';
import '../pages/managmentUserPage/managment_user_page.dart';
import '../pages/managmentUserPage/user_management_options_page.dart';
import '../pages/rootPage/root_page.dart';
import '../pages/settingPage/setting_page.dart';

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
      name: '/management-user',
      page: () => const ManagmentUserPage(),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingPage(),
    ),
    GetPage(
      name: '/user-management-options',
      page: () => UserManagementOptionsPage(),
      bindings: const [],
    ),
    GetPage(
      name: '/crab-type-management',
      page: () => const CrabTypeManagementPage(),
      binding: CrabTypeBinding(),
    ),
    GetPage(
      name: '/trader-management',
      page: () => const TraderManagementPage(),
      binding: TraderBinding(),
    ),
    GetPage(
      name: '/crab-purchase-management',
      page: () => const CrabPurchaseManagementPage(),
      binding: CrabPurchaseBinding(),
    ),
    GetPage(
      name: '/daily-summary-management',
      page: () => DailySummaryManagementPage(),
      binding: DailySummaryBinding(),
    ),
  ];
}
