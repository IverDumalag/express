import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String tbl_name = 'tbl_phrases_words';
  final String col_entry_id = 'entry_id';
  final String col_words = 'words';
  final String col_favorite = 'favorite';
  final String col_sign_language = 'sign_language';
  final String col_created_at = 'created_at';
  final String col_updated_at = 'updated_at';

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'express.db');
    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $tbl_name (
          $col_entry_id VARCHAR(100) PRIMARY KEY,
          $col_words VARCHAR(100) NOT NULL,
          $col_favorite INT NOT NULL, 
          $col_sign_language VARCHAR(100), 
          $col_created_at TIMESTAMP NOT NULL,
          $col_updated_at TIMESTAMP NOT NULL
        )
        ''');
      },
    );
  }

  void addPhrase(String words, int favorite, String sign_language) async {
    final db = await database;
    final String entry_id = '$words${DateTime.now().toIso8601String()}';
    await db.insert(
      tbl_name,
      {
        col_entry_id: entry_id,
        col_words: words,
        col_favorite: favorite,
        col_sign_language: sign_language,
        col_created_at: DateTime.now().toIso8601String(),
        col_updated_at: DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPhrases() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(tbl_name);
    return result;
  }

  Future<void> updateFavorite(String entry_id, int favorite) async {
    final db = await database;
    await db.update(
      tbl_name,
      {
        col_favorite: favorite,
        col_updated_at: DateTime.now().toIso8601String(),
      },
      where: '$col_entry_id = ?',
      whereArgs: [entry_id],
    );
  }

  Future<void> deletePhrase(String entry_id) async {
    final db = await database;
    await db.delete(
      tbl_name,
      where: '$col_entry_id = ?',
      whereArgs: [entry_id],
    );
  }
}
