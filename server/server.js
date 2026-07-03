const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;
const mongoUri = process.env.MONGODB_URI;

app.use(cors());
app.use(express.json());

let db;
let client;

// Kết nối cơ sở dữ liệu MongoDB
async function connectDb() {
  try {
    client = new MongoClient(mongoUri);
    await client.connect();
    db = client.db();
    console.log('Đã kết nối thành công tới MongoDB Atlas!');
  } catch (error) {
    console.error('Kết nối tới MongoDB thất bại:', error);
    process.exit(1);
  }
}

// Helper sinh ID tự động tăng
async function getNextId(collectionName) {
  const collection = db.collection(collectionName);
  const result = await collection.find({}).sort({ id: -1 }).limit(1).toArray();
  if (result.length === 0) return 1;
  return (result[0].id || 0) + 1;
}

// -----------------------------------------------------------------------------
// ENDPOINTS QUẢN LÝ BÀN (TABLES)
// -----------------------------------------------------------------------------

// Lấy danh sách bàn
app.get('/api/tables', async (req, res) => {
  try {
    const list = await db.collection('tables').find({}).sort({ id: 1 }).toArray();
    res.json(list);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Thêm bàn mới
app.post('/api/tables', async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ error: 'Tên bàn không được trống' });
    
    // Kiểm tra trùng tên bàn (không phân biệt hoa thường)
    const existing = await db.collection('tables').findOne({ 
      name: { $regex: new RegExp(`^${name.trim()}$`, 'i') } 
    });
    if (existing) {
      return res.status(400).json({ error: 'Tên bàn đã tồn tại trong sơ đồ!' });
    }

    const nextId = await getNextId('tables');
    const newTable = {
      id: nextId,
      name: name.trim(),
      status: 'vacant'
    };
    await db.collection('tables').insertOne(newTable);
    res.json(newTable);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cập nhật thông tin bàn (tên, trạng thái)
app.put('/api/tables/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { name, status } = req.body;
    
    const updateDoc = {};
    if (status !== undefined) updateDoc.status = status;
    
    if (name !== undefined) {
      const trimmedName = name.trim();
      if (!trimmedName) return res.status(400).json({ error: 'Tên bàn không được trống' });
      
      // Kiểm tra trùng tên bàn (trừ chính bàn đó ra)
      const existing = await db.collection('tables').findOne({ 
        name: { $regex: new RegExp(`^${trimmedName}$`, 'i') },
        id: { $ne: id }
      });
      if (existing) {
        return res.status(400).json({ error: 'Tên bàn đã tồn tại trong sơ đồ!' });
      }
      updateDoc.name = trimmedName;
    }

    await db.collection('tables').updateOne({ id }, { $set: updateDoc });
    res.json({ message: 'Cập nhật bàn thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cập nhật trạng thái bàn (giữ nguyên để tránh break các chỗ cũ gọi)
app.put('/api/tables/:id/status', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { status } = req.body;
    await db.collection('tables').updateOne({ id }, { $set: { status } });
    res.json({ message: 'Cập nhật trạng thái bàn thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Xóa bàn
app.delete('/api/tables/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const table = await db.collection('tables').findOne({ id });
    if (!table) return res.status(404).json({ error: 'Không tìm thấy bàn' });
    if (table.status !== 'vacant') {
      return res.status(400).json({ error: 'Không thể xóa bàn đang có khách!' });
    }
    await db.collection('tables').deleteOne({ id });
    res.json({ message: 'Xóa bàn thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------------------------------
// ENDPOINTS QUẢN LÝ ĐỒ UỐNG / MÓN ĂN (MENU ITEMS)
// -----------------------------------------------------------------------------

// Lấy danh sách món ăn/uống
app.get('/api/menu-items', async (req, res) => {
  try {
    const list = await db.collection('menu_items').find({}).sort({ id: 1 }).toArray();
    res.json(list);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Thêm món ăn/uống
app.post('/api/menu-items', async (req, res) => {
  try {
    const { name, price, category, unit } = req.body;
    const nextId = await getNextId('menu_items');
    const newItem = {
      id: nextId,
      name,
      price: parseFloat(price),
      category,
      isAvailable: true,
      unit: unit || 'Chai',
      stock: 0
    };
    await db.collection('menu_items').insertOne(newItem);
    res.json(newItem);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cập nhật món ăn/uống
app.put('/api/menu-items/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { name, price, category, isAvailable, unit, stock } = req.body;
    const updateDoc = {};
    if (name !== undefined) updateDoc.name = name;
    if (price !== undefined) updateDoc.price = parseFloat(price);
    if (category !== undefined) updateDoc.category = category;
    if (isAvailable !== undefined) updateDoc.isAvailable = isAvailable;
    if (unit !== undefined) updateDoc.unit = unit;
    if (stock !== undefined) updateDoc.stock = parseInt(stock);

    await db.collection('menu_items').updateOne({ id }, { $set: updateDoc });
    res.json({ message: 'Cập nhật món thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Xóa một món
app.delete('/api/menu-items/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    await db.collection('menu_items').deleteOne({ id });
    res.json({ message: 'Xóa món thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Xóa tất cả các món
app.delete('/api/menu-items', async (req, res) => {
  try {
    const { excludeIngredients, category } = req.query;
    let filter = {};
    if (excludeIngredients === 'true') {
      filter = { category: { $ne: 'ingredient' } };
    } else if (category) {
      filter = { category };
    }
    await db.collection('menu_items').deleteMany(filter);
    res.json({ message: 'Xóa các món thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------------------------------
// ENDPOINTS QUẢN LÝ ĐƠN VỊ TÍNH (UNITS)
// -----------------------------------------------------------------------------

// Lấy danh sách đơn vị tính
app.get('/api/units', async (req, res) => {
  try {
    const list = await db.collection('units').find({}).sort({ id: 1 }).toArray();
    res.json(list);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Thêm đơn vị tính
app.post('/api/units', async (req, res) => {
  try {
    const { name } = req.body;
    const nextId = await getNextId('units');
    const newUnit = { id: nextId, name };
    await db.collection('units').insertOne(newUnit);
    res.json(newUnit);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cập nhật đơn vị tính
app.put('/api/units/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { name } = req.body;
    await db.collection('units').updateOne({ id }, { $set: { name } });
    res.json({ message: 'Cập nhật đơn vị tính thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Xóa một đơn vị tính
app.delete('/api/units/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    await db.collection('units').deleteOne({ id });
    res.json({ message: 'Xóa đơn vị tính thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Xóa tất cả đơn vị tính
app.delete('/api/units', async (req, res) => {
  try {
    await db.collection('units').deleteMany({});
    res.json({ message: 'Xóa tất cả đơn vị tính thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------------------------------
// ENDPOINTS QUẢN LÝ GIAO DỊCH KHO (STOCK TRANSACTIONS)
// -----------------------------------------------------------------------------

// Lấy danh sách giao dịch kho (lọc theo type nếu có)
app.get('/api/stock-transactions', async (req, res) => {
  try {
    const { type } = req.query;
    const filter = type ? { type } : {};
    const list = await db.collection('stock_transactions').find(filter).sort({ date: -1 }).toArray();
    res.json(list);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Thêm giao dịch kho mới (Nhập kho / Tiêu thụ trực tiếp)
app.post('/api/stock-transactions', async (req, res) => {
  try {
    const { menuItemId, menuItemName, type, quantity, price, note } = req.body;
    const nextId = await getNextId('stock_transactions');
    const now = new Date();
    const newTx = {
      id: nextId,
      menuItemId: parseInt(menuItemId),
      menuItemName,
      type, // 'in' hoặc 'out'
      quantity: parseInt(quantity),
      price: parseFloat(price),
      date: now.toISOString(),
      note: note || ''
    };
    await db.collection('stock_transactions').insertOne(newTx);

    // Cập nhật số lượng tồn kho của món ăn/uống tương ứng
    if (newTx.menuItemId > 0) {
      const item = await db.collection('menu_items').findOne({ id: newTx.menuItemId });
      if (item) {
        const currentStock = item.stock || 0;
        const newStock = type === 'in' ? currentStock + newTx.quantity : currentStock - newTx.quantity;
        await db.collection('menu_items').updateOne({ id: newTx.menuItemId }, { $set: { stock: newStock } });
      }
    }

    res.json(newTx);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Xóa giao dịch kho (Hủy bỏ ảnh hưởng lên tồn kho)
app.delete('/api/stock-transactions/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const tx = await db.collection('stock_transactions').findOne({ id });
    if (tx) {
      if (tx.menuItemId > 0) {
        const item = await db.collection('menu_items').findOne({ id: tx.menuItemId });
        if (item) {
          const currentStock = item.stock || 0;
          const newStock = tx.type === 'in' ? currentStock - tx.quantity : currentStock + tx.quantity;
          await db.collection('menu_items').updateOne({ id: tx.menuItemId }, { $set: { stock: newStock } });
        }
      }
      await db.collection('stock_transactions').deleteOne({ id });
      res.json({ message: 'Xóa giao dịch kho thành công và đã hoàn trả tồn kho' });
    } else {
      res.status(404).json({ error: 'Không tìm thấy giao dịch' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------------------------------
// ENDPOINTS QUẢN LÝ HÓA ĐƠN / ĐẶT MÓN (ORDERS)
// -----------------------------------------------------------------------------

// Lấy hóa đơn đang hoạt động của bàn
app.get('/api/orders/active/:tableId', async (req, res) => {
  try {
    const tableId = parseInt(req.params.tableId);
    const order = await db.collection('orders').findOne({ tableId, status: 'active' });
    if (!order) return res.status(404).json({ message: 'Không có hóa đơn hoạt động cho bàn này' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Tạo hóa đơn mới cho bàn (Bắt đầu ăn uống)
app.post('/api/orders', async (req, res) => {
  try {
    const { tableId } = req.body;
    const tId = parseInt(tableId);

    // Kiểm tra xem đã có hóa đơn active chưa
    const existing = await db.collection('orders').findOne({ tableId: tId, status: 'active' });
    if (existing) return res.json(existing);

    const nextId = await getNextId('orders');
    const now = new Date();
    const newOrder = {
      id: nextId,
      tableId: tId,
      status: 'active',
      totalAmount: 0.0,
      items: [],
      createdAt: now.toISOString(),
      completedAt: null
    };
    await db.collection('orders').insertOne(newOrder);

    // Chuyển trạng thái bàn thành 'occupied' (có khách)
    await db.collection('tables').updateOne({ id: tId }, { $set: { status: 'occupied' } });

    res.json(newOrder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Thêm món vào hóa đơn
app.post('/api/orders/:orderId/items', async (req, res) => {
  try {
    const orderId = parseInt(req.params.orderId);
    let { menuItem, menuItemId, quantity, priceAtOrder, note } = req.body;

    const order = await db.collection('orders').findOne({ id: orderId });
    if (!order) return res.status(404).json({ error: 'Không tìm thấy hóa đơn' });

    if (!menuItem && menuItemId) {
      menuItem = await db.collection('menu_items').findOne({ id: parseInt(menuItemId) });
    }
    if (!menuItem) return res.status(400).json({ error: 'Không tìm thấy món ăn/đồ uống tương ứng' });

    // Tạo ID tự động tăng cho order_item
    let maxItemId = 0;
    if (order.items && order.items.length > 0) {
      maxItemId = Math.max(...order.items.map(i => i.id));
    }
    const newItemId = maxItemId + 1;

    const newItem = {
      id: newItemId,
      orderId,
      menuItem,
      quantity: parseInt(quantity),
      priceAtOrder: parseFloat(priceAtOrder),
      note: note || ''
    };

    const newItems = [...(order.items || []), newItem];
    const newTotal = newItems.reduce((sum, item) => sum + (item.quantity * item.priceAtOrder), 0.0);

    // Trừ số lượng tồn kho của món ăn/uống (chỉ áp dụng cho nguyên liệu)
    const item = await db.collection('menu_items').findOne({ id: menuItem.id });
    if (item && item.category === 'ingredient') {
      const currentStock = item.stock || 0;
      const newStock = currentStock - newItem.quantity;
      await db.collection('menu_items').updateOne({ id: menuItem.id }, { $set: { stock: newStock } });
    }

    await db.collection('orders').updateOne(
      { id: orderId },
      { $set: { items: newItems, totalAmount: newTotal } }
    );

    res.json(newItem);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cập nhật số lượng món trong hóa đơn theo itemId
app.put('/api/orders/items/:itemId', async (req, res) => {
  try {
    const itemId = parseInt(req.params.itemId);
    const { quantity } = req.body;
    const newQty = parseInt(quantity);

    const order = await db.collection('orders').findOne({ 'items.id': itemId });
    if (!order) return res.status(404).json({ error: 'Không tìm thấy hóa đơn chứa món ăn này' });

    let diffQty = 0;
    let targetMenuItemId = 0;

    const newItems = order.items.map(item => {
      if (item.id === itemId) {
        diffQty = newQty - item.quantity; // Số lượng tăng lên (+), hoặc giảm đi (-)
        targetMenuItemId = item.menuItem.id;
        return { ...item, quantity: newQty };
      }
      return item;
    });

    const newTotal = newItems.reduce((sum, item) => sum + (item.quantity * item.priceAtOrder), 0.0);

    // Cập nhật lại tồn kho của món ăn/uống (chỉ áp dụng cho nguyên liệu)
    if (targetMenuItemId > 0 && diffQty !== 0) {
      const item = await db.collection('menu_items').findOne({ id: targetMenuItemId });
      if (item && item.category === 'ingredient') {
        const currentStock = item.stock || 0;
        const newStock = currentStock - diffQty; // Nếu bán thêm thì trừ đi, nếu giảm bớt thì cộng trả lại
        await db.collection('menu_items').updateOne({ id: targetMenuItemId }, { $set: { stock: newStock } });
      }
    }

    await db.collection('orders').updateOne(
      { id: order.id },
      { $set: { items: newItems, totalAmount: newTotal } }
    );

    res.json({ message: 'Cập nhật số lượng món thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Xóa món khỏi hóa đơn theo itemId
app.delete('/api/orders/items/:itemId', async (req, res) => {
  try {
    const itemId = parseInt(req.params.itemId);

    const order = await db.collection('orders').findOne({ 'items.id': itemId });
    if (!order) return res.status(404).json({ error: 'Không tìm thấy hóa đơn chứa món ăn này' });

    const itemToDelete = order.items.find(i => i.id === itemId);
    if (!itemToDelete) return res.status(404).json({ error: 'Không tìm thấy món ăn trong hóa đơn' });

    // Trả lại số lượng tồn kho của món ăn/uống (chỉ áp dụng cho nguyên liệu)
    const item = await db.collection('menu_items').findOne({ id: itemToDelete.menuItem.id });
    if (item && item.category === 'ingredient') {
      const currentStock = item.stock || 0;
      const newStock = currentStock + itemToDelete.quantity;
      await db.collection('menu_items').updateOne({ id: itemToDelete.menuItem.id }, { $set: { stock: newStock } });
    }

    const newItems = order.items.filter(i => i.id !== itemId);
    const newTotal = newItems.reduce((sum, item) => sum + (item.quantity * item.priceAtOrder), 0.0);

    await db.collection('orders').updateOne(
      { id: order.id },
      { $set: { items: newItems, totalAmount: newTotal } }
    );

    res.json({ message: 'Xóa món khỏi hóa đơn thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Thanh toán hóa đơn (Checkout)
app.post('/api/orders/:orderId/checkout', async (req, res) => {
  try {
    const orderId = parseInt(req.params.orderId);
    const now = new Date();

    const order = await db.collection('orders').findOne({ id: orderId });
    if (!order) return res.status(404).json({ error: 'Không tìm thấy hóa đơn' });

    await db.collection('orders').updateOne(
      { id: orderId },
      { $set: { status: 'completed', completedAt: now.toISOString() } }
    );

    // Chuyển trạng thái bàn thành 'vacant' (trống)
    await db.collection('tables').updateOne({ id: order.tableId }, { $set: { status: 'vacant' } });

    res.json({ message: 'Thanh toán thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Hủy hóa đơn
app.post('/api/orders/:orderId/cancel', async (req, res) => {
  try {
    const orderId = parseInt(req.params.orderId);

    const order = await db.collection('orders').findOne({ id: orderId });
    if (!order) return res.status(404).json({ error: 'Không tìm thấy hóa đơn' });

    // Trả lại số lượng tồn kho cho toàn bộ món ăn trong hóa đơn bị hủy (chỉ áp dụng cho nguyên liệu)
    for (const itemToDelete of (order.items || [])) {
      const item = await db.collection('menu_items').findOne({ id: itemToDelete.menuItem.id });
      if (item && item.category === 'ingredient') {
        const currentStock = item.stock || 0;
        const newStock = currentStock + itemToDelete.quantity;
        await db.collection('menu_items').updateOne({ id: itemToDelete.menuItem.id }, { $set: { stock: newStock } });
      }
    }

    await db.collection('orders').updateOne(
      { id: orderId },
      { $set: { status: 'cancelled' } }
    );

    // Chuyển trạng thái bàn thành 'vacant' (trống)
    await db.collection('tables').updateOne({ id: order.tableId }, { $set: { status: 'vacant' } });

    res.json({ message: 'Hủy hóa đơn thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------------------------------
// ENDPOINTS BÁO CÁO (REPORTS)
// -----------------------------------------------------------------------------

// Báo cáo doanh thu ngày
app.get('/api/reports/daily', async (req, res) => {
  try {
    const { date } = req.query; // YYYY-MM-DD
    const targetDate = date ? new Date(date) : new Date();
    
    const startOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate()).toISOString();
    const endOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(), 23, 59, 59, 999).toISOString();

    const orders = await db.collection('orders').find({
      status: 'completed',
      completedAt: { $gte: startOfDay, $lte: endOfDay }
    }).toArray();

    const totalRevenue = orders.reduce((sum, o) => sum + o.totalAmount, 0.0);

    res.json({
      date: targetDate.toISOString(),
      totalRevenue,
      totalOrders: orders.length,
      orders
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Báo cáo doanh thu theo khoảng thời gian gom nhóm theo ngày
app.get('/api/reports/range', async (req, res) => {
  try {
    const { start, end } = req.query;
    if (!start || !end) return res.status(400).json({ error: 'Thiếu tham số start hoặc end' });

    const orders = await db.collection('orders').find({
      status: 'completed',
      completedAt: { $gte: start, $lte: end }
    }).toArray();

    const grouped = {};
    for (const row of orders) {
      const completedAt = new Date(row.completedAt);
      const dateKey = `${completedAt.getFullYear()}-${completedAt.getMonth() + 1}-${completedAt.getDate()}`;
      if (!grouped[dateKey]) grouped[dateKey] = [];
      grouped[dateKey].push(row);
    }

    const reports = [];
    for (const [dateKey, list] of Object.entries(grouped)) {
      const parts = dateKey.split('-');
      const date = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
      const total = list.reduce((sum, o) => sum + o.totalAmount, 0.0);
      
      reports.push({
        date: date.toISOString(),
        totalRevenue: total,
        totalOrders: list.length,
        orders: list
      });
    }

    reports.sort((a, b) => new Date(a.date) - new Date(b.date));
    res.json(reports);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Báo cáo tài chính chi tiết (Doanh thu, Chi phí, Lợi nhuận) từng món đồ uống
app.get('/api/reports/financial', async (req, res) => {
  try {
    const { start, end } = req.query;
    if (!start || !end) return res.status(400).json({ error: 'Thiếu tham số start hoặc end' });

    // 1. Lấy tất cả hóa đơn hoàn thành trong khoảng thời gian
    const orders = await db.collection('orders').find({
      status: 'completed',
      completedAt: { $gte: start, $lte: end }
    }).toArray();

    // 2. Lấy tất cả giao dịch kho trong khoảng thời gian
    const txs = await db.collection('stock_transactions').find({
      date: { $gte: start, $lte: end }
    }).toArray();

    // 3. Lấy tất cả món ăn/uống hiện có
    const menuItems = await db.collection('menu_items').find({}).toArray();

    const statsMap = {};
    for (const item of menuItems) {
      statsMap[item.id] = {
        menuItemId: item.id,
        menuItemName: item.name,
        revenue: 0.0,
        cost: 0.0,
        quantitySold: 0,
        quantityImported: 0
      };
    }

    // 4. Cộng dồn doanh thu từ Hóa đơn
    for (const order of orders) {
      for (const item of (order.items || [])) {
        const id = item.menuItem.id;
        if (!statsMap[id]) {
          statsMap[id] = {
            menuItemId: id,
            menuItemName: item.menuItem.name,
            revenue: 0.0,
            cost: 0.0,
            quantitySold: 0,
            quantityImported: 0
          };
        }
        statsMap[id].revenue += item.quantity * item.priceAtOrder;
        statsMap[id].quantitySold += item.quantity;
      }
    }

    // 5. Cộng dồn chi phí & tiêu thụ từ Stock Transactions
    for (const tx of txs) {
      const id = tx.menuItemId;
      if (id > 0) {
        if (!statsMap[id]) {
          statsMap[id] = {
            menuItemId: id,
            menuItemName: tx.menuItemName,
            revenue: 0.0,
            cost: 0.0,
            quantitySold: 0,
            quantityImported: 0
          };
        }
        if (tx.type === 'in') {
          statsMap[id].cost += tx.quantity * tx.price;
          statsMap[id].quantityImported += tx.quantity;
        } else if (tx.type === 'out') {
          statsMap[id].revenue += tx.quantity * tx.price;
          statsMap[id].quantitySold += tx.quantity;
        }
      }
    }

    let totalRevenue = 0.0;
    let totalCost = 0.0;
    const items = [];

    for (const stats of Object.values(statsMap)) {
      if (stats.revenue > 0 || stats.cost > 0 || stats.quantitySold > 0 || stats.quantityImported > 0) {
        const profit = stats.revenue - stats.cost;
        items.push({
          menuItemId: stats.menuItemId,
          menuItemName: stats.menuItemName,
          revenue: stats.revenue,
          cost: stats.cost,
          profit,
          quantitySold: stats.quantitySold,
          quantityImported: stats.quantityImported
        });
        totalRevenue += stats.revenue;
        totalCost += stats.cost;
      }
    }

    items.sort((a, b) => b.revenue - a.revenue);

    res.json({
      startDate: start,
      endDate: end,
      totalRevenue,
      totalCost,
      totalProfit: totalRevenue - totalCost,
      items
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Báo cáo đồ uống bán chạy nhất (Best Sellers)
app.get('/api/reports/best-sellers', async (req, res) => {
  try {
    const completedOrders = await db.collection('orders').find({ status: 'completed' }).toArray();
    const map = {};

    for (const order of completedOrders) {
      for (const item of (order.items || [])) {
        const id = item.menuItem.id;
        const name = item.menuItem.name;
        const qty = item.quantity;
        const revenue = qty * item.priceAtOrder;

        if (map[id]) {
          map[id].quantitySold += qty;
          map[id].totalRevenue += revenue;
        } else {
          map[id] = {
            menuItemId: id,
            menuItemName: name,
            quantitySold: qty,
            totalRevenue: revenue
          };
        }
      }
    }

    const list = Object.values(map);
    list.sort((a, b) => {
      const cmp = b.quantitySold - a.quantitySold;
      if (cmp !== 0) return cmp;
      return b.totalRevenue - a.totalRevenue;
    });

    res.json(list);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Khởi chạy Server sau khi kết nối DB thành công
connectDb().then(() => {
  app.listen(port, () => {
    console.log(`Backend Server đang chạy tại http://localhost:${port}`);
  });
});
