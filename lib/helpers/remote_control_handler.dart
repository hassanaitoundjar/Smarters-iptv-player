part of 'helpers.dart';

/// Remote Control Handler
/// Handles TV remote control key events
class RemoteControlHandler {
  /// Handle remote key event (New API)
  static RemoteAction? handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return null;
    
    final key = event.logicalKey.keyLabel;
    
    // Navigation Keys
    if (key == RemoteControlConfig.keyUp || event.logicalKey == LogicalKeyboardKey.arrowUp) {
      return RemoteAction.navigateUp;
    }
    if (key == RemoteControlConfig.keyDown || event.logicalKey == LogicalKeyboardKey.arrowDown) {
      return RemoteAction.navigateDown;
    }
    if (key == RemoteControlConfig.keyLeft || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      return RemoteAction.navigateLeft;
    }
    if (key == RemoteControlConfig.keyRight || event.logicalKey == LogicalKeyboardKey.arrowRight) {
      return RemoteAction.navigateRight;
    }
    if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
      return RemoteAction.select;
    }
    
    // Back/Escape
    if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.goBack) {
      return RemoteAction.back;
    }
    
    // Home
    if (event.logicalKey == LogicalKeyboardKey.home) {
      return RemoteAction.home;
    }
    
    // Menu
    if (event.logicalKey == LogicalKeyboardKey.contextMenu) {
      return RemoteAction.menu;
    }
    
    // Media Keys
    if (event.logicalKey == LogicalKeyboardKey.mediaPlay) {
      return RemoteAction.play;
    }
    if (event.logicalKey == LogicalKeyboardKey.mediaPause) {
      return RemoteAction.pause;
    }
    if (event.logicalKey == LogicalKeyboardKey.mediaPlayPause) {
      return RemoteAction.play; // Toggle play/pause
    }
    if (event.logicalKey == LogicalKeyboardKey.mediaStop) {
      return RemoteAction.stop;
    }
    if (event.logicalKey == LogicalKeyboardKey.mediaFastForward) {
      return RemoteAction.fastForward;
    }
    if (event.logicalKey == LogicalKeyboardKey.mediaRewind) {
      return RemoteAction.rewind;
    }
    if (event.logicalKey == LogicalKeyboardKey.mediaTrackNext) {
      return RemoteAction.nextTrack;
    }
    if (event.logicalKey == LogicalKeyboardKey.mediaTrackPrevious) {
      return RemoteAction.previousTrack;
    }
    
    // Volume Keys
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
      return RemoteAction.volumeUp;
    }
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
      return RemoteAction.volumeDown;
    }
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeMute) {
      return RemoteAction.volumeMute;
    }
    
    // Channel Keys
    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      return RemoteAction.channelUp;
    }
    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      return RemoteAction.channelDown;
    }
    
    // Info Key
    if (event.logicalKey == LogicalKeyboardKey.info) {
      return RemoteAction.info;
    }
    
    // Color Keys
    if (event.logicalKey == LogicalKeyboardKey.f1) {
      return RemoteAction.colorRed;
    }
    if (event.logicalKey == LogicalKeyboardKey.f2) {
      return RemoteAction.colorGreen;
    }
    if (event.logicalKey == LogicalKeyboardKey.f3) {
      return RemoteAction.colorYellow;
    }
    if (event.logicalKey == LogicalKeyboardKey.f4) {
      return RemoteAction.colorBlue;
    }
    
    // Number Keys
    if (event.logicalKey == LogicalKeyboardKey.digit0 || event.logicalKey == LogicalKeyboardKey.numpad0) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit1 || event.logicalKey == LogicalKeyboardKey.numpad1) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit2 || event.logicalKey == LogicalKeyboardKey.numpad2) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit3 || event.logicalKey == LogicalKeyboardKey.numpad3) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit4 || event.logicalKey == LogicalKeyboardKey.numpad4) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit5 || event.logicalKey == LogicalKeyboardKey.numpad5) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit6 || event.logicalKey == LogicalKeyboardKey.numpad6) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit7 || event.logicalKey == LogicalKeyboardKey.numpad7) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit8 || event.logicalKey == LogicalKeyboardKey.numpad8) {
      return RemoteAction.numberInput;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit9 || event.logicalKey == LogicalKeyboardKey.numpad9) {
      return RemoteAction.numberInput;
    }
    
    return null;
  }
  
  /// Get number from key event
  static int? getNumberFromKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return null;
    
    if (event.logicalKey == LogicalKeyboardKey.digit0 || event.logicalKey == LogicalKeyboardKey.numpad0) return 0;
    if (event.logicalKey == LogicalKeyboardKey.digit1 || event.logicalKey == LogicalKeyboardKey.numpad1) return 1;
    if (event.logicalKey == LogicalKeyboardKey.digit2 || event.logicalKey == LogicalKeyboardKey.numpad2) return 2;
    if (event.logicalKey == LogicalKeyboardKey.digit3 || event.logicalKey == LogicalKeyboardKey.numpad3) return 3;
    if (event.logicalKey == LogicalKeyboardKey.digit4 || event.logicalKey == LogicalKeyboardKey.numpad4) return 4;
    if (event.logicalKey == LogicalKeyboardKey.digit5 || event.logicalKey == LogicalKeyboardKey.numpad5) return 5;
    if (event.logicalKey == LogicalKeyboardKey.digit6 || event.logicalKey == LogicalKeyboardKey.numpad6) return 6;
    if (event.logicalKey == LogicalKeyboardKey.digit7 || event.logicalKey == LogicalKeyboardKey.numpad7) return 7;
    if (event.logicalKey == LogicalKeyboardKey.digit8 || event.logicalKey == LogicalKeyboardKey.numpad8) return 8;
    if (event.logicalKey == LogicalKeyboardKey.digit9 || event.logicalKey == LogicalKeyboardKey.numpad9) return 9;
    
    return null;
  }
}
