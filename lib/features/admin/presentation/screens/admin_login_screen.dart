import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/app_form_field.dart';
import 'package:shop/core/widgets/custom_text.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final String _correctPassword = '01005797956Mo'; // Hardcoded for now
  bool _obscureText = true;
  String? _errorMessage;

  void _login() {
    if (_passwordController.text == _correctPassword) {
      context.go(Routes.adminDashboardScreen);
    } else {
      setState(() {
        _errorMessage = 'كلمة المرور غير صحيحة';
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark professional theme
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 100,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              AppText(
                'لوحة تحكم الإدارة',
                style: font24w700.copyWith(color: Colors.white),
                alignment: AlignmentDirectional.center,
              ),
              const SizedBox(height: 8),
              AppText(
                'يرجى إدخال كلمة المرور للمتابعة',
                style: font14w500.copyWith(color: Colors.white70),
                alignment: AlignmentDirectional.center,
              ),
              const SizedBox(height: 48),
              AppFormField(
                controller: _passwordController,
                hintText: 'كلمة المرور',
                obsecureText: _obscureText,
                maxLines: 1,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                onFieldSubmitted: (_) => _login(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppText(
                    _errorMessage!,
                    style: font14w500.copyWith(color: Colors.redAccent),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AppText(
                    'تسجيل الدخول',
                    style: font16w700.copyWith(color: Colors.white),
                    alignment: AlignmentDirectional.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
