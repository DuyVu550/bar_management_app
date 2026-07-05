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

    print('Fetching first menu item...');
    final item = await menuItems.findOne();
    if (item == null) {
      print('No menu items found. Please add a menu item first.');
      await db.close();
      return;
    }
    print('Found item: ${item['name']} (ID: ${item['id']})');

    print('Getting next ID for stock_transactions...');
    final result = await stockTransactions.find(
      where.sortBy('id', descending: true).limit(1)
    ).toList();
    int nextId = 1;
    if (result.isNotEmpty) {
      nextId = (result.first['id'] as int) + 1;
    }
    print('Next ID: $nextId');

    print('Inserting transaction...');
    await stockTransactions.insert({
      'id': nextId,
      'menuItemId': item['id'],
      'menuItemName': item['name'],
      'type': 'in',
      'quantity': 10,
      'price': 15000.0,
      'date': DateTime.now().toIso8601String(),
      'note': 'Test stock in script',
    });
    print('Inserted transaction successfully!');

    print('Updating menu item stock...');
    final currentStock = item['stock'] as int? ?? 0;
    await menuItems.updateOne(
      where.eq('id', item['id']),
      modify.set('stock', currentStock + 10),
    );
    print('Updated menu item stock successfully!');

    await db.close();
    print('DB connection closed successfully!');
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
