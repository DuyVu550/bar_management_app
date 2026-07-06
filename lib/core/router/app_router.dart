import 'package:go_router/go_router.dart';
import '../../features/table/presentation/screens/table_grid_screen.dart';
import '../../features/order/presentation/screens/order_detail_screen.dart';
import '../../features/menu/presentation/screens/menu_management_screen.dart';
import '../../features/menu/presentation/screens/ingredient_management_screen.dart';
import '../../features/report/presentation/screens/revenue_report_screen.dart';
import '../../features/unit/presentation/screens/unit_management_screen.dart';
import '../../features/stock/presentation/screens/stock_in_screen.dart';
import '../../features/stock/presentation/screens/consumption_screen.dart';
import '../../features/stock/presentation/screens/stock_management_screen.dart';

import '../widgets/main_layout.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ShellRoute bọc các màn hình chính để giữ Menu Sidebar cố định bên trái
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TableGridScreen(),
        ),
        GoRoute(
          path: '/menu-manage',
          builder: (context, state) => const MenuManagementScreen(),
        ),
        GoRoute(
          path: '/ingredients-manage',
          builder: (context, state) => const IngredientManagementScreen(),
        ),
        GoRoute(
          path: '/report',
          builder: (context, state) => const RevenueReportScreen(),
        ),
        GoRoute(
          path: '/units',
          builder: (context, state) => const UnitManagementScreen(),
        ),
        GoRoute(
          path: '/stock-in',
          builder: (context, state) => const StockInScreen(),
        ),
        GoRoute(
          path: '/consumption',
          builder: (context, state) => const ConsumptionScreen(),
        ),
        GoRoute(
          path: '/stock-manage',
          builder: (context, state) => const StockManagementScreen(),
        ),
      ],
    ),
    // Màn hình chi tiết bàn (gọi món) hiển thị tràn màn hình (Fullscreen) không chứa sidebar
    GoRoute(
      path: '/table/:id',
      builder: (context, state) {
        final tableIdStr = state.pathParameters['id'];
        final tableName = state.uri.queryParameters['name'] ?? 'Bàn';
        final tableId = int.tryParse(tableIdStr ?? '') ?? 0;
        return OrderDetailScreen(tableId: tableId, tableName: tableName);
      },
    ),
  ],
);

