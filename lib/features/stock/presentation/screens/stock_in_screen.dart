import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../menu/presentation/providers/menu_providers.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/stock_transaction_entity.dart';
import '../providers/stock_providers.dart';

class StockInScreen extends ConsumerWidget {
  const StockInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockInStream = ref.watch(stockInListProvider);
    final filteredStockIn = ref.watch(filteredStockInListProvider);
    final searchQuery = ref.watch(stockSearchQueryProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('NHẬP HÀNG & LỊCH SỬ'),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm theo tên đồ uống
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => ref.read(stockSearchQueryProvider.notifier).setQuery(val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên đồ uống nhập...',
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

          // Danh sách lịch sử nhập hàng gom nhóm theo ngày
          Expanded(
            child: stockInStream.when(
              data: (allTransactions) {
                if (allTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.move_to_inbox_outlined, size: 80, color: AppTheme.textMuted),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có lịch sử nhập hàng nào',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddStockInDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Tạo phiếu nhập mới'),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredStockIn.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy giao dịch nhập hàng phù hợp!',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                  );
                }

                // Gom nhóm giao dịch nhập hàng theo ngày
                final Map<String, List<StockTransactionEntity>> groupedTransactions = {};
                for (final tx in filteredStockIn) {
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

                    // Tính tổng số lượng & chi phí trong ngày
                    final totalQty = dailyTxs.fold<int>(0, (sum, tx) => sum + tx.quantity);
                    final totalCost = dailyTxs.fold<double>(0.0, (sum, tx) => sum + (tx.quantity * tx.price));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      color: AppTheme.cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.borderStroke, width: 1),
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
                                    const Icon(Icons.calendar_today, color: AppTheme.primaryGold, size: 18),
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
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                    ),
                                    Text(
                                      'Tổng chi: ${currencyFormat.format(totalCost)}',
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

                          // Chi tiết từng dòng nhập hàng trong ngày
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dailyTxs.length,
                            separatorBuilder: (context, index) => const Divider(color: AppTheme.borderStroke, height: 1),
                            itemBuilder: (context, idx) {
                              final tx = dailyTxs[idx];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.darkBg,
                                  radius: 18,
                                  child: const Icon(Icons.arrow_downward, color: AppTheme.accentNeonGreen, size: 18),
                                ),
                                title: Text(
                                  tx.menuItemName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Số lượng: ${tx.quantity} • Đơn giá: ${currencyFormat.format(tx.price)}',
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                    ),
                                    if (tx.note.isNotEmpty)
                                      Text(
                                        'Ghi chú: ${tx.note}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currencyFormat.format(tx.quantity * tx.price),
                                      style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w500),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.accentNeonRed, size: 20),
                                      onPressed: () => _showDeleteConfirmDialog(context, ref, tx),
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
                  'Lỗi tải dữ liệu kho: $err',
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
        onPressed: () => _showAddStockInDialog(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // Dialog nhập hàng mới
  void _showAddStockInDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    MenuItemEntity? selectedItem;
    final qtyController = TextEditingController();
    final priceController = TextEditingController();
    final noteController = TextEditingController();
    final customNameController = TextEditingController();
    String selectedCustomUnit = 'Chai';
    bool isCustomProduct = false;
    bool isInitialized = false;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final menuItemsAsync = ref.watch(menuListProvider);

            return menuItemsAsync.when(
              data: (items) {
                if (!isInitialized && items.isNotEmpty) {
                  selectedItem = items.first;
                  isInitialized = true;
                }

                return StatefulBuilder(
                  builder: (context, setState) {
                    final canSubmit = isCustomProduct || (selectedItem != null);

                    return AlertDialog(
                      backgroundColor: AppTheme.cardBg,
                      title: const Text(
                        'PHIẾU NHẬP HÀNG MỚI',
                        style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                      ),
                      content: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Toggle nhập tự do
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Nhập sản phẩm tự do:', style: TextStyle(color: AppTheme.textMain, fontSize: 14)),
                                  Switch(
                                    value: isCustomProduct,
                                    activeColor: AppTheme.primaryGold,
                                    onChanged: (val) {
                                      setState(() {
                                        isCustomProduct = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (!isCustomProduct) ...[
                                // Dropdown chọn món
                                const Text('Đồ uống/Món ăn nhập:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                const SizedBox(height: 8),
                                items.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'Thực đơn trống. Vui lòng bật "Nhập sản phẩm tự do"!',
                                          style: TextStyle(color: AppTheme.accentNeonRed, fontSize: 12),
                                        ),
                                      )
                                    : DropdownButtonFormField<int>(
                                        value: selectedItem?.id,
                                        dropdownColor: AppTheme.cardBg,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: AppTheme.darkBg,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        style: const TextStyle(color: AppTheme.textMain),
                                        items: items.map((item) {
                                          return DropdownMenuItem<int>(
                                            value: item.id,
                                            child: Text('${item.name} (${item.unit})'),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedItem = items.firstWhere((i) => i.id == val);
                                          });
                                        },
                                      ),
                              ] else ...[
                                // Ô nhập tên tự do
                                TextFormField(
                                  controller: customNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tên sản phẩm nhập',
                                    labelStyle: TextStyle(color: AppTheme.textMuted),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderStroke)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
                                  ),
                                  style: const TextStyle(color: AppTheme.textMain),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Vui lòng nhập tên sản phẩm!';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Dropdown đơn vị tự do
                                const Text('Đơn vị tính:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: selectedCustomUnit,
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
                                  labelText: 'Số lượng nhập',
                                  labelStyle: TextStyle(color: AppTheme.textMuted),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderStroke)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
                                ),
                                style: const TextStyle(color: AppTheme.textMain),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập số lượng!';
                                  final qty = int.tryParse(val) ?? 0;
                                  if (qty <= 0) return 'Số lượng phải lớn hơn 0!';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Ô nhập giá nhập
                              TextFormField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Đơn giá nhập (đ)',
                                  labelStyle: TextStyle(color: AppTheme.textMuted),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderStroke)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
                                ),
                                style: const TextStyle(color: AppTheme.textMain),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập đơn giá!';
                                  final price = double.tryParse(val) ?? 0.0;
                                  if (price < 0) return 'Đơn giá không được âm!';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Ô ghi chú
                              TextFormField(
                                controller: noteController,
                                decoration: const InputDecoration(
                                  labelText: 'Ghi chú',
                                  labelStyle: TextStyle(color: AppTheme.textMuted),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderStroke)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
                                ),
                                style: const TextStyle(color: AppTheme.textMain),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('HỦY', style: TextStyle(color: AppTheme.textMuted)),
                        ),
                        if (canSubmit)
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final qty = int.parse(qtyController.text.trim());
                                final price = double.parse(priceController.text.trim());
                                final note = noteController.text.trim();

                                final itemId = isCustomProduct ? 0 : selectedItem!.id;
                                final itemName = isCustomProduct
                                    ? '${customNameController.text.trim()} ($selectedCustomUnit)'
                                    : selectedItem!.name;

                                await ref.read(stockActionsProvider.notifier).addStockIn(
                                      menuItemId: itemId,
                                      menuItemName: itemName,
                                      quantity: qty,
                                      price: price,
                                      note: note,
                                    );

                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            child: const Text('NHẬP HÀNG'),
                          ),
                      ],
                    );
                  },
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
                content: Text('Lỗi: $err', style: const TextStyle(color: AppTheme.accentNeonRed)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('HỦY', style: TextStyle(color: AppTheme.textMuted)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Xác nhận xóa phiếu nhập
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, StockTransactionEntity tx) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text('XÓA PHIẾU NHẬP?', style: TextStyle(color: AppTheme.accentNeonRed, fontWeight: FontWeight.bold)),
          content: Text(
            'Bạn chắc chắn muốn xóa phiếu nhập của "${tx.menuItemName}" số lượng ${tx.quantity} chứ? Tồn kho tương ứng sẽ bị giảm đi.',
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
                await ref.read(stockActionsProvider.notifier).deleteStockTransaction(tx.id);
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
