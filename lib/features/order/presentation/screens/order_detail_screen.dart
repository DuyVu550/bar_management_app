import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../../menu/presentation/providers/menu_providers.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../providers/order_providers.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int tableId;
  final String tableName;

  const OrderDetailScreen({
    super.key,
    required this.tableId,
    required this.tableName,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> with SingleTickerProviderStateMixin {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  late TabController _tabController;
  String _searchQuery = '';
  MenuCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeOrderStream = ref.watch(activeOrderProvider(widget.tableId));
    final menuItemsStream = ref.watch(menuListProvider);

    return activeOrderStream.when(
      data: (order) {
        final hasOrder = order != null;
        
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.tableName, style: const TextStyle(fontSize: 20)),
                Text(
                  hasOrder ? 'Đang hoạt động' : 'Chưa mở bàn',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasOrder ? AppTheme.accentNeonRed : AppTheme.accentNeonGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            bottom: hasOrder
                ? TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primaryGold,
                    labelColor: AppTheme.primaryGold,
                    unselectedLabelColor: AppTheme.textMuted,
                    tabs: [
                      const Tab(icon: Icon(Icons.restaurant_menu), text: 'THỰC ĐƠN'),
                      Tab(
                        icon: Badge(
                          label: Text('${order.items.fold<int>(0, (sum, item) => sum + item.quantity)}'),
                          isLabelVisible: order.items.isNotEmpty,
                          backgroundColor: AppTheme.accentNeonRed,
                          child: const Icon(Icons.receipt_long),
                        ),
                        text: 'ĐƠN HÀNG',
                      ),
                    ],
                  )
                : null,
          ),
          body: !hasOrder
              ? _buildEmptyOrderState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMenuTab(order, menuItemsStream),
                    _buildOrderItemsTab(order),
                  ],
                ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(widget.tableName)),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: Text(widget.tableName)),
        body: Center(child: Text('Lỗi: $err', style: const TextStyle(color: AppTheme.accentNeonRed))),
      ),
    );
  }

  Widget _buildEmptyOrderState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_bar_outlined, size: 100, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              '${widget.tableName} đang trống',
              style: const TextStyle(color: AppTheme.textMain, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Khách hàng cần mở bàn trước khi gọi đồ uống & món ăn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(orderActionsProvider.notifier).createOrder(widget.tableId);
                },
                child: const Text('MỞ BÀN GỌI MÓN', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTab(OrderEntity order, AsyncValue<List<MenuItemEntity>> menuItemsStream) {
    return menuItemsStream.when(
      data: (items) {
        final availableItems = items.where((item) => item.isAvailable && item.category != MenuCategory.ingredient).toList();
        final filteredItems = availableItems.where((item) {
          final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesCategory = _selectedCategory == null || item.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        return Column(
          children: [
            // Thanh tìm kiếm và Filter Category
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món nước, đồ ăn...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardBg,
                    ),
                    style: const TextStyle(color: AppTheme.textMain),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryFilterChip(null, 'Tất cả'),
                        _buildCategoryFilterChip(MenuCategory.drink, 'Đồ uống 🍹'),
                        _buildCategoryFilterChip(MenuCategory.food, 'Đồ ăn 🍔'),
                        _buildCategoryFilterChip(MenuCategory.snack, 'Snack 🍟'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Danh sách món
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(child: Text('Không tìm thấy món phù hợp', style: TextStyle(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.darkBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  item.category == MenuCategory.drink
                                      ? '🍹'
                                      : item.category == MenuCategory.food
                                          ? '🍔'
                                          : '🍟',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(_currencyFormat.format(item.price), style: const TextStyle(color: AppTheme.primaryGold)),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle, color: AppTheme.primaryGold, size: 30),
                              onPressed: () => _showAddNoteDialog(context, order.id, item),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
      error: (err, stack) => Center(child: Text('Lỗi tải menu: $err')),
    );
  }

  Widget _buildCategoryFilterChip(MenuCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primaryGold.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryGold : AppTheme.textMuted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: AppTheme.primaryGold,
        backgroundColor: AppTheme.cardBg,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
      ),
    );
  }

  Widget _buildOrderItemsTab(OrderEntity order) {
    return Column(
      children: [
        Expanded(
          child: order.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt, size: 64, color: AppTheme.textMuted),
                      SizedBox(height: 12),
                      Text('Chưa gọi món nào', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menuItem.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currencyFormat.format(item.priceAtOrder),
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                  ),
                                  if (item.note != null && item.note!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ghi chú: ${item.note}',
                                      style: const TextStyle(color: AppTheme.secondaryAmber, fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.textMuted),
                                  onPressed: () => ref.read(orderActionsProvider.notifier).updateQuantity(item.id, item.quantity - 1),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGold),
                                  onPressed: () => ref.read(orderActionsProvider.notifier).updateQuantity(item.id, item.quantity + 1),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.accentNeonRed),
                                  onPressed: () => ref.read(orderActionsProvider.notifier).removeOrderItem(item.id),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Panel thanh toán & Hủy bàn
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: AppTheme.borderStroke),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng thanh toán:', style: TextStyle(fontSize: 16, color: AppTheme.textMuted)),
                    Text(
                      _currencyFormat.format(order.totalAmount),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentNeonRed,
                          side: const BorderSide(color: AppTheme.accentNeonRed),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showCancelOrderDialog(context, order.id),
                        child: const Text('HỦY BÀN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (order.items.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _showCheckoutReceiptDialog(context, order),
                          child: const Text('THANH TOÁN', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context, int orderId, MenuItemEntity item) {
    final noteController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Thêm ${item.name}', style: const TextStyle(color: AppTheme.primaryGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn giá: ${_currencyFormat.format(item.price)}', style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Số lượng:', style: TextStyle(color: AppTheme.textMain)),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textMain),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Ghi chú (Ví dụ: Ít đá, không đường)',
              ),
              style: const TextStyle(color: AppTheme.textMain),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(qtyController.text) ?? 1;
              if (quantity > 0) {
                await ref.read(orderActionsProvider.notifier).addOrderItem(
                      orderId: orderId,
                      menuItemId: item.id,
                      quantity: quantity,
                      price: item.price,
                      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm ${item.name} vào đơn hàng'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context, int orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Hủy đơn hàng?', style: TextStyle(color: AppTheme.accentNeonRed)),
        content: const Text('Tất cả các món đã gọi sẽ bị hủy và bàn sẽ được trả về trạng thái trống. Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentNeonRed, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(orderActionsProvider.notifier).cancelOrder(orderId);
              if (context.mounted) {
                Navigator.pop(context);
                context.pop();
              }
            },
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutReceiptDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Center(
          child: Text(
            'HÓA ĐƠN THANH TOÁN',
            style: TextStyle(color: AppTheme.primaryGold, letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.tableName.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 16),
                  ),
                ),
                Center(
                  child: Text(
                    'Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
                const Divider(color: AppTheme.borderStroke, height: 24, thickness: 1.5),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.menuItem.name, style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w500)),
                                if (item.note != null && item.note!.isNotEmpty)
                                  Text('Note: ${item.note}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          Text('${item.quantity} x ', style: const TextStyle(color: AppTheme.textMuted)),
                          Text(
                            _currencyFormat.format(item.priceAtOrder * item.quantity),
                            style: const TextStyle(color: AppTheme.textMain),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(color: AppTheme.borderStroke, height: 24, thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textMain)),
                    Text(
                      _currencyFormat.format(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryGold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Cảm ơn quý khách! Hẹn gặp lại!',
                    style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(orderActionsProvider.notifier).checkoutOrder(order.id);
              if (context.mounted) {
                Navigator.pop(context);
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thanh toán thành công!'),
                    backgroundColor: AppTheme.accentNeonGreen,
                  ),
                );
              }
            },
            child: const Text('XÁC NHẬN THANH TOÁN'),
          ),
        ],
      ),
    );
  }
}
