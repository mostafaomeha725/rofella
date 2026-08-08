import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/utils/spacing.dart';
import 'package:shop/core/di/services_locator.dart';
import 'package:shop/features/search/presentation/manager/search_cubit.dart';
import 'package:shop/core/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  final String? categoryName;
  const SearchScreen({super.key, this.categoryName});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final SearchCubit _searchCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchCubit = sl.get<SearchCubit>(param1: widget.categoryName);

    _searchController.addListener(() {
      _searchCubit.searchLocal(_searchController.text);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = _searchCubit.state;
        if (state is SearchLoaded &&
            state.hasMoreNetwork &&
            !state.isNetworkLoadingMore &&
            state.hasSearchedNetwork) {
          _searchCubit.searchNetwork();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          titleSpacing: 0,
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _searchCubit.searchNetwork();
                }
              },
              style: font14w400.copyWith(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'ابحث عن المنتجات',
                hintStyle: font14w400.copyWith(color: Colors.black45),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black45,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.black45,
                          size: 16,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          actions: [const SizedBox(width: 16)],
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial) {
              return Center(
                child: Text(
                  'ابدأ البحث عن المنتجات',
                  style: font16w600.copyWith(color: Colors.grey[400]),
                ),
              );
            }

            if (state is SearchLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF9E6566)),
              );
            }

            if (state is SearchError) {
              return Center(child: Text('حدث خطأ: ${state.message}'));
            }

            if (state is SearchLoaded) {
              final products = state.products;

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                      verticalSpacing(16),
                      Text(
                        'لا توجد نتائج تطابق بحثك',
                        style: font16w600.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount;
                            if (constraints.maxWidth > 1024) {
                              crossAxisCount = 5;
                            } else if (constraints.maxWidth > 768) {
                              crossAxisCount = 4;
                            } else {
                              crossAxisCount = 2;
                            }

                            return GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.60,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: products[index]);
                              },
                            );
                          },
                        ),
                      ),
                      if (state.isNetworkLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF9E6566),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
