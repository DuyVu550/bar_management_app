import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/layout_providers.dart';
import '../../domain/entities/unit_entity.dart';
import '../providers/unit_providers.dart';

class UnitManagementScreen extends ConsumerWidget {
  const UnitManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsStream = ref.watch(unitListProvider);
    final filteredUnits = ref.watch(filteredUnitListProvider);
    final searchQuery = ref.watch(unitSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QUẢN LÝ ĐƠN VỊ'),
        leading: MediaQuery.of(context).size.width < 800
            ? IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.primaryGold),
                tooltip: 'Mở menu',
                onPressed: () => ref.read(scaffoldKeyProvider).currentState?.openDrawer(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppTheme.accentNeonRed),
            tooltip: 'Xóa tất cả đơn vị',
            onPressed: () => _showDeleteAllConfirmation(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm đơn vị
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => ref.read(unitSearchQueryProvider.notifier).setQuery(val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đơn vị theo tên...',
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
          
          // Danh sách đơn vị thời gian thực
          Expanded(
            child: unitsStream.when(
              data: (allUnits) {
                if (allUnits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.scale_outlined, size: 80, color: AppTheme.textMuted),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có đơn vị tính nào',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditUnitDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm đơn vị mới'),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredUnits.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy đơn vị phù hợp!',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUnits.length,
                  itemBuilder: (context, index) {
                    final unit = filteredUnits[index];
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
                          child: Icon(Icons.inventory_2_outlined, color: AppTheme.primaryGold),
                        ),
                        title: Text(
                          unit.name,
                          style: const TextStyle(
                            color: AppTheme.textMain,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Mã ID: #${unit.id}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditUnitDialog(context, ref, unit: unit),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppTheme.accentNeonRed),
                              onPressed: () => _showDeleteConfirmation(context, ref, unit),
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
                  'Lỗi tải dữ liệu: $err',
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
        onPressed: () => _showAddEditUnitDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Hộp thoại Thêm/Sửa đơn vị
  void _showAddEditUnitDialog(BuildContext context, WidgetRef ref, {UnitEntity? unit}) {
    final controller = TextEditingController(text: unit?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = unit != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: Text(
            isEdit ? 'SỬA ĐƠN VỊ' : 'THÊM ĐƠN VỊ MỚI',
            style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Tên đơn vị tính',
                labelStyle: TextStyle(color: AppTheme.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderStroke)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
              ),
              style: const TextStyle(color: AppTheme.textMain),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Vui lòng nhập tên đơn vị tính!';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final name = controller.text.trim();
                  if (isEdit) {
                    await ref.read(unitActionsProvider.notifier).updateUnit(unit.copyWith(name: name));
                  } else {
                    await ref.read(unitActionsProvider.notifier).addUnit(name);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('LƯU'),
            ),
          ],
        );
      },
    );
  }

  // Hộp thoại xác nhận xóa 1 đơn vị
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, UnitEntity unit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text('XÁC NHẬN XÓA', style: TextStyle(color: AppTheme.accentNeonRed, fontWeight: FontWeight.bold)),
          content: Text(
            'Bạn chắc chắn muốn xóa đơn vị "${unit.name}" chứ?',
            style: const TextStyle(color: AppTheme.textMain),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentNeonRed, foregroundColor: Colors.white),
              onPressed: () async {
                await ref.read(unitActionsProvider.notifier).deleteUnit(unit.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('XÓA'),
            ),
          ],
        );
      },
    );
  }

  // Hộp thoại xác nhận xóa tất cả đơn vị
  void _showDeleteAllConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text('CẢNH BÁO NGUY HIỂM', style: TextStyle(color: AppTheme.accentNeonRed, fontWeight: FontWeight.bold)),
          content: const Text(
            'Bạn chắc chắn muốn xóa TẤT CẢ các đơn vị tính chứ? Thao tác này không thể khôi phục!',
            style: TextStyle(color: AppTheme.textMain),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentNeonRed, foregroundColor: Colors.white),
              onPressed: () async {
                await ref.read(unitActionsProvider.notifier).deleteAllUnits();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('XÓA TẤT CẢ'),
            ),
          ],
        );
      },
    );
  }
}
