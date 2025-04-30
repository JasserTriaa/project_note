import 'package:my_app/Model/notes_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton pour assurer une seule instance de DatabaseHelper
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance; // Retourne toujours la même instance
  DatabaseHelper._internal(); // Constructeur privé pour Singleton

  // Constantes pour le nom de la table et les colonnes
  static const String tableNotes = 'notes';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnContent = 'content';
  static const String columnColor = 'color';
  static const String columnDateTime = 'dateTime';

  // Getter pour la base de données
  Future<Database> get database async {
    // Vérifie si la base de données est déjà initialisée
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialisation de la base de données
  Future<Database> _initDatabase() async {
    try {
      // Obtient le chemin de stockage pour les bases de données
      String path = join(await getDatabasesPath(), 'my_notes.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate, // Appelé uniquement lors de la création initiale
      );
    } catch (e) {
      // Gestion des erreurs d'initialisation
      throw Exception(
          'Erreur lors de l\'initialisation de la base de données : $e');
    }
  }

  // Création de la table (appelée lors de l'initialisation)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNotes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnColor TEXT NOT NULL,
        $columnDateTime TEXT NOT NULL
      )
    ''');
  }

  // Insertion d'une nouvelle note
  Future<int> insertNote(Note note) async {
    final db = await database;

    // Validation des champs obligatoires
    if (note.title.isEmpty || note.content.isEmpty) {
      throw ArgumentError(
          'Le titre et le contenu de la note ne peuvent pas être vides.');
    }

    try {
      // Ajout de la note dans la base de données
      return await db.insert(tableNotes, note.toMap());
    } catch (e) {
      throw Exception('Erreur lors de l\'insertion de la note : $e');
    }
  }

  // Récupération de toutes les notes
  Future<List<Note>> getNotes({int limit = 10, int offset = 0}) async {
    final db = await database;

    try {
      // Requête pour récupérer toutes les notes avec pagination
      final List<Map<String, dynamic>> maps = await db.query(
        tableNotes,
        limit: limit,
        offset: offset,
      );

      // Transformation des résultats en une liste d'objets Note
      return maps.map((map) => Note.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notes : $e');
    }
  }

  // Mise à jour d'une note existante
  Future<int> updateNote(Note note) async {
    final db = await database;

    // Vérifie que l'ID est présent
    if (note.id == null) {
      throw ArgumentError(
          'L\'ID de la note ne peut pas être null pour une mise à jour.');
    }

    try {
      // Met à jour la note dans la base de données
      return await db.update(
        tableNotes,
        note.toMap(),
        where: '$columnId = ?', // Clause WHERE pour sélectionner la note
        whereArgs: [note.id],
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la note : $e');
    }
  }

  // Suppression d'une note
  Future<int> deleteNote(int id) async {
    final db = await database;

    try {
      // Supprime la note correspondant à l'ID donné
      return await db.delete(
        tableNotes,
        where: '$columnId = ?', // Clause WHERE pour sélectionner la note
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la note : $e');
    }
  }

  // Suppression de plusieurs notes
  Future<int> deleteNotes(List<int> ids) async {
    final db = await database;

    try {
      // Supprime plusieurs notes correspondant aux IDs donnés
      return await db.delete(
        tableNotes,
        where: '$columnId IN (${List.filled(ids.length, '?').join(', ')})',
        whereArgs: ids,
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression des notes : $e');
    }
  }

  // Fermeture de la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
