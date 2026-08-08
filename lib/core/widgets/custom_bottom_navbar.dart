import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/core/widgets/nav_bar_item.dart';
import 'package:shop/core/widgets/navigation_state.dart';

class CustomBottomNavBar extends StatelessWidget {
  final List<Map<String, dynamic>> navItems;
  final NavigationState navState;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.navItems,
    required this.navState,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        height: 85.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 25.r,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            return NavBarItem(
              icon: navItems[index]['icon'],
              label: navItems[index]['label'],
              isSelected: navState.selectedIndex == index,
              onTap: () {
                onItemTapped(index);
              },
            );
          }),
        ),
      ),
    );
  }
}
