import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_ordering.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create FoodItems and OrderPlans tables
        await db.execute('''
          CREATE TABLE FoodItems (
            id INTEGER PRIMARY KEY,
            name TEXT,
            cost REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE OrderPlans (
            id INTEGER PRIMARY KEY,
            date TEXT,
            target_cost REAL,
            selected_foods TEXT
          )
        ''');
        // Populate initial data
        await _populateInitialData(db);
      },
    );
  }

  // Populate the database with initial food items
  Future<void> _populateInitialData(Database db) async {
    List<Map<String, dynamic>> foodItems = [
        {'name': 'Chicken Burrito', 'cost': 10.0},
        {'name': 'Beef Burrito', 'cost': 9.5},
        {'name': 'Veggie Burrito', 'cost': 8.5},
        {'name': 'Churros', 'cost': 4.0},
        {'name': 'Nachos', 'cost': 7.0},
        {'name': 'Big Mac', 'cost': 5.5},
        {'name': 'Quarter Pounder with Cheese', 'cost': 6.5},
        {'name': 'Chicken McNuggets', 'cost': 4.0},
        {'name': 'Filet-O-Fish', 'cost': 5.0},
        {'name': 'McChicken', 'cost': 3.5},
        {'name': 'Original Recipe Chicken', 'cost': 10.0},
        {'name': 'Zinger Burger', 'cost': 6.5},
        {'name': 'Popcorn Chicken', 'cost': 5.0},
        {'name': 'Hot Wings', 'cost': 7.5},
        {'name': 'Mashed Potatoes with Gravy', 'cost': 3.0},
        {'name': 'Chicken Sandwich', 'cost': 5.5},
        {'name': 'Cajun Fries', 'cost': 3.0},
        {'name': 'Spicy Chicken Tenders', 'cost': 7.0},
        {'name': 'Red Beans & Rice', 'cost': 3.5},
        {'name': 'Biscuits', 'cost': 2.5},


    ];

    // Insert each food item into the FoodItems table
    for (var item in foodItems) {
      await db.insert('FoodItems', item);
      print("Inserted: ${item['name']} with cost ${item['cost']}");  // Debugging: Log insertion
    }
  }


  // Fetch all food items from the database
  Future<List<Map<String, dynamic>>> getFoodItems() async {
    final db = await database;
    return await db.query('FoodItems');
  }

  // Add a food item to the database
  Future<void> addFoodItem(String name, double cost) async {
    final db = await database;
    await db.insert('FoodItems', {'name': name, 'cost': cost});
  }

  // Delete a food item by ID
  Future<void> deleteFoodItem(int id) async {
    final db = await database;
    await db.delete('FoodItems', where: 'id = ?', whereArgs: [id]);
  }

  // Update a food item by ID
  Future<void> updateFoodItem(int id, String name, double cost) async {
    final db = await database;
    await db.update(
      'FoodItems',
      {'name': name, 'cost': cost},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Save an order plan for a given date
  Future<void> saveOrderPlan(String date, double targetCost, List<int> foodIds) async {
    final db = await database;
    String selectedFoods = foodIds.join(',');  // Convert the food IDs to a comma-separated string
    await db.insert('OrderPlans', {
      'date': date,
      'target_cost': targetCost,
      'selected_foods': selectedFoods,
    });
  }

  // Fetch the order plan for a specific date
  Future<Map<String, dynamic>?> getOrderPlan(String date) async {
    final db = await database;
    final result = await db.query('OrderPlans', where: 'date = ?', whereArgs: [date]);
    return result.isNotEmpty ? result.first : null;
  }
}
