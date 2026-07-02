import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  // Sẽ được override trong main.dart sau khi đã kết nối thành công tới MongoDB
  throw UnimplementedError('databaseProvider must be overridden in main()');
});
