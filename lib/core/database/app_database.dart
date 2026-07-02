import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AppDatabase {
  late Db _db;
  bool _isConnected = false;

  // Stream Controllers để phát tín hiệu đồng bộ hóa reactive
  final _tableUpdateController = StreamController<void>.broadcast();
  final _menuUpdateController = StreamController<void>.broadcast();
  final _orderUpdateController = StreamController<void>.broadcast();
  final _unitUpdateController = StreamController<void>.broadcast();
  final _stockUpdateController = StreamController<void>.broadcast();

  Stream<void> get tableUpdates => _tableUpdateController.stream;
  Stream<void> get menuUpdates => _menuUpdateController.stream;
  Stream<void> get orderUpdates => _orderUpdateController.stream;
  Stream<void> get unitUpdates => _unitUpdateController.stream;
  Stream<void> get stockUpdates => _stockUpdateController.stream;

  void notifyTableChanged() => _tableUpdateController.add(null);
  void notifyMenuChanged() => _menuUpdateController.add(null);
  void notifyOrderChanged() => _orderUpdateController.add(null);
  void notifyUnitChanged() => _unitUpdateController.add(null);
  void notifyStockChanged() => _stockUpdateController.add(null);

  Db get db => _db;

  Future<void> connect() async {
    if (_isConnected) return;
    
    // Đọc chuỗi kết nối từ file cấu hình .env bảo mật
    final connectionString = dotenv.env['MONGODB_URI'] ?? "";
    if (connectionString.isEmpty) {
      throw Exception("Lỗi: MONGODB_URI không tồn tại hoặc bị trống trong file .env!");
    }

    _db = await Db.create(connectionString);
    await _db.open(secure: true);
    _isConnected = true;

    // Seed dữ liệu mẫu nếu database đang trống
    await _seedDataIfNeeded();
  }

  Future<void> ensureConnected() async {
    if (!_isConnected || !_db.isConnected) {
      _isConnected = false;
      await connect();
    }
  }

  Future<void> close() async {
    if (_isConnected) {
      await _db.close();
      _isConnected = false;
    }
    await _tableUpdateController.close();
    await _menuUpdateController.close();
    await _orderUpdateController.close();
    await _unitUpdateController.close();
    await _stockUpdateController.close();
  }

  // Truy cập các Collections trong MongoDB
  DbCollection get tables => _db.collection('tables');
  DbCollection get menuItems => _db.collection('menu_items');
  DbCollection get orders => _db.collection('orders');
  DbCollection get units => _db.collection('units');
  DbCollection get stockTransactions => _db.collection('stock_transactions');

  // Hàm sinh mã ID dạng số tự động tăng đơn giản
  Future<int> getNextId(String collectionName) async {
    final collection = _db.collection(collectionName);
    final result = await collection.find(
      where.sortBy('id', descending: true).limit(1)
    ).toList();
    if (result.isEmpty) return 1;
    return (result.first['id'] as int) + 1;
  }

  Future<void> _seedDataIfNeeded() async {
    // 1. Seed Bàn
    final tableCount = await tables.count();
    if (tableCount == 0) {
      await tables.insertAll([
        {'id': 1, 'name': 'Bàn 1', 'status': 'vacant'},
        {'id': 2, 'name': 'Bàn 2', 'status': 'vacant'},
        {'id': 3, 'name': 'Bàn 3', 'status': 'vacant'},
        {'id': 4, 'name': 'Bàn VIP 1', 'status': 'vacant'},
        {'id': 5, 'name': 'Bàn VIP 2', 'status': 'vacant'},
      ]);
      notifyTableChanged();
    }

    // 2. Seed Món trong Menu
    final menuCount = await menuItems.count();
    if (menuCount == 0) {
      await menuItems.insertAll([
        {
          'id': 1,
          'name': 'Mojito Cocktail 🍹',
          'price': 85000.0,
          'category': 'drink',
          'isAvailable': true
        },
        {
          'id': 2,
          'name': 'Whisky Sour 🥃',
          'price': 120000.0,
          'category': 'drink',
          'isAvailable': true
        },
        {
          'id': 3,
          'name': 'Heineken Beer 🍺',
          'price': 45000.0,
          'category': 'drink',
          'isAvailable': true
        },
        {
          'id': 4,
          'name': 'Beef Steak 🥩',
          'price': 180000.0,
          'category': 'food',
          'isAvailable': true
        },
        {
          'id': 5,
          'name': 'French Fries 🍟',
          'price': 50000.0,
          'category': 'snack',
          'isAvailable': true
        },
        {
          'id': 6,
          'name': 'Grilled Octopus 🐙',
          'price': 150000.0,
          'category': 'food',
          'isAvailable': true
        },
        {
          'id': 7,
          'name': 'Mixed Nuts 🥜',
          'price': 35000.0,
          'category': 'snack',
          'isAvailable': true
        },
      ]);
      notifyMenuChanged();
    }

    // 3. Seed Đơn vị mẫu (Units)
    final unitCount = await units.count();
    if (unitCount == 0) {
      await units.insertAll([
        {'id': 1, 'name': 'Chai'},
        {'id': 2, 'name': 'Lon'},
        {'id': 3, 'name': 'Ly'},
        {'id': 4, 'name': 'Đĩa'},
        {'id': 5, 'name': 'Phần'},
      ]);
      notifyUnitChanged();
    }
  }
}
