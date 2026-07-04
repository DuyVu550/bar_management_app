import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/entities/financial_report_entity.dart';
import '../../domain/entities/financial_item_entity.dart';
import '../providers/report_providers.dart';

class RevenueReportScreen extends ConsumerWidget {
  const RevenueReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BÁO CÁO CỬA HÀNG'),
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryGold,
            labelColor: AppTheme.primaryGold,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.receipt_long_outlined),
                text: 'DOANH THU NGÀY',
              ),
              Tab(
                icon: Icon(Icons.analytics_outlined),
                text: 'BÁO CÁO TÀI CHÍNH',
              ),
              Tab(icon: Icon(Icons.star_outline), text: 'BÁN CHẠY NHẤT'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DailyRevenueTab(),
            _FinancialReportTab(),
            _BestSellersTab(),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// TAB 1: DOANH THU HÀNG NGÀY / TUẦN (GIỮ NGUYÊN LOGIC CŨ)
// ==============================================================================
class _DailyRevenueTab extends ConsumerStatefulWidget {
  const _DailyRevenueTab();

  @override
  ConsumerState<_DailyRevenueTab> createState() => _DailyRevenueTabState();
}

class _DailyRevenueTabState extends ConsumerState<_DailyRevenueTab> {
  DateTime _selectedDate = DateTime.now();
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    final dailyRevenueAsync = ref.watch(
      dailyRevenueStateProvider(_selectedDate),
    );
    final weeklyReportAsync = ref.watch(weeklyRevenueReportProvider);

    return SingleChildScrollView(
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
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            ),
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
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            ),
            error: (err, stack) => Center(child: Text('Lỗi tải biểu đồ: $err')),
          ),
        ],
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
                const Text(
                  'Xem báo cáo ngày:',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  format.format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMain,
                  ),
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
                  colors: [
                    AppTheme.cardBg,
                    AppTheme.primaryGold.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: AppTheme.primaryGold,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Doanh thu',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _currencyFormat.format(revenue),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGold,
                      ),
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
                  colors: [
                    AppTheme.cardBg,
                    AppTheme.secondaryAmber.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: AppTheme.secondaryAmber,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tổng hóa đơn',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$ordersCount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryAmber,
                    ),
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
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
        final timeStr = order.completedAt != null
            ? DateFormat('HH:mm').format(order.completedAt!)
            : '--:--';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              'Hóa đơn #${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Thanh toán lúc: $timeStr',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            trailing: Text(
              _currencyFormat.format(order.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
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
          child: Center(
            child: Text(
              'Không có dữ liệu 7 ngày qua',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
        ),
      );
    }

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
              final height = ratio * 100 + 10;
              final dayOfWeek = DateFormat('E').format(day.date);
              final dayStr = DateFormat('dd/MM').format(day.date);

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    day.totalRevenue > 0
                        ? '${(day.totalRevenue / 1000).toStringAsFixed(0)}k'
                        : '',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.primaryGold,
                      fontWeight: FontWeight.w600,
                    ),
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
                          color: AppTheme.primaryGold.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayOfWeek,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dayStr,
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppTheme.textMuted,
                    ),
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
        title: Text(
          'CHI TIẾT HÓA ĐƠN #${order.id}',
          style: const TextStyle(color: AppTheme.primaryGold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return ListTile(
                title: Text(
                  item.menuItem.name,
                  style: const TextStyle(color: AppTheme.textMain),
                ),
                subtitle: item.note != null && item.note!.isNotEmpty
                    ? Text(
                        'Ghi chú: ${item.note}',
                        style: const TextStyle(
                          color: AppTheme.secondaryAmber,
                          fontSize: 11,
                        ),
                      )
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

// ==============================================================================
// TAB 2: BÁO CÁO TÀI CHÍNH THEO KHOẢNG THỜI GIAN TÙY Ý (MỚI)
// ==============================================================================
class _FinancialReportTab extends ConsumerStatefulWidget {
  const _FinancialReportTab();

  @override
  ConsumerState<_FinancialReportTab> createState() =>
      _FinancialReportTabState();
}

class _FinancialReportTabState extends ConsumerState<_FinancialReportTab> {
  late DateTime _startDate;
  late DateTime _endDate;
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
  }

  @override
  Widget build(BuildContext context) {
    final financialReportAsync = ref.watch(
      financialReportProvider(_startDate, _endDate),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bộ chọn khoảng ngày
          _buildDateRangePickerCard(context),
          const SizedBox(height: 20),

          // Kết quả báo cáo tài chính
          financialReportAsync.when(
            data: (report) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(report),
                const SizedBox(height: 24),
                const Text(
                  'CHI TIẾT THEO ĐỒ UỐNG',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDrinkStatsList(report.items),
              ],
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            ),
            error: (err, stack) => Center(child: Text('Lỗi: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePickerCard(BuildContext context) {
    final format = DateFormat('dd/MM/yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khoảng thời gian báo cáo:',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${format.format(_startDate)} - ${format.format(_endDate)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.date_range, size: 18),
              label: const Text('CHỌN KHOẢNG'),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  initialDateRange: DateTimeRange(
                    start: _startDate,
                    end: _endDate,
                  ),
                  firstDate: DateTime(2025),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    _startDate = picked.start;
                    _endDate = picked.end;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(FinancialReportEntity report) {
    final profitColor = report.totalProfit >= 0
        ? AppTheme.accentNeonGreen
        : AppTheme.accentNeonRed;
    final profitPrefix = report.totalProfit >= 0 ? '+' : '';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                title: 'Doanh thu',
                value: _currencyFormat.format(report.totalRevenue),
                icon: Icons.trending_up,
                iconColor: AppTheme.accentNeonGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniCard(
                title: 'Chi phí',
                value: _currencyFormat.format(report.totalCost),
                icon: Icons.trending_down,
                iconColor: AppTheme.accentNeonRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [AppTheme.cardBg, profitColor.withValues(alpha: 0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: profitColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: profitColor.withValues(alpha: 0.15),
                      child: Icon(
                        report.totalProfit >= 0
                            ? Icons.monetization_on
                            : Icons.money_off,
                        color: profitColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng Lợi nhuận',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$profitPrefix${_currencyFormat.format(report.totalProfit)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: profitColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: profitColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.totalProfit >= 0 ? 'CÓ LÃI' : 'LỖ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: profitColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppTheme.cardBg, iconColor.withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkStatsList(List<FinancialItemEntity> items) {
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Không có dữ liệu tài chính trong khoảng thời gian này',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final profitColor = item.profit >= 0
            ? AppTheme.accentNeonGreen
            : AppTheme.accentNeonRed;
        final profitPrefix = item.profit >= 0 ? '+' : '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên đồ uống & Lợi nhuận
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.menuItemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: profitColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$profitPrefix${_currencyFormat.format(item.profit)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppTheme.borderStroke, height: 1),
                const SizedBox(height: 12),

                // Chi tiết Doanh thu & Chi phí
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: AppTheme.accentNeonGreen,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Doanh thu',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${_currencyFormat.format(item.revenue)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.textMain,
                            ),
                          ),
                          Text(
                            'Đã bán: ${item.quantitySold}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 35,
                      color: AppTheme.borderStroke,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                color: AppTheme.accentNeonRed,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Chi phí nhập',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '-${_currencyFormat.format(item.cost)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.textMain,
                            ),
                          ),
                          Text(
                            'Đã nhập: ${item.quantityImported}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==============================================================================
// TAB 3: ĐỒ UỐNG BÁN CHẠY NHẤT (BEST SELLERS - REALTIME)
// ==============================================================================
class _BestSellersTab extends ConsumerWidget {
  const _BestSellersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestSellersAsync = ref.watch(bestSellersProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return bestSellersAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_outline, size: 80, color: AppTheme.textMuted),
                SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu bán chạy nhất',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final rank = index + 1;

            Widget rankWidget;
            Color? rankColor;
            if (rank == 1) {
              rankWidget = const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 28,
              );
              rankColor = Colors.amber.withValues(alpha: 0.08);
            } else if (rank == 2) {
              rankWidget = const Icon(
                Icons.emoji_events,
                color: Color(0xFFC0C0C0),
                size: 28,
              );
              rankColor = const Color(0xFFC0C0C0).withValues(alpha: 0.06);
            } else if (rank == 3) {
              rankWidget = const Icon(
                Icons.emoji_events,
                color: Color(0xFFCD7F32),
                size: 28,
              );
              rankColor = const Color(0xFFCD7F32).withValues(alpha: 0.04);
            } else {
              rankWidget = CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.borderStroke,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
                ),
              );
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: rankColor != null ? null : AppTheme.cardBg,
                  gradient: rankColor != null
                      ? LinearGradient(
                          colors: [AppTheme.cardBg, rankColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    rankWidget,
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.menuItemName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đã bán: ${item.quantitySold} sản phẩm',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Doanh thu',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(item.totalRevenue),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ],
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
          'Lỗi: $err',
          style: const TextStyle(color: AppTheme.accentNeonRed),
        ),
      ),
    );
  }
}
