import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/table_providers.dart';
import '../../domain/entities/table_entity.dart';

class TableGridScreen extends ConsumerWidget {
  const TableGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesStream = ref.watch(tableListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BAR MANAGER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.straighten, color: AppTheme.primaryGold),
            tooltip: 'Quản lý Đơn vị',
            onPressed: () => context.push('/units'),
          ),
          IconButton(
            icon: const Icon(Icons.move_to_inbox, color: AppTheme.primaryGold),
            tooltip: 'Nhập hàng',
            onPressed: () => context.push('/stock-in'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryGold),
            tooltip: 'Tiêu thụ',
            onPressed: () => context.push('/consumption'),
          ),
          IconButton(
            icon: const Icon(Icons.inventory, color: AppTheme.primaryGold),
            tooltip: 'Báo cáo kho',
            onPressed: () => context.push('/stock-manage'),
          ),
          IconButton(
            icon: const Icon(Icons.restaurant_menu, color: AppTheme.primaryGold),
            tooltip: 'Quản lý Menu',
            onPressed: () => context.push('/menu-manage'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: AppTheme.primaryGold),
            tooltip: 'Báo cáo doanh thu',
            onPressed: () => context.push('/report'),
          ),
        ],
      ),
      body: tablesStream.when(
        data: (tables) {
          if (tables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.table_restaurant_outlined, size: 80, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có bàn nào trong sơ đồ',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTableDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm bàn mới'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                final isVacant = table.status == TableStatus.vacant;

                return GestureDetector(
                  onTap: () {
                    context.push('/table/${table.id}?name=${Uri.encodeComponent(table.name)}');
                  },
                  onLongPress: () {
                    if (isVacant) {
                      _showDeleteConfirmDialog(context, ref, table);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể xóa bàn đang có khách!'),
                          backgroundColor: AppTheme.accentNeonRed,
                        ),
                      );
                    }
                  },
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.cardBg,
                            AppTheme.cardBg.withOpacity(0.8),
                          ],
                        ),
                        border: Border.all(
                          color: isVacant 
                              ? AppTheme.accentNeonGreen.withOpacity(0.3) 
                              : AppTheme.accentNeonRed.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isVacant 
                                ? AppTheme.accentNeonGreen.withOpacity(0.08) 
                                : AppTheme.accentNeonRed.withOpacity(0.08),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_restaurant,
                            size: 48,
                            color: isVacant ? AppTheme.accentNeonGreen : AppTheme.accentNeonRed,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            table.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isVacant 
                                  ? AppTheme.accentNeonGreen.withOpacity(0.15) 
                                  : AppTheme.accentNeonRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isVacant ? 'TRỐNG' : 'CÓ KHÁCH',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isVacant ? AppTheme.accentNeonGreen : AppTheme.accentNeonRed,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
        error: (err, stack) => Center(
          child: Text(
            'Lỗi tải sơ đồ bàn: $err',
            style: const TextStyle(color: AppTheme.accentNeonRed),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: AppTheme.darkBg,
        onPressed: () => _showAddTableDialog(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showAddTableDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Thêm bàn mới', style: TextStyle(color: AppTheme.primaryGold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Tên bàn (ví dụ: Bàn 5, Bàn VIP 1)',
          ),
          autofocus: true,
          style: const TextStyle(color: AppTheme.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref.read(tableActionsProvider.notifier).createTable(name);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, TableEntity table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Xác nhận xóa bàn', style: TextStyle(color: AppTheme.accentNeonRed)),
        content: Text('Bạn có chắc chắn muốn xóa ${table.name} khỏi sơ đồ?'),
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
              await ref.read(tableActionsProvider.notifier).deleteTable(table.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
