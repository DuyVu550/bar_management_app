import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/layout_providers.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final scaffoldKey = ref.watch(scaffoldKeyProvider);

    return Scaffold(
      key: scaffoldKey,
      drawer: isMobile
          ? const Drawer(
              backgroundColor: AppTheme.cardBg,
              child: SafeArea(
                child: SidebarContent(isDrawer: true),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: isCollapsed ? 70 : 260,
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border(
                  right: BorderSide(
                    color: AppTheme.borderStroke.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: const SidebarContent(isDrawer: false),
            ),
          Expanded(
            child: Container(
              color: AppTheme.darkBg,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarContent extends ConsumerWidget {
  final bool isDrawer;

  const SidebarContent({
    super.key,
    required this.isDrawer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    
    // Trích xuất path hiện tại của GoRouter để làm nổi bật item đang chọn
    final GoRouterState routerState = GoRouterState.of(context);
    final String currentPath = routerState.uri.path;

    final menuItems = [
      _MenuItem(
        title: 'Sơ đồ bàn',
        icon: Icons.table_restaurant_outlined,
        selectedIcon: Icons.table_restaurant,
        path: '/',
      ),
      _MenuItem(
        title: 'Quản lý Đơn vị',
        icon: Icons.straighten,
        selectedIcon: Icons.straighten,
        path: '/units',
      ),
      _MenuItem(
        title: 'Nhập hàng',
        icon: Icons.move_to_inbox_outlined,
        selectedIcon: Icons.move_to_inbox,
        path: '/stock-in',
      ),
      _MenuItem(
        title: 'Tiêu thụ',
        icon: Icons.shopping_bag_outlined,
        selectedIcon: Icons.shopping_bag,
        path: '/consumption',
      ),
      _MenuItem(
        title: 'Báo cáo kho',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        path: '/stock-manage',
      ),
      _MenuItem(
        title: 'Quản lý Nguyên liệu',
        icon: Icons.layers_outlined,
        selectedIcon: Icons.layers,
        path: '/ingredients-manage',
      ),
      _MenuItem(
        title: 'Quản lý Thực đơn',
        icon: Icons.restaurant_menu_outlined,
        selectedIcon: Icons.restaurant_menu,
        path: '/menu-manage',
      ),
      _MenuItem(
        title: 'Báo cáo tài chính',
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        path: '/report',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header logo
        Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: (isCollapsed && !isDrawer) ? 12 : 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!(isCollapsed && !isDrawer)) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_bar,
                    color: AppTheme.primaryGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'BAR MANAGER',
                    style: TextStyle(
                      color: AppTheme.primaryGold,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_bar,
                        color: AppTheme.primaryGold,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              // Nút Collapse/Expand trên Desktop
              if (!isDrawer && !isCollapsed)
                IconButton(
                  onPressed: () => ref.read(sidebarCollapsedProvider.notifier).state = true,
                  icon: const Icon(Icons.chevron_left, color: AppTheme.primaryGold, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Thu gọn menu',
                ),
              if (!isDrawer && isCollapsed)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () => ref.read(sidebarCollapsedProvider.notifier).state = false,
                      icon: const Icon(Icons.chevron_right, color: AppTheme.primaryGold, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Mở rộng menu',
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(color: AppTheme.borderStroke.withValues(alpha: 0.3), height: 1),
        const SizedBox(height: 12),
        // Menu list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isSelected = currentPath == item.path;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildMenuItemTile(context, item, isSelected, isCollapsed && !isDrawer),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemTile(BuildContext context, _MenuItem item, bool isSelected, bool collapsed) {
    const activeColor = AppTheme.primaryGold;
    const inactiveColor = AppTheme.textMuted;

    if (collapsed) {
      return Tooltip(
        message: item.title,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderStroke),
        ),
        textStyle: const TextStyle(color: AppTheme.textMain, fontSize: 12),
        margin: const EdgeInsets.only(left: 12),
        child: InkWell(
          onTap: () {
            if (isDrawer) Navigator.of(context).pop();
            context.go(item.path);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryGold.withValues(alpha: 0.15),
                        AppTheme.primaryGold.withValues(alpha: 0.02),
                      ],
                    )
                  : null,
            ),
            child: Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (isDrawer) Navigator.of(context).pop();
        context.go(item.path);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryGold.withValues(alpha: 0.12),
                    AppTheme.primaryGold.withValues(alpha: 0.02),
                  ],
                )
              : null,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppTheme.primaryGold, width: 3),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: isSelected ? AppTheme.textMain : inactiveColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  _MenuItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}
