import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../menu/presentation/providers/menu_providers.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../providers/stock_providers.dart';

class StockManagementScreen extends ConsumerStatefulWidget {
  const StockManagementScreen({super.key});

  @override
  ConsumerState<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends ConsumerState<StockManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final menuItemsAsync = ref.watch(menuListProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BÁO CÁO TỒN KHO'),
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryGold,
            labelColor: AppTheme.primaryGold,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(text: 'TẤT CẢ SẢN PHẨM'),
              Tab(text: 'ĐÃ HẾT HÀNG (TỒN = 0)'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Thanh tìm kiếm sản phẩm trong kho
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm trong kho...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGold),
                  filled: true,
                  fillColor: AppTheme.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(color: AppTheme.textMain),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Tất cả
                  _buildStockList(menuItemsAsync, onlyOutOfStock: false, currencyFormat: currencyFormat),
                  // Tab 2: Hết hàng
                  _buildStockList(menuItemsAsync, onlyOutOfStock: true, currencyFormat: currencyFormat),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockList(
    AsyncValue<List<MenuItemEntity>> menuItemsAsync, {
    required bool onlyOutOfStock,
    required NumberFormat currencyFormat,
  }) {
    return menuItemsAsync.when(
      data: (items) {
        var filteredItems = items.where((item) {
          return item.category == MenuCategory.ingredient &&
              item.name.toLowerCase().contains(_searchQuery);
        }).toList();

        if (onlyOutOfStock) {
          filteredItems = filteredItems.where((item) => item.stock <= 0).toList();
        }

        if (filteredItems.isEmpty) {
          return Center(
            child: Text(
              onlyOutOfStock
                  ? 'Không có sản phẩm nào đã bán hết hàng!'
                  : 'Không tìm thấy sản phẩm nào trong kho!',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isOutOfStock = item.stock <= 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: AppTheme.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.borderStroke, width: 1),
              ),
              child: ListTile(
                onTap: () => _showProductHistoryBottomSheet(context, item),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.darkBg,
                  child: Text(
                    item.category == MenuCategory.drink
                        ? '🍹'
                        : item.category == MenuCategory.food
                            ? '🍔'
                            : '🍟',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                subtitle: Text(
                  'Giá bán: ${currencyFormat.format(item.price)}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? AppTheme.accentNeonRed.withValues(alpha: 0.15)
                        : AppTheme.accentNeonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Tồn: ${item.stock} ${item.unit}',
                    style: TextStyle(
                      color: isOutOfStock ? AppTheme.accentNeonRed : AppTheme.accentNeonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGold),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Lỗi tải danh mục kho: $err',
          style: const TextStyle(color: AppTheme.accentNeonRed),
        ),
      ),
    );
  }

  // BottomSheet xem chi tiết lịch sử Nhập Hàng / Tiêu Thụ của sản phẩm
  void _showProductHistoryBottomSheet(BuildContext context, MenuItemEntity item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final allTransactionsStream = ref.watch(allStockTransactionsProvider);
                final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
                final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

                return Column(
                  children: [
                    // Thanh gạt drag handle
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.borderStroke,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tiêu đề
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppTheme.primaryGold,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Tồn kho hiện tại: ${item.stock} ${item.unit}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.textMuted),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppTheme.borderStroke, height: 24),

                    // Lịch sử giao dịch kho
                    Expanded(
                      child: allTransactionsStream.when(
                        data: (txs) {
                          // Lọc giao dịch của sản phẩm cụ thể này
                          final productTxs = txs.where((tx) => tx.menuItemId == item.id).toList();

                          if (productTxs.isEmpty) {
                            return const Center(
                              child: Text(
                                'Chưa có lịch sử nhập xuất nào cho sản phẩm này!',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: productTxs.length,
                            itemBuilder: (context, idx) {
                              final tx = productTxs[idx];
                              final isIn = tx.type == 'in';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppTheme.darkBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: AppTheme.borderStroke, width: 0.5),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isIn
                                        ? AppTheme.accentNeonGreen.withValues(alpha: 0.1)
                                        : AppTheme.accentNeonRed.withValues(alpha: 0.1),
                                    child: Icon(
                                      isIn ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isIn ? AppTheme.accentNeonGreen : AppTheme.accentNeonRed,
                                    ),
                                  ),
                                  title: Text(
                                    isIn ? 'Nhập hàng' : 'Tiêu thụ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isIn ? AppTheme.accentNeonGreen : AppTheme.accentNeonRed,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateTimeFormat.format(tx.date),
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                      ),
                                      if (tx.note.isNotEmpty)
                                        Text(
                                          'Ghi chú: ${tx.note}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isIn ? "+" : "-"}${tx.quantity} ${item.unit}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isIn ? AppTheme.accentNeonGreen : AppTheme.accentNeonRed,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        currencyFormat.format(tx.quantity * tx.price),
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryGold),
                        ),
                        error: (err, _) => Center(
                          child: Text(
                            'Lỗi tải lịch sử: $err',
                            style: const TextStyle(color: AppTheme.accentNeonRed),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
