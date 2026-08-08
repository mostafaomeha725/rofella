import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/core/utils/spacing.dart';

import 'package:shop/features/home/presentation/manager/home_cubit.dart';

import 'collections_section.dart';
import 'firebase_category_section.dart';

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200), // Max desktop width
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is HomeError) {
              return Center(child: Text(state.message));
            }

            if (state is HomeLoaded) {
              final categories = state.categories;

              return ListView.builder(
                itemCount: categories.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        const CollectionsSection(),
                        verticalSpacing(16),
                      ],
                    );
                  }
                  if (index == categories.length + 1) {
                    return verticalSpacing(32);
                  }

                  final category = categories[index - 1];
                  return Column(
                    children: [
                      FirebaseCategorySection(categoryTitle: category.name),
                      verticalSpacing(16),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
