import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../providers/menu_providers.dart';

class MenuManagementScreen extends ConsumerWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsStream = ref.watch(menuListProvider);
    final filteredItems = ref.watch(filteredMenuListProvider);
    final searchQuery = ref.watch(menuSearchQueryProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('QUẢN LÝ THỰC ĐƠN & ĐỒ UỐNG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppTheme.accentNeonRed),
            tooltip: 'Xóa tất cả thực đơn',
            onPressed: () => _showDeleteAllConfirmDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm món ăn / đồ uống
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => ref.read(menuSearchQueryProvider.notifier).setQuery(val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đồ uống/món ăn theo tên...',
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

          // Danh sách thực đơn thời gian thực
          Expanded(
            child: menuItemsStream.when(
              data: (allItems) {
                if (allItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu_outlined, size: 80, color: AppTheme.textMuted),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có món ăn/nước uống nào',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditItemDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm món mới'),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredItems.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy món ăn/nước uống phù hợp!',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppTheme.cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.borderStroke, width: 1),
                      ),
                      child: ListTile(
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
                        subtitle: Row(
                          children: [
                            Text(
                              currencyFormat.format(item.price),
                              style: const TextStyle(color: AppTheme.primaryGold, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.isAvailable
                                    ? AppTheme.accentNeonGreen.withOpacity(0.15)
                                    : AppTheme.accentNeonRed.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.isAvailable ? 'Phục vụ' : 'Hết hàng',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.isAvailable ? AppTheme.accentNeonGreen : AppTheme.accentNeonRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditItemDialog(context, ref, item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppTheme.accentNeonRed),
                              onPressed: () => _showDeleteConfirmDialog(context, ref, item),
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
              error: (err, stack) => Center(
                child: Text(
                  'Lỗi tải thực đơn: $err',
                  style: const TextStyle(color: AppTheme.accentNeonRed),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: AppTheme.darkBg,
        onPressed: () => _showAddEditItemDialog(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showAddEditItemDialog(BuildContext context, WidgetRef ref, [MenuItemEntity? item]) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(text: item != null ? '${item.price.toInt()}' : '');
    MenuCategory category = item?.category ?? MenuCategory.drink;
    bool isAvailable = item?.isAvailable ?? true;
    String selectedUnit = item?.unit ?? 'Chai';
    final isEdit = item != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: Text(
            isEdit ? 'Chỉnh sửa món' : 'Thêm món mới',
            style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên món',
                    labelStyle: TextStyle(color: AppTheme.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderStroke)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
                  ),
                  style: const TextStyle(color: AppTheme.textMain),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Đơn giá (đ)',
                    labelStyle: TextStyle(color: AppTheme.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderStroke)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
                  ),
                  style: const TextStyle(color: AppTheme.textMain),
                ),
                const SizedBox(height: 16),
                const Text('Phân loại:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MenuCategory.values.map((cat) {
                    final isSel = category == cat;
                    return ChoiceChip(
                      label: Text(cat == MenuCategory.drink
                          ? 'Đồ uống 🍹'
                          : cat == MenuCategory.food
                              ? 'Đồ ăn 🍔'
                              : 'Snack 🍟'),
                      selected: isSel,
                      selectedColor: AppTheme.primaryGold.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSel ? AppTheme.primaryGold : AppTheme.textMuted,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => category = cat);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Đơn vị tính:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  dropdownColor: AppTheme.cardBg,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.darkBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: const TextStyle(color: AppTheme.textMain),
                  items: const ['Chai', 'Lon', 'Ly', 'Đĩa', 'Phần'].map((u) {
                    return DropdownMenuItem<String>(
                      value: u,
                      child: Text(u),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedUnit = val);
                  },
                ),
                if (isEdit) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trạng thái phục vụ:', style: TextStyle(color: AppTheme.textMain)),
                      Switch(
                        value: isAvailable,
                        activeColor: AppTheme.accentNeonGreen,
                        inactiveTrackColor: AppTheme.accentNeonRed.withOpacity(0.2),
                        onChanged: (val) => setState(() => isAvailable = val),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;

                if (name.isNotEmpty && price > 0) {
                  if (isEdit) {
                    await ref.read(menuActionsProvider.notifier).updateMenuItem(
                          item.copyWith(
                            name: name,
                            price: price,
                            category: category,
                            isAvailable: isAvailable,
                            unit: selectedUnit,
                          ),
                        );
                  } else {
                    await ref.read(menuActionsProvider.notifier).addMenuItem(name, price, category, selectedUnit);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(isEdit ? 'Lưu' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('XÓA MÓN?', style: TextStyle(color: AppTheme.accentNeonRed, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa món "${item.name}" khỏi thực đơn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentNeonRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(menuActionsProvider.notifier).deleteMenuItem(item.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('CẢNH BÁO NGUY HIỂM', style: TextStyle(color: AppTheme.accentNeonRed, fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa TẤT CẢ các món ăn và đồ uống khỏi thực đơn? Thao tác này không thể khôi phục!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentNeonRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(menuActionsProvider.notifier).deleteAllMenuItems();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('XÓA TẤT CẢ'),
          ),
        ],
      ),
    );
  }
}
