import 'package:flutter_test/flutter_test.dart';
import 'package:bar_manager/features/table/domain/entities/table_entity.dart';
import 'package:bar_manager/features/menu/domain/entities/menu_item_entity.dart';

void main() {
  test('Kiểm tra TableEntity mapping hoạt động đúng', () {
    final table = TableEntity.fromSchemaName(1, 'Bàn 1', 'vacant');
    expect(table.id, equals(1));
    expect(table.name, equals('Bàn 1'));
    expect(table.status, equals(TableStatus.vacant));
  });

  test('Kiểm tra MenuItemEntity mapping hoạt động đúng', () {
    final item = MenuItemEntity.fromSchemaName(
      id: 1,
      name: 'Mojito 🍹',
      price: 85000.0,
      categoryStr: 'drink',
      isAvailable: true,
    );
    expect(item.id, equals(1));
    expect(item.name, equals('Mojito 🍹'));
    expect(item.price, equals(85000.0));
    expect(item.category, equals(MenuCategory.drink));
    expect(item.isAvailable, isTrue);
  });
}
