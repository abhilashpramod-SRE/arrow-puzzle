import 'dart:math';

import 'package:flutter/foundation.dart';

import '../level_data/level_loader.dart';
import '../models/game_models.dart';
import 'sound_service.dart';

class GameController extends ChangeNotifier {
  GameController({required LevelLoader levelLoader, required SoundService soundService})
      : _levelLoader = levelLoader,
        _soundService = soundService;

  final LevelLoader _levelLoader;
  final SoundService _soundService;

  List<LevelModel> _levels = [];
  int _levelIndex = 0;
  int _mistakes = 0;
  List<ArrowModel> _activeArrows = [];
  ArrowMove? _pendingMove;

  bool _isLoading = true;
  bool _isWon = false;
  bool _isFailed = false;

  bool get isLoading => _isLoading;
  bool get isWon => _isWon;
  bool get isFailed => _isFailed;
  int get mistakes => _mistakes;
  int get maxMistakes => 3;

  int get levelNumber => currentLevel.level;
  LevelModel get currentLevel => _levels[_levelIndex];
  List<ArrowModel> get activeArrows => List.unmodifiable(_activeArrows);
  ArrowMove? get pendingMove => _pendingMove;

  int get stars {
    switch (_mistakes) {
      case 0:
        return 3;
      case 1:
        return 2;
      default:
        return 1;
    }
  }

  Future<void> initialize() async {
    _levels = await _levelLoader.loadLevels();
    _isLoading = false;
    _loadLevel(0);
    notifyListeners();
  }

  void _loadLevel(int index) {
    _levelIndex = index.clamp(0, max(0, _levels.length - 1));
    _mistakes = 0;
    _isWon = false;
    _isFailed = false;
    _pendingMove = null;
    _activeArrows = currentLevel.arrows.map((arrow) => arrow.copyWith()).toList();
  }

  void restartLevel() {
    _loadLevel(_levelIndex);
    notifyListeners();
  }

  void nextLevel() {
    if (_levelIndex >= _levels.length - 1) {
      _loadLevel(0);
    } else {
      _loadLevel(_levelIndex + 1);
    }
    notifyListeners();
  }

  void onArrowTapped(String arrowId) {
    if (_pendingMove != null || _isWon || _isFailed) {
      return;
    }

    ArrowModel? arrow;
    for (final candidate in _activeArrows) {
      if (candidate.id == arrowId) {
        arrow = candidate;
        break;
      }
    }
    if (arrow == null) {
      return;
    }

    _soundService.playTap();
    _pendingMove = _calculateMove(arrow);
    notifyListeners();
  }

  ArrowMove _calculateMove(ArrowModel arrow) {
    final delta = switch (arrow.direction) {
      ArrowDirection.up => const GridPoint(0, -1),
      ArrowDirection.down => const GridPoint(0, 1),
      ArrowDirection.left => const GridPoint(-1, 0),
      ArrowDirection.right => const GridPoint(1, 0),
    };

    var cursor = arrow.position;

    while (true) {
      final next = cursor.copyWith(x: cursor.x + delta.x, y: cursor.y + delta.y);
      final outOfGrid = next.x < 0 || next.x >= currentLevel.gridSize || next.y < 0 || next.y >= currentLevel.gridSize;
      if (outOfGrid) {
        return ArrowMove(
          arrow: arrow,
          from: arrow.position,
          to: next,
          result: MoveResult.exited,
          duration: _durationForDistance(_distance(arrow.position, next)),
        );
      }

      if (currentLevel.walls.contains(next)) {
        return ArrowMove(
          arrow: arrow,
          from: arrow.position,
          to: cursor,
          result: MoveResult.wallHit,
          duration: _durationForDistance(_distance(arrow.position, cursor).clamp(1, 20)),
        );
      }

      cursor = next;

      if (currentLevel.exits.contains(cursor)) {
        return ArrowMove(
          arrow: arrow,
          from: arrow.position,
          to: cursor,
          result: MoveResult.exited,
          duration: _durationForDistance(_distance(arrow.position, cursor)),
        );
      }
    }
  }

  int _distance(GridPoint from, GridPoint to) => (from.x - to.x).abs() + (from.y - to.y).abs();

  Duration _durationForDistance(int distance) => Duration(milliseconds: (220 + (distance * 90)).clamp(220, 1000));

  void completePendingMove() {
    final move = _pendingMove;
    if (move == null) {
      return;
    }

    if (move.result == MoveResult.exited) {
      _activeArrows.removeWhere((arrow) => arrow.id == move.arrow.id);
      if (_activeArrows.isEmpty) {
        _isWon = true;
        _soundService.playSuccess();
      }
    } else {
      _mistakes += 1;
      _soundService.playFailure();
      if (_mistakes >= maxMistakes) {
        _isFailed = true;
      }
    }

    _pendingMove = null;
    notifyListeners();
  }
}
