import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/item_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/item_card.dart';

class ListingScreen extends StatefulWidget {
  final String? initialCategory;

  const ListingScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ItemProvider>(context, listen: false);
      if (widget.initialCategory != null) {
        provider.setCategory(widget.initialCategory!);
      }
      _searchController.text = provider.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort & Filter Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSortOption(ctx, itemProvider, 'newest', 'Newest Arrivals', Icons.new_releases_outlined),
              _buildSortOption(ctx, itemProvider, 'price_asc', 'Price: Low to High', Icons.arrow_upward_rounded),
              _buildSortOption(ctx, itemProvider, 'price_desc', 'Price: High to Low', Icons.arrow_downward_rounded),
              _buildSortOption(ctx, itemProvider, 'rating', 'Customer Rating', Icons.star_outline_rounded),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    ItemProvider provider,
    String value,
    String title,
    IconData icon,
  ) {
    final isSelected = provider.sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        provider.setSortBy(value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = itemProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products & Services'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: 'Toggle Layout',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filter & Sort',
            onPressed: () => _showSortBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: Column(
              children: [
                // Search Input Field with Clear Button
                TextField(
                  controller: _searchController,
                  onChanged: (val) => itemProvider.setSearchQuery(val.trim()),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search items, tags, or descriptions...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              itemProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: AppStyles.roundedMedium,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: itemProvider.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = itemProvider.categories[index];
                      return CategoryChip(
                        label: category,
                        isSelected: itemProvider.selectedCategory == category,
                        onTap: () => itemProvider.setCategory(category),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Count and Active Filter Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${items.length} ${items.length == 1 ? "result" : "results"} found',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                if (itemProvider.selectedCategory != 'All' || itemProvider.searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      itemProvider.resetFilters();
                    },
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Items Grid or List View with Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await itemProvider.fetchCategories();
                await itemProvider.fetchItems();
              },
              child: itemProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? EmptyStateView(
                          title: 'No Matching Records',
                          message:
                              'We couldn’t find any items matching "${itemProvider.searchQuery}" in category "${itemProvider.selectedCategory}".',
                          buttonText: 'Reset All Filters',
                          onButtonPressed: () {
                            _searchController.clear();
                            itemProvider.resetFilters();
                          },
                        )
                      : _isGridView
                          ? GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return ItemCard(item: items[index]);
                              },
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  height: 220,
                                  child: ItemCard(item: items[index]),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
