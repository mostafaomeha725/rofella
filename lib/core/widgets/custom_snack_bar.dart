import 'package:flutter/material.dart';
import 'package:shop/core/utils/easy_loading.dart' as easy;

class CustomSnackBar {
  static void showSuccess(BuildContext context, {required String message}) {
    easy.showSuccess(message);
  }

  static void showError(BuildContext context, {required String message}) {
    easy.showError(message);
  }
}
