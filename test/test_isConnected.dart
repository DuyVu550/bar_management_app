import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  final connectionString = "mongodb+srv://admin123:123456%40@cluster0.nddwu1x.mongodb.net/bar_manager?retryWrites=true&w=majority&tls=true";
  try {
    final db = await Db.create(connectionString);
    print('Before open: isConnected = ${db.isConnected}');
    await db.open(secure: true);
    print('After open: isConnected = ${db.isConnected}');
    await db.close();
    print('After close: isConnected = ${db.isConnected}');
  } catch (e) {
    print('Error: $e');
  }
}
