import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../OverviewUserPage/overview_user_page.dart';
import '../managmentUserPage/managment_user_page.dart';
import '../settingPage/setting_page.dart';
import '../../apps/apps_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/overview_controller.dart';
import '../../widgets/network_status_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final AuthController authController = Get.find<AuthController>();

  static final List<Widget> _widgetOptions = <Widget>[
    const ManagmentUserPage(),
    DepotOverviewPage(),
    const SettingPage(),
  ];

  static final List<String> _pageTitles = [
    'Quản lý vựa cua',
    'Tổng quan',
    'Cài đặt',
  ];

  static final List<IconData> _pageIcons = [
    Icons.inventory,
    Icons.dashboard,
    Icons.settings,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        shadowColor: AppColors.primaryColor.withOpacity(0.3),
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // Refresh button for overview page
          if (_selectedIndex == 1)
            //   IconButton(
            //     icon: const Icon(Icons.refresh, color: Colors.white),
            //     onPressed: () {
            //       // Refresh overview data
            //       final overviewController = Get.find<DepotOverviewController>();
            //       overviewController.fetchDepotOverview();
            //     },
            //   ),
            // // User info
            Obx(() {
              if (authController.user.value != null) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          authController.user.value!.username.isNotEmpty
                              ? authController.user.value!.username[0]
                                  .toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            authController.user.value!.fullname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            authController.user.value!.role,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
        ],
      ),
      body: Column(
        children: [
          const NetworkStatusWidget(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor.withOpacity(0.08),
                    AppColors.backgroundColor,
                    AppColors.primaryColor.withOpacity(0.02),
                  ],
                ),
              ),
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: List.generate(_pageIcons.length, (index) {
            return BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == index
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _pageIcons[index],
                  color: _selectedIndex == index
                      ? AppColors.primaryColor
                      : AppColors.textColor.withOpacity(0.6),
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _pageIcons[index],
                  color: AppColors.primaryColor,
                ),
              ),
              label: _pageTitles[index],
            );
          }),
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textColor.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
