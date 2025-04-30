import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Importer cette bibliothèque pour identifier la plateforme
import 'package:my_app/screens/home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Importer pour le web

void main() {
  runApp(MyApp());

  // Vérifier si l'application est sur le web
  if (kIsWeb) {
    // Utiliser directement databaseFactoryFfiWeb pour le web
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit(); // Initialiser pour les plateformes natives (Android, iOS)
    databaseFactory =
        databaseFactoryFfi; // Utiliser databaseFactoryFfi pour les plateformes natives
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Notes App",
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(color: Colors.black87)),
      home: HomeScreen(),
    );
  }
}
