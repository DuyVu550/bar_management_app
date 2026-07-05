import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class AppDatabase {
  late Dio _dio;
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

  Dio get dio => _dio;

  Future<void> connect() async {
    if (_isConnected) return;
    
    String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (!origin.contains('localhost') && !origin.contains('127.0.0.1')) {
        apiUrl = origin;
      }
    }
    
    _dio = Dio(BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _isConnected = true;
  }

  Future<void> ensureConnected() async {
    await connect();
  }

  Future<void> close() async {
    await _tableUpdateController.close();
    await _menuUpdateController.close();
    await _orderUpdateController.close();
    await _unitUpdateController.close();
    await _stockUpdateController.close();
  }
}
