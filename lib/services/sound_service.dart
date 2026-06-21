import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _swipePlayer;
  final AudioPlayer _mergePlayer;
  final AudioPlayer _newTilePlayer;
  bool _enabled = true;

  SoundService()
      : _swipePlayer = AudioPlayer(),
        _mergePlayer = AudioPlayer(),
        _newTilePlayer = AudioPlayer() {
    _swipePlayer.setVolume(0.5);
    _mergePlayer.setVolume(0.6);
    _newTilePlayer.setVolume(0.4);
  }

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  void playSwipe() {
    if (!_enabled) return;
    _swipePlayer.stop().then((_) {
      _swipePlayer.play(AssetSource('sounds/swipe.wav'));
    }).catchError((_) {});
  }

  void playMerge() {
    if (!_enabled) return;
    _mergePlayer.stop().then((_) {
      _mergePlayer.play(AssetSource('sounds/merge.wav'));
    }).catchError((_) {});
  }

  void playNewTile() {
    if (!_enabled) return;
    _newTilePlayer.stop().then((_) {
      _newTilePlayer.play(AssetSource('sounds/new_tile.wav'));
    }).catchError((_) {});
  }

  void dispose() {
    _swipePlayer.dispose();
    _mergePlayer.dispose();
    _newTilePlayer.dispose();
  }
}
