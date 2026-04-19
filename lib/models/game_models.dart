import 'dart:ui';

enum ArrowDirection { up, down, left, right }

enum MoveResult { exited, wallHit }

class GridPoint {
  const GridPoint(this.x, this.y);

  final int x;
  final int y;

  GridPoint copyWith({int? x, int? y}) => GridPoint(x ?? this.x, y ?? this.y);

  Offset toOffset() => Offset(x.toDouble(), y.toDouble());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GridPoint && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

class ArrowModel {
  const ArrowModel({
    required this.id,
    required this.position,
    required this.direction,
  });

  final String id;
  final GridPoint position;
  final ArrowDirection direction;

  ArrowModel copyWith({String? id, GridPoint? position, ArrowDirection? direction}) =>
      ArrowModel(
        id: id ?? this.id,
        position: position ?? this.position,
        direction: direction ?? this.direction,
      );

  factory ArrowModel.fromJson(Map<String, dynamic> json, {required int index}) {
    return ArrowModel(
      id: 'a_$index',
      position: GridPoint(json['x'] as int, json['y'] as int),
      direction: ArrowDirection.values.firstWhere(
        (value) => value.name == (json['dir'] as String).toLowerCase(),
      ),
    );
  }
}

class LevelModel {
  const LevelModel({
    required this.level,
    required this.gridSize,
    required this.kittyPosition,
    required this.arrows,
    required this.exits,
    required this.walls,
  });

  final int level;
  final int gridSize;
  final GridPoint kittyPosition;
  final List<ArrowModel> arrows;
  final List<GridPoint> exits;
  final List<GridPoint> walls;

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      level: json['level'] as int,
      gridSize: json['gridSize'] as int,
      kittyPosition: GridPoint(
        (json['kittyPosition'] as List<dynamic>)[0] as int,
        (json['kittyPosition'] as List<dynamic>)[1] as int,
      ),
      arrows: ((json['arrows'] as List<dynamic>?) ?? const <dynamic>[])
          .asMap()
          .entries
          .map((entry) => ArrowModel.fromJson(entry.value as Map<String, dynamic>, index: entry.key))
          .toList(),
      exits: ((json['exits'] as List<dynamic>?) ?? const <dynamic>[])
          .map((exit) => GridPoint((exit as Map<String, dynamic>)['x'] as int, exit['y'] as int))
          .toList(),
      walls: ((json['walls'] as List<dynamic>?) ?? const <dynamic>[])
          .map((wall) => GridPoint((wall as Map<String, dynamic>)['x'] as int, wall['y'] as int))
          .toList(),
    );
  }
}

class ArrowMove {
  const ArrowMove({
    required this.arrow,
    required this.from,
    required this.to,
    required this.result,
    required this.duration,
  });

  final ArrowModel arrow;
  final GridPoint from;
  final GridPoint to;
  final MoveResult result;
  final Duration duration;
}
