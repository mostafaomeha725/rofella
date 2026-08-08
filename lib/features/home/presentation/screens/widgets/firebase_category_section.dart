import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/core/widgets/section_title.dart';
import 'package:shop/core/widgets/product_card.dart';
import 'package:shop/core/di/services_locator.dart';
import 'package:shop/features/home/data/services/category_cache_service.dart';

class FirebaseCategorySection extends StatefulWidget {
  final String categoryTitle;
  final bool showTitle;
  final Widget? emptyStateWidget;

  const FirebaseCategorySection({
    super.key,
    required this.categoryTitle,
    this.showTitle = true,
    this.emptyStateWidget,
  });

  @override
  State<FirebaseCategorySection> createState() =>
      _FirebaseCategorySectionState();
}

class _FirebaseCategorySectionState extends State<FirebaseCategorySection> {
  CategorySectionData? _data;
  final Set<String> _animatedProductIds = {};
  bool _isLoadingMore = false;
  late final CategoryCacheService _cacheService;

  @override
  void initState() {
    super.initState();
    _cacheService = sl<CategoryCacheService>();
    _loadData();
  }

  Future<void> _loadData() async {
    final cachedData = _cacheService.getCached(widget.categoryTitle);

    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _data = cachedData;
        });
      }

      if (cachedData.lastFetch != null) {
        final diff = DateTime.now().difference(cachedData.lastFetch!);
        if (diff.inMinutes >= 5) {
          _backgroundRefresh();
        }
      }
    } else {
      await _cacheService.fetchCategory(widget.categoryTitle, limit: 8);
      if (mounted) {
        setState(() {
          _data = _cacheService.getCached(widget.categoryTitle);
        });
      }
    }
  }

  Future<void> _backgroundRefresh() async {
    final didUpdate = await _cacheService.backgroundRefresh(
      widget.categoryTitle,
      limit: 8,
    );
    if (didUpdate && mounted) {
      setState(() {
        _data = _cacheService.getCached(widget.categoryTitle);
        _animatedProductIds.clear();
      });
    }
  }

  Future<void> _fetchMoreProducts() async {
    if (_isLoadingMore || _data == null || !_data!.hasMore) return;

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    await _cacheService.fetchCategory(
      widget.categoryTitle,
      startAfter: _data!.lastDocument as DocumentSnapshot?,
      limit: 8,
    );

    if (mounted) {
      setState(() {
        _data = _cacheService.getCached(widget.categoryTitle);
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null || _data!.products == null) {
      return const SizedBox(
        height: 350,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF5C2428)),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _data!,
      builder: (context, _) {
        final products = _data!.products;

        if (products == null || products.isEmpty) {
          return widget.emptyStateWidget ?? const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showTitle) SectionTitle(title: widget.categoryTitle),
            LayoutBuilder(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.60,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  cacheExtent: 0,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  addSemanticIndexes: false,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _StaggeredAnimatedItem(
                      key: ValueKey(product.id),
                      index: index,
                      productId: product.id ?? 'item_$index',
                      animatedProductIds: _animatedProductIds,
                      child: ProductCard(
                        key: ValueKey(product.id),
                        product: product,
                      ),
                    );
                  },
                );
              },
            ),
            if (_data!.hasMore && products.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                  child: _isLoadingMore
                      ? const CircularProgressIndicator(color: Colors.black)
                      : ElevatedButton(
                          onPressed: _fetchMoreProducts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111111),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            'Load more',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StaggeredAnimatedItem extends StatefulWidget {
  final Widget child;
  final int index;
  final String productId;
  final Set<String> animatedProductIds;

  const _StaggeredAnimatedItem({
    super.key,
    required this.child,
    required this.index,
    required this.productId,
    required this.animatedProductIds,
  });

  @override
  State<_StaggeredAnimatedItem> createState() => _StaggeredAnimatedItemState();
}

class _StaggeredAnimatedItemState extends State<_StaggeredAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAlreadyAnimated = false;

  @override
  void initState() {
    super.initState();
    _isAlreadyAnimated = widget.animatedProductIds.contains(widget.productId);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (_isAlreadyAnimated) {
      _controller.value = 1.0;
    } else {
      widget.animatedProductIds.add(widget.productId);
      final delay = (widget.index % 8) * 30;
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAlreadyAnimated && _controller.isCompleted) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
