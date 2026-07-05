import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/notes_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NOTE: Run `flutterfire configure` in this project directory to
  // auto-generate firebase_options.dart, then uncomment the import below
  // and pass `options: DefaultFirebaseOptions.currentPlatform` here.
  // import 'firebase_options.dart';
  await Firebase.initializeApp();

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotesListScreen(),
    );
  }
}