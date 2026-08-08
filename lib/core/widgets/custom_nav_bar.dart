import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_bottom_navbar.dart';
import 'package:shop/core/widgets/navigation_state.dart';

class CustomNavBar extends StatefulWidget {
  final bool isAdmin;

  const CustomNavBar({super.key, this.isAdmin = true});

  // ignore: library_private_types_in_public_api
  static _CustomNavBarState? of(BuildContext context) =>
      context.findAncestorStateOfType<_CustomNavBarState>();

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late NavigationState _navState;
  late List<Map<String, dynamic>> _navItems;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _navState = NavigationState();
    // _initializeNavigation();
  }

  // void _initializeNavigation() {
  //   if (widget.isAdmin) {
  //     _navItems = AdminNavData.items;
  //     _screens = AdminNavData.screens;
  //   } else {
  //     _navItems = CustomerNavData.items;
  //     _screens = CustomerNavData.screens;
  //   }
  // }

  void goBack() {
    setState(() {
      if (_navState.navigationStack.length > 1) {
        _navState.navigationStack.removeLast();
        _navState.selectedIndex = _navState.navigationStack.last;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _navState.navigationStack.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navState.handleBackPress(() => setState(() {}));
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff8f9fa),
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_navState.selectedIndex],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          navItems: _navItems,
          navState: _navState,
          onItemTapped: (index) {
            setState(() {
              _navState.selectedIndex = index;
              _navState.navigationStack.add(index);
            });
          },
        ),
      ),
    );
  }
}
