import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../providers/report_providers.dart';

class RevenueReportScreen extends ConsumerStatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  ConsumerState<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends ConsumerState<RevenueReportScreen> {
  DateTime _selectedDate = DateTime.now();
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    final dailyRevenueAsync = ref.watch(dailyRevenueStateProvider(_selectedDate));
    final weeklyReportAsync = ref.watch(weeklyRevenueReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BÁO CÁO DOANH THU'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bộ chọn ngày
            _buildDatePickerCard(context),
            const SizedBox(height: 20),

            // Kết quả doanh thu ngày đã chọn
            dailyRevenueAsync.when(
              data: (report) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(report.totalRevenue, report.totalOrders),
                  const SizedBox(height: 24),
                  const Text(
                    'LỊCH SỬ HÓA ĐƠN TRONG NGÀY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOrderList(report.orders),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),

            const SizedBox(height: 28),
            const Text(
              'BIỂU ĐỒ DOANH THU 7 NGÀY GẦN NHẤT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Biểu đồ doanh thu tuần qua
            weeklyReportAsync.when(
              data: (weeklyData) => _buildWeeklyChart(weeklyData),
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
              error: (err, stack) => Center(child: Text('Lỗi tải biểu đồ: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerCard(BuildContext context) {
    final format = DateFormat('dd/MM/yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Xem báo cáo ngày:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  format.format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: const Text('CHỌN NGÀY'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppTheme.primaryGold,
                          onPrimary: AppTheme.darkBg,
                          surface: AppTheme.cardBg,
                          onSurface: AppTheme.textMain,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double revenue, int ordersCount) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [AppTheme.cardBg, AppTheme.primaryGold.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.attach_money, color: AppTheme.primaryGold, size: 28),
                  const SizedBox(height: 12),
                  const Text('Doanh thu', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _currencyFormat.format(revenue),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [AppTheme.cardBg, AppTheme.secondaryAmber.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.receipt_long, color: AppTheme.secondaryAmber, size: 28),
                  const SizedBox(height: 12),
                  const Text('Tổng hóa đơn', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '$ordersCount',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondaryAmber),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderList(List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Chưa có doanh thu trong ngày này',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final timeStr = order.completedAt != null ? DateFormat('HH:mm').format(order.completedAt!) : '--:--';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('Hóa đơn #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Thanh toán lúc: $timeStr', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            trailing: Text(
              _currencyFormat.format(order.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
            ),
            onTap: () => _showOrderDetailsDialog(context, order),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyChart(List<dynamic> weeklyData) {
    if (weeklyData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('Không có dữ liệu 7 ngày qua', style: TextStyle(color: AppTheme.textMuted))),
        ),
      );
    }

    // Tìm doanh thu lớn nhất để tính tỉ lệ chiều cao cột
    double maxRevenue = 1.0;
    for (final day in weeklyData) {
      if (day.totalRevenue > maxRevenue) maxRevenue = day.totalRevenue;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 160,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyData.map<Widget>((day) {
              final ratio = day.totalRevenue / maxRevenue;
              final height = ratio * 100 + 10; // Giới hạn từ 10px tới 110px
              final dayOfWeek = DateFormat('E').format(day.date); // Thứ
              final dayStr = DateFormat('dd/MM').format(day.date);

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    day.totalRevenue > 0 ? '${(day.totalRevenue / 1000).toStringAsFixed(0)}k' : '',
                    style: const TextStyle(fontSize: 9, color: AppTheme.primaryGold, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.secondaryAmber, AppTheme.primaryGold],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, -1),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayOfWeek,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMain, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    dayStr,
                    style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('CHI TIẾT HÓA ĐƠN #${order.id}', style: const TextStyle(color: AppTheme.primaryGold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return ListTile(
                title: Text(item.menuItem.name, style: const TextStyle(color: AppTheme.textMain)),
                subtitle: item.note != null && item.note!.isNotEmpty
                    ? Text('Ghi chú: ${item.note}', style: const TextStyle(color: AppTheme.secondaryAmber, fontSize: 11))
                    : null,
                trailing: Text(
                  '${item.quantity} x ${_currencyFormat.format(item.priceAtOrder)}',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
