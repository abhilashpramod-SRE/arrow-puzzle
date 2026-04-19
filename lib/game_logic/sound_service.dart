import 'package:flutter/services.dart';

/// Lightweight sound feedback without external packages/assets.
class SoundService {
  Future<void> playTap() => SystemSound.play(SystemSoundType.click);

  Future<void> playSuccess() => SystemSound.play(SystemSoundType.alert);

  Future<void> playFailure() => SystemSound.play(SystemSoundType.alert);
}
