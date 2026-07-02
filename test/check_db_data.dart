import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  final connectionString = "mongodb+srv://admin123:123456%40@cluster0.nddwu1x.mongodb.net/bar_manager?retryWrites=true&w=majority&tls=true";
  print('Connecting to MongoDB Atlas...');
  try {
    final db = await Db.create(connectionString);
    await db.open(secure: true);
    print('Connected successfully!');

    final stockTransactions = db.collection('stock_transactions');
    final all = await stockTransactions.find().toList();
    print('Transactions in database: ${all.length}');
    for (final doc in all) {
      print('Doc: $doc');
      try {
        print(' - id: ${doc['id']} (${doc['id'].runtimeType})');
        print(' - menuItemId: ${doc['menuItemId']} (${doc['menuItemId'].runtimeType})');
        print(' - price: ${doc['price']} (${doc['price'].runtimeType})');
        print(' - quantity: ${doc['quantity']} (${doc['quantity'].runtimeType})');
        print(' - date: ${doc['date']} (${doc['date'].runtimeType})');
      } catch (inner) {
        print('   Failed printing fields: $inner');
      }
    }

    await db.close();
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
