# Save Kitty (Flutter)

A casual arrow-maze puzzle game where you clear arrows to rescue the kitty.

## Run

```bash
flutter pub get
flutter run
```

## Architecture

- `lib/models`: immutable game data models
- `lib/game_logic`: state and gameplay engine
- `lib/level_data`: JSON level loader
- `lib/ui`: screens and widgets
- `assets/levels/levels.json`: level definitions

## Gameplay rules

- Tap an arrow to move it continuously in its facing direction.
- If it reaches an exit or leaves the board, it is removed.
- If it hits a wall, you lose one heart.
- You have 3 hearts total.
- Remove all arrows to save the kitty.
