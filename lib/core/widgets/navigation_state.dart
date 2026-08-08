import 'package:flutter/material.dart';

class NavigationState {
  int selectedIndex = 0;
  final List<int> navigationStack = [0];

  void onItemTapped(int index, VoidCallback onStateChanged) {
    if (index == selectedIndex) return;
    selectedIndex = index;
    navigationStack.add(index);
    onStateChanged();
  }

  void goBack(VoidCallback onStateChanged) {
    if (navigationStack.length > 1) {
      navigationStack.removeLast();
      selectedIndex = navigationStack.last;
    } else {
      selectedIndex = 0;
    }
    onStateChanged();
  }

  void handleBackPress(VoidCallback onStateChanged) {
    if (navigationStack.length > 1) {
      navigationStack.removeLast();
      selectedIndex = navigationStack.last;
      onStateChanged();
    }
  }
}
