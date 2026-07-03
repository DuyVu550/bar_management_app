import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../providers/menu_providers.dart';

class IngredientManagementScreen extends ConsumerWidget {
  const IngredientManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsStream = ref.watch(menuListProvider);
    final filteredItems = ref.watch(filteredMenuListProvider);
    final searchQuery = ref.watch(menuSearchQueryProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('QUẢN LÝ NGUYÊN LIỆU'),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm nguyên liệu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => ref.read(menuSearchQueryProvider.notifier).setQuery(val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nguyên liệu theo tên...',
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

          // Danh sách nguyên liệu thời gian thực
          Expanded(
            child: menuItemsStream.when(
              data: (allItems) {
                final ingredients = allItems.where((i) => i.category == MenuCategory.ingredient).toList();
                final filteredIngredients = filteredItems.where((i) => i.category == MenuCategory.ingredient).toList();

                if (ingredients.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.layers_outlined, size: 80, color: AppTheme.textMuted),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có nguyên liệu nào',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Nguyên liệu mới sẽ tự động được thêm khi nhập kho.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredIngredients.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy nguyên liệu phù hợp!',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredIngredients.length,
                  itemBuilder: (context, index) {
                    final item = filteredIngredients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppTheme.cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.borderStroke, width: 1),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.darkBg,
                          child: Text(
                            '📦',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'Đơn vị tính: ${item.unit}',
                              style: const TextStyle(color: AppTheme.primaryGold, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.isAvailable
                                    ? AppTheme.accentNeonGreen.withValues(alpha: 0.15)
                                    : AppTheme.accentNeonRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.isAvailable ? 'Có sẵn' : 'Ngừng sử dụng',
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
                              onPressed: () => _showEditItemDialog(context, ref, item),
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
                  'Lỗi tải nguyên liệu: $err',
                  style: const TextStyle(color: AppTheme.accentNeonRed),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, WidgetRef ref, MenuItemEntity item) {
    final nameController = TextEditingController(text: item.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'ĐỔI TÊN NGUYÊN LIỆU',
          style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên nguyên liệu',
                labelStyle: TextStyle(color: AppTheme.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderStroke)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
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
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await ref.read(menuActionsProvider.notifier).updateMenuItem(
                      item.copyWith(name: name),
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'CẢNH BÁO XÓA NGUYÊN LIỆU',
          style: TextStyle(color: AppTheme.accentNeonRed, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa nguyên liệu "${item.name}"?\n\n'
          'Hành động này sẽ xóa vĩnh viễn nguyên liệu khỏi danh sách và có thể ảnh hưởng đến lịch sử giao dịch cũng như các báo cáo kho liên quan!',
          style: const TextStyle(color: AppTheme.textMain),
        ),
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
}
