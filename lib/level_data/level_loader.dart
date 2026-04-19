import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/game_models.dart';

class LevelLoader {
  Future<List<LevelModel>> loadLevels() async {
    final raw = await rootBundle.loadString('assets/levels/levels.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((json) => LevelModel.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.level.compareTo(b.level));
  }
}
