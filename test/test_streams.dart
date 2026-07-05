// ignore_for_file: avoid_print
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  const connectionString = "mongodb+srv://admin123:123456%40@cluster0.nddwu1x.mongodb.net/bar_manager?retryWrites=true&w=majority&tls=true";
  print('Connecting to MongoDB Atlas...');
  try {
    final db = await Db.create(connectionString);
    await db.open(secure: true);
    print('Connected successfully!');

    final stockTransactions = db.collection('stock_transactions');
    final menuItems = db.collection('menu_items');

    print('Fetching stock transactions...');
    final txList = await stockTransactions.find(where.eq('type', 'in').sortBy('date', descending: true)).toList();
    print('Stock In transactions: ${txList.length}');
    for (final tx in txList) {
      print('Tx: ${tx['menuItemName']} - Qty: ${tx['quantity']} - Price: ${tx['price']} - Date: ${tx['date']}');
    }

    print('Fetching menu items...');
    final itemList = await menuItems.find(where.sortBy('id')).toList();
    print('Menu items: ${itemList.length}');
    for (final item in itemList) {
      print('Item: ${item['name']} - Stock: ${item['stock']} - Unit: ${item['unit']}');
    }

    await db.close();
    print('Done successfully without errors!');
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
