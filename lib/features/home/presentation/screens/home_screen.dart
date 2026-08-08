import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/core/di/services_locator.dart';
import 'package:shop/core/widgets/home_app_bar.dart';
import 'package:shop/features/home/presentation/manager/home_cubit.dart';
import 'widgets/home_screen_body.dart';
import 'package:shop/core/widgets/whatsapp_floating_button.dart';
import 'package:shop/core/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<HomeCubit>()..init(),
      child: const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        drawer: AppDrawer(),
        appBar: HomeAppBar(),
        body: HomeScreenBody(),
        floatingActionButton: WhatsappFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
