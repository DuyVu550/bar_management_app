import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/layout_providers.dart';
import '../../../menu/presentation/providers/menu_providers.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/stock_transaction_entity.dart';
import '../providers/stock_providers.dart';
import '../../../../core/database/database_provider.dart';
import '../../../unit/presentation/providers/unit_providers.dart';

class ConsumptionScreen extends ConsumerWidget {
  const ConsumptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consumptionStream = ref.watch(consumptionListProvider);
    final filteredConsumption = ref.watch(filteredConsumptionListProvider);
    final searchQuery = ref.watch(stockSearchQueryProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('TIÊU THỤ & LỊCH SỬ'),
        leading: MediaQuery.of(context).size.width < 800
            ? IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.primaryGold),
                tooltip: 'Mở menu',
                onPressed: () => ref.read(scaffoldKeyProvider).currentState?.openDrawer(),
              )
            : null,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm theo tên đồ uống tiêu thụ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) =>
                  ref.read(stockSearchQueryProvider.notifier).setQuery(val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tiêu thụ...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primaryGold,
                ),
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

          // Danh sách lịch sử tiêu thụ gom nhóm theo ngày
          Expanded(
            child: consumptionStream.when(
              data: (allTransactions) {
                if (allTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.outbox_outlined,
                          size: 80,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có lịch sử tiêu thụ nào',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showAddConsumptionDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Ghi nhận tiêu thụ mới'),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredConsumption.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy giao dịch tiêu thụ phù hợp!',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                  );
                }

                // Gom nhóm giao dịch tiêu thụ theo ngày
                final Map<String, List<StockTransactionEntity>>
                groupedTransactions = {};
                for (final tx in filteredConsumption) {
                  final key = dateFormat.format(tx.date);
                  groupedTransactions.putIfAbsent(key, () => []).add(tx);
                }

                final sortedDates = groupedTransactions.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final dateStr = sortedDates[index];
                    final dailyTxs = groupedTransactions[dateStr]!;

                    // Tính tổng số lượng & giá trị tiêu thụ trong ngày
                    final totalQty = dailyTxs.fold<int>(
                      0,
                      (sum, tx) => sum + tx.quantity,
                    );
                    final totalValue = dailyTxs.fold<double>(
                      0.0,
                      (sum, tx) => sum + (tx.quantity * tx.price),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      color: AppTheme.cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: AppTheme.borderStroke,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header ngày gom nhóm
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppTheme.darkBg,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: AppTheme.primaryGold,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ngày $dateStr',
                                      style: const TextStyle(
                                        color: AppTheme.textMain,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'SL: $totalQty',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Tổng trị giá: ${currencyFormat.format(totalValue)}',
                                      style: const TextStyle(
                                        color: AppTheme.primaryGold,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Chi tiết từng dòng tiêu thụ trong ngày
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dailyTxs.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: AppTheme.borderStroke,
                              height: 1,
                            ),
                            itemBuilder: (context, idx) {
                              final tx = dailyTxs[idx];
                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.darkBg,
                                  radius: 18,
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color: AppTheme.accentNeonRed,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  tx.menuItemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textMain,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Số lượng: ${tx.quantity} • Giá bán: ${currencyFormat.format(tx.price)}',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (tx.note.isNotEmpty)
                                      Text(
                                        'Ghi chú: ${tx.note}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currencyFormat.format(
                                        tx.quantity * tx.price,
                                      ),
                                      style: const TextStyle(
                                        color: AppTheme.textMain,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.accentNeonRed,
                                        size: 20,
                                      ),
                                      onPressed: () => _showDeleteConfirmDialog(
                                        context,
                                        ref,
                                        tx,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
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
                  'Lỗi tải dữ liệu tiêu thụ: $err',
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
        onPressed: () => _showAddConsumptionDialog(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // Dialog ghi nhận tiêu thụ mới
  void _showAddConsumptionDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    int? selectedId;
    final qtyController = TextEditingController();
    final noteController = TextEditingController();
    final customNameController = TextEditingController();
    String selectedCustomUnit = 'Chai';
    bool isAddingNew = false;
    bool isInitialized = false;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final menuItemsAsync = ref.watch(menuListProvider);
            final unitsAsync = ref.watch(unitListProvider);

            return menuItemsAsync.when(
              data: (items) {
                return unitsAsync.when(
                  data: (units) {
                    // Chỉ lấy các mặt hàng thuộc nhóm Nguyên liệu (ingredient)
                    final ingredients = items
                        .where((i) => i.category == MenuCategory.ingredient)
                        .toList();
                    final unitNames = units.map((u) => u.name).toList();
                    if (unitNames.isEmpty) {
                      unitNames.addAll([
                        'Chai',
                        'Lon',
                        'Ly',
                        'Kg',
                        'Bao',
                        'Thùng',
                        'Hộp',
                        'Gói',
                        'Quả',
                        'Đĩa',
                        'Phần',
                      ]);
                    }

                    return StatefulBuilder(
                      builder: (context, setState) {
                        if (!isInitialized) {
                          if (ingredients.isNotEmpty) {
                            selectedId = ingredients.first.id;
                            isAddingNew = false;
                          } else {
                            selectedId = -1;
                            isAddingNew = true;
                          }
                          selectedCustomUnit = unitNames.first;
                          isInitialized = true;
                        }

                        final canSubmit =
                            isAddingNew ||
                            (selectedId != null && selectedId != -1);

                        return AlertDialog(
                          backgroundColor: AppTheme.cardBg,
                          title: const Text(
                            'PHIẾU TIÊU THỤ',
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Form(
                            key: formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dropdown chọn nguyên liệu
                                  const Text(
                                    'Nguyên liệu tiêu thụ:',
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<int>(
                                    initialValue: selectedId,
                                    dropdownColor: AppTheme.cardBg,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppTheme.darkBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: AppTheme.textMain,
                                    ),
                                    items: [
                                      const DropdownMenuItem<int>(
                                        value: -1,
                                        child: Text(
                                          '+ Thêm nguyên liệu mới...',
                                          style: TextStyle(
                                            color: AppTheme.primaryGold,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ...ingredients.map((item) {
                                        return DropdownMenuItem<int>(
                                          value: item.id,
                                          child: Text(
                                            '${item.name} (${item.unit}) - Tồn: ${item.stock}',
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          selectedId = val;
                                          isAddingNew = (val == -1);
                                        });
                                      }
                                    },
                                  ),
                                  if (isAddingNew) ...[
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: customNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Tên nguyên liệu mới',
                                        labelStyle: TextStyle(
                                          color: AppTheme.textMuted,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppTheme.borderStroke,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppTheme.primaryGold,
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: AppTheme.textMain,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Vui lòng nhập tên nguyên liệu!';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Đơn vị tính:',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedCustomUnit,
                                      dropdownColor: AppTheme.cardBg,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppTheme.darkBg,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: AppTheme.textMain,
                                      ),
                                      items: unitNames.map((u) {
                                        return DropdownMenuItem<String>(
                                          value: u,
                                          child: Text(u),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            selectedCustomUnit = val;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 16),

                                  // Ô nhập số lượng
                                  TextFormField(
                                    controller: qtyController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Số lượng tiêu thụ',
                                      labelStyle: TextStyle(
                                        color: AppTheme.textMuted,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.borderStroke,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.primaryGold,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: AppTheme.textMain,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Vui lòng nhập số lượng!';
                                      }
                                      final qty = int.tryParse(val) ?? 0;
                                      if (qty <= 0) {
                                        return 'Số lượng phải lớn hơn 0!';
                                      }
                                      if (!isAddingNew && selectedId != -1) {
                                        final selectedItem = ingredients
                                            .firstWhere(
                                              (i) => i.id == selectedId,
                                            );
                                        if (qty > selectedItem.stock) {
                                          return 'Vượt quá số lượng tồn kho (Tồn: ${selectedItem.stock})!';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const SizedBox(height: 16),

                                  // Ô ghi chú
                                  TextFormField(
                                    controller: noteController,
                                    decoration: const InputDecoration(
                                      labelText: 'Ghi chú',
                                      labelStyle: TextStyle(
                                        color: AppTheme.textMuted,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.borderStroke,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.primaryGold,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: AppTheme.textMain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'HỦY',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            ),
                            if (canSubmit)
                              ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    final qty = int.parse(
                                      qtyController.text.trim(),
                                    );
                                    final note = noteController.text.trim();

                                    int itemId = selectedId ?? -1;
                                    double price = 0.0;
                                    String itemName = '';

                                    if (isAddingNew) {
                                      final newName = customNameController.text
                                          .trim();
                                      final db = ref.read(databaseProvider);
                                      await db.ensureConnected();
                                      final resItem = await db.dio.post(
                                        '/api/menu-items',
                                        data: {
                                          'name': newName,
                                          'price': price,
                                          'category':
                                              MenuCategory.ingredient.name,
                                          'unit': selectedCustomUnit,
                                        },
                                      );
                                      final createdItem = resItem.data;
                                      itemId = createdItem['id'] as int;
                                      itemName = createdItem['name'] as String;
                                      db.notifyMenuChanged();
                                    } else {
                                      final selectedItem = ingredients
                                          .firstWhere(
                                            (i) => i.id == selectedId,
                                          );
                                      itemId = selectedItem.id;
                                      itemName = selectedItem.name;
                                    }

                                    await ref
                                        .read(stockActionsProvider.notifier)
                                        .addConsumption(
                                          menuItemId: itemId,
                                          menuItemName: itemName,
                                          quantity: qty,
                                          price: price,
                                          note: note,
                                        );

                                    if (context.mounted) Navigator.pop(context);
                                  }
                                },
                                child: const Text('GHI NHẬN'),
                              ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ),
                  error: (err, _) => AlertDialog(
                    backgroundColor: AppTheme.cardBg,
                    content: Text(
                      'Lỗi tải đơn vị: $err',
                      style: const TextStyle(color: AppTheme.accentNeonRed),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'HỦY',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                ),
              ),
              error: (err, _) => AlertDialog(
                backgroundColor: AppTheme.cardBg,
                content: Text(
                  'Lỗi: $err',
                  style: const TextStyle(color: AppTheme.accentNeonRed),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'HỦY',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Xác nhận xóa phiếu tiêu thụ
  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    StockTransactionEntity tx,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text(
            'XÓA GIAO DỊCH?',
            style: TextStyle(
              color: AppTheme.accentNeonRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn chắc chắn muốn xóa giao dịch tiêu thụ của "${tx.menuItemName}" số lượng ${tx.quantity} chứ? Tồn kho sẽ được cộng trả lại.',
            style: const TextStyle(color: AppTheme.textMain),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'HỦY',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentNeonRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await ref
                    .read(stockActionsProvider.notifier)
                    .deleteStockTransaction(tx.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('XÓA'),
            ),
          ],
        );
      },
    );
  }
}
