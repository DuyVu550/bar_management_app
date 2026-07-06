import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/layout_providers.dart';
import '../providers/table_providers.dart';
import '../../domain/entities/table_entity.dart';

class TableGridScreen extends ConsumerWidget {
  const TableGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesStream = ref.watch(tableListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SƠ ĐỒ BÀN'),
          leading: MediaQuery.of(context).size.width < 800
              ? IconButton(
                  icon: const Icon(Icons.menu, color: AppTheme.primaryGold),
                  tooltip: 'Mở menu',
                  onPressed: () => ref.read(scaffoldKeyProvider).currentState?.openDrawer(),
                )
              : null,
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryGold,
            labelColor: AppTheme.primaryGold,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(text: 'BÀN THƯỜNG'),
              Tab(text: 'BÀN VIP'),
            ],
          ),
        ),
        body: tablesStream.when(
          data: (tables) {
            // Chia bàn thường và bàn VIP (tên chứa chữ VIP)
            final normalTables = tables.where((t) => !t.name.toUpperCase().contains('VIP')).toList();
            final vipTables = tables.where((t) => t.name.toUpperCase().contains('VIP')).toList();

            return TabBarView(
              children: [
                _buildGrid(context, ref, normalTables, 'Chưa có bàn thường nào'),
                _buildGrid(context, ref, vipTables, 'Chưa có bàn VIP nào'),
              ],
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
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<TableEntity> tables, String emptyMessage) {
    if (tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_restaurant_outlined, size: 80, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 18, fontWeight: FontWeight.w500),
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

          return Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.cardBg,
                    AppTheme.cardBg.withValues(alpha: 0.8),
                  ],
                ),
                border: Border.all(
                  color: isVacant 
                      ? AppTheme.accentNeonGreen.withValues(alpha: 0.3) 
                      : AppTheme.accentNeonRed.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isVacant 
                        ? AppTheme.accentNeonGreen.withValues(alpha: 0.08) 
                        : AppTheme.accentNeonRed.withValues(alpha: 0.08),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: Stack(
                children: [
                  // Phần click chính vào bàn để gọi món (đặt trước)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.push('/table/${table.id}?name=${Uri.encodeComponent(table.name)}');
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_restaurant,
                            size: 44,
                            color: isVacant ? AppTheme.accentNeonGreen : AppTheme.accentNeonRed,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            table.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: isVacant 
                                  ? AppTheme.accentNeonGreen.withValues(alpha: 0.15) 
                                  : AppTheme.accentNeonRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isVacant ? 'TRỐNG' : 'CÓ KHÁCH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isVacant ? AppTheme.accentNeonGreen : AppTheme.accentNeonRed,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Nút menu (3 chấm) ở góc trên bên phải hiển thị PopupMenu trực quan (đặt sau để đè lên trên InkWell)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppTheme.textMuted,
                        size: 22,
                      ),
                      tooltip: 'Tùy chọn bàn',
                      onSelected: (value) {
                        if (value == 'rename') {
                          _showRenameTableDialog(context, ref, table);
                        } else if (value == 'delete') {
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
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'rename',
                          child: ListTile(
                            leading: Icon(Icons.edit, color: AppTheme.primaryGold, size: 20),
                            title: Text('Sửa tên bàn', style: TextStyle(fontSize: 14)),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          enabled: isVacant,
                          child: ListTile(
                            leading: Icon(
                              Icons.delete,
                              color: isVacant ? AppTheme.accentNeonRed : AppTheme.textMuted,
                              size: 20,
                            ),
                            title: Text(
                              'Xóa bàn',
                              style: TextStyle(
                                fontSize: 14,
                                color: isVacant ? AppTheme.textMain : AppTheme.textMuted,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                try {
                  await ref.read(tableActionsProvider.notifier).createTable(name);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  final errorMsg = e.toString().replaceFirst('Exception: ', '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg),
                        backgroundColor: AppTheme.accentNeonRed,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showRenameTableDialog(BuildContext context, WidgetRef ref, TableEntity table) {
    final controller = TextEditingController(text: table.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Đổi tên bàn', style: TextStyle(color: AppTheme.primaryGold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập tên bàn mới',
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
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await ref.read(tableActionsProvider.notifier).renameTable(table.id, newName);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  final errorMsg = e.toString().replaceFirst('Exception: ', '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg),
                        backgroundColor: AppTheme.accentNeonRed,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Lưu'),
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
              try {
                await ref.read(tableActionsProvider.notifier).deleteTable(table.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                final errorMsg = e.toString().replaceFirst('Exception: ', '');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: AppTheme.accentNeonRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
