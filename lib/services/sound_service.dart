import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _swipePlayer = AudioPlayer();
  final AudioPlayer _mergePlayer = AudioPlayer();
  final AudioPlayer _newTilePlayer = AudioPlayer();

  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  void playSwipe() {
    if (!_enabled) return;
    _swipePlayer.stop();
    _swipePlayer.play(AssetSource('sounds/swipe.wav'));
  }

  void playMerge() {
    if (!_enabled) return;
    _mergePlayer.stop();
    _mergePlayer.play(AssetSource('sounds/merge.wav'));
  }

  void playNewTile() {
    if (!_enabled) return;
    _newTilePlayer.stop();
    _newTilePlayer.play(AssetSource('sounds/new_tile.wav'));
  }

  void dispose() {
    _swipePlayer.dispose();
    _mergePlayer.dispose();
    _newTilePlayer.dispose();
  }
}
