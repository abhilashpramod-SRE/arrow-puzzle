import 'dart:ui';
import 'package:flutter/material.dart';

import '../../game_logic/game_controller.dart';
import '../../models/game_models.dart';

class PuzzleBoard extends StatelessWidget {
  const PuzzleBoard({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final level = controller.currentLevel;
    final cellCount = level.gridSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final boardSize = size.isFinite ? size : 320.0;
        final cellSize = boardSize / cellCount;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(boardSize, boardSize),
                painter: BoardPainter(level: level),
              ),
              ...controller.activeArrows
                  .where((arrow) => controller.pendingMove?.arrow.id != arrow.id)
                  .map(
                    (arrow) => Positioned(
                      left: arrow.position.x * cellSize,
                      top: arrow.position.y * cellSize,
                      width: cellSize,
                      height: cellSize,
                      child: ArrowTile(
                        arrow: arrow,
                        onTap: () => controller.onArrowTapped(arrow.id),
                      ),
                    ),
                  ),
              if (controller.pendingMove != null)
                MovingArrow(
                  move: controller.pendingMove!,
                  cellSize: cellSize,
                  onComplete: controller.completePendingMove,
                ),
            ],
          ),
        );
      },
    );
  }
}

class BoardPainter extends CustomPainter {
  BoardPainter({required this.level});

  final LevelModel level;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / level.gridSize;
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.black87;

    for (var i = 0; i <= level.gridSize; i++) {
      final offset = i * cellSize;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), gridPaint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
    }

    final exitPaint = Paint()..color = Colors.green.withValues(alpha: 0.18);
    for (final exit in level.exits) {
      canvas.drawRect(
        Rect.fromLTWH(exit.x * cellSize, exit.y * cellSize, cellSize, cellSize),
        exitPaint,
      );
    }

    final wallPaint = Paint()..color = Colors.black87;
    for (final wall in level.walls) {
      canvas.drawRect(
        Rect.fromLTWH(wall.x * cellSize, wall.y * cellSize, cellSize, cellSize),
        wallPaint,
      );
    }

    final kittyRect = Rect.fromLTWH(
      level.kittyPosition.x * cellSize,
      level.kittyPosition.y * cellSize,
      cellSize,
      cellSize,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '🐱',
        style: TextStyle(fontSize: cellSize * 0.55),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final kittyOffset = Offset(
      kittyRect.left + (cellSize - textPainter.width) / 2,
      kittyRect.top + (cellSize - textPainter.height) / 2,
    );
    textPainter.paint(canvas, kittyOffset);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => oldDelegate.level != level;
}

class ArrowTile extends StatelessWidget {
  const ArrowTile({super.key, required this.arrow, required this.onTap});

  final ArrowModel arrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            _symbolForDirection(arrow.direction),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  String _symbolForDirection(ArrowDirection direction) => switch (direction) {
        ArrowDirection.up => '↑',
        ArrowDirection.down => '↓',
        ArrowDirection.left => '←',
        ArrowDirection.right => '→',
      };
}

class MovingArrow extends StatefulWidget {
  const MovingArrow({
    super.key,
    required this.move,
    required this.cellSize,
    required this.onComplete,
  });

  final ArrowMove move;
  final double cellSize;
  final VoidCallback onComplete;

  @override
  State<MovingArrow> createState() => _MovingArrowState();
}

class _MovingArrowState extends State<MovingArrow> {
  @override
  Widget build(BuildContext context) {
    final move = widget.move;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: move.duration,
      curve: Curves.easeInOut,
      onEnd: widget.onComplete,
      builder: (context, progress, child) {
        final x = lerpDouble(move.from.x.toDouble(), move.to.x.toDouble(), progress)!;
        final y = lerpDouble(move.from.y.toDouble(), move.to.y.toDouble(), progress)!;

        return Positioned(
          left: x * widget.cellSize,
          top: y * widget.cellSize,
          width: widget.cellSize,
          height: widget.cellSize,
          child: IgnorePointer(
            child: Center(
              child: Text(
                switch (move.arrow.direction) {
                  ArrowDirection.up => '↑',
                  ArrowDirection.down => '↓',
                  ArrowDirection.left => '←',
                  ArrowDirection.right => '→',
                },
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
