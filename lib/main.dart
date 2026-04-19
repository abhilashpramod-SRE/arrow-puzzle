import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_logic/game_controller.dart';
import 'game_logic/sound_service.dart';
import 'level_data/level_loader.dart';
import 'ui/screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController(
        levelLoader: LevelLoader(),
        soundService: SoundService(),
      )..initialize(),
      child: const SaveKittyApp(),
    ),
  );
}

class SaveKittyApp extends StatelessWidget {
  const SaveKittyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Save Kitty',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const GameScreen(),
    );
  }
}
