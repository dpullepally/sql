import 'package:fluttersqlite/car.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final _databaseName = "cardb.db";
  static final _databaseVersion = 1;

  static final table = 'cars_table';
  static final table2 = 'cars_table2';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnMiles = 'miles';

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnMiles INTEGER NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $table2 (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnMiles INTEGER NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Car car) async {
    insert2(car);
    Database? db = await instance.database;
    return await db!.insert(table, {'name': car.name, 'miles': car.miles}) ;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    queryAllRows2();
    Database? db = await instance.database;
    return await db!.query(table);
  }

  // Queries rows based on the argument received
  Future<List<Map<String, dynamic>>> queryRows(name) async {
    queryRows2(name);
    Database? db = await instance.database;
    return await db!.query(table, where: "$columnName LIKE '%$name%'");
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    queryRowCount2();
    showAllTables();
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Car car) async {
    update2(car);
    Database? db = await instance.database;
    int id = car.toMap()['id'];
    return await db!.update(
        table, car.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    delete2(id);
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> insert2(Car car) async {
    Database? db = await instance.database;
    return await db!.insert(table2, {'name': car.name, 'miles': car.miles}) ;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows2() async {
    Database? db = await instance.database;
    return await db!.query(table2);
  }

  // Queries rows based on the argument received
  Future<List<Map<String, dynamic>>> queryRows2(name) async {
    Database? db = await instance.database;
    return await db!.query(table2, where: "$columnName LIKE '%$name%'");
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount2() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table2'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update2(Car car) async {
    Database? db = await instance.database;
    int id = car.toMap()['id'];
    return await db!.update(
        table2, car.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete2(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table2, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int?> showAllTables() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery("SELECT name FROM sqlite_master WHERE type='table'"));
  }

  Future<int?> joinTables() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery("SELECT * FROM $table a INNER JOIN $table2 b ON a.id=b.id"));
  }

  Future<int?> unionTables() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery("SELECT * FROM $table UNION SELECT * FROM $table2"));
  }

  Future<int?> createView() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery("Create view my_view as SELECT * FROM $table"));
  }

  Future<int?> createIndex() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery("CREATE INDEX carIndex ON $table ($columnId );"));
  }

  Future<int?> createTrigger() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery("CREATE TRIGGER InsertIntoCarTrigger BEFORE INSERT ON $table BEGIN INSERT INTO $table2 VALUES(1, \"maruti\",1543, 'Insert'); END;"));
  }

  Future<int?> fullTextSearch() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery("SELECT * FROM $table WHERE $table MATCH 'learn SQLite';"));
  }

  Future<int?> sqliteCase() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery("SELECT * FROM $table WHERE $table MATCH 'learn SQLite';"));
  }

}