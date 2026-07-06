import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider quản lý ScaffoldState GlobalKey để các màn hình con có thể mở Drawer
final scaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});

// Provider quản lý trạng thái thu gọn (collapsed) của Sidebar trên màn hình Desktop
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
