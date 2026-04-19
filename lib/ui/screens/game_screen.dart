import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game_logic/game_controller.dart';
import '../widgets/puzzle_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, child) {
        if (game.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (game.isWon) {
            _showResultDialog(context, isWin: true, game: game);
          } else if (game.isFailed) {
            _showResultDialog(context, isWin: false, game: game);
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(levelNumber: game.levelNumber),
                const SizedBox(height: 8),
                _HeartsRow(mistakes: game.mistakes, maxMistakes: game.maxMistakes),
                const SizedBox(height: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PuzzleBoard(controller: game),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: game.restartLevel,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Restart'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Hint: Clear outer arrows first.')),
                            );
                          },
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Hint'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showResultDialog(BuildContext context, {required bool isWin, required GameController game}) async {
    if (ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(isWin ? 'Kitty Saved! 🐱✨' : 'Oops! Kitty is still trapped 😿'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isWin ? 'Great job! You cleared all arrows.' : 'You used all 3 hearts. Try again.'),
              const SizedBox(height: 12),
              if (isWin) _StarsRow(stars: game.stars),
            ],
          ),
          actions: [
            if (isWin)
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  game.nextLevel();
                },
                child: const Text('Next Level'),
              )
            else
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  game.restartLevel();
                },
                child: const Text('Retry'),
              ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.levelNumber});

  final int levelNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Level $levelNumber',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

class _HeartsRow extends StatelessWidget {
  const _HeartsRow({required this.mistakes, required this.maxMistakes});

  final int mistakes;
  final int maxMistakes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxMistakes, (index) {
        final isLost = index < mistakes;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isLost ? Icons.heart_broken : Icons.favorite,
            color: isLost ? Colors.black26 : Colors.redAccent,
          ),
        );
      }),
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: 30,
        );
      }),
    );
  }
}
