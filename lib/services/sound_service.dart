class SoundService {
  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  void playSwipe() {
    // Sound disabled — audioplayers package not available in offline build
  }

  void playMerge() {
    // Sound disabled — audioplayers package not available in offline build
  }

  void playNewTile() {
    // Sound disabled — audioplayers package not available in offline build
  }

  void dispose() {
    // No resources to dispose
  }
}
