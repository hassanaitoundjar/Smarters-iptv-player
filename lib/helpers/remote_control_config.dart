part of 'helpers.dart';

/// TV Remote Control Configuration
/// Maps remote control keys to actions
class RemoteControlConfig {
  // Navigation Keys
  static const String keyUp = 'Arrow Up';
  static const String keyDown = 'Arrow Down';
  static const String keyLeft = 'Arrow Left';
  static const String keyRight = 'Arrow Right';
  static const String keyCenter = 'Select';
  static const String keyOk = 'Enter';
  
  // Media Control Keys
  static const String keyPlay = 'Media Play';
  static const String keyPause = 'Media Pause';
  static const String keyPlayPause = 'Media Play Pause';
  static const String keyStop = 'Media Stop';
  static const String keyFastForward = 'Media Fast Forward';
  static const String keyRewind = 'Media Rewind';
  static const String keyNext = 'Media Track Next';
  static const String keyPrevious = 'Media Track Previous';
  
  // Volume Keys
  static const String keyVolumeUp = 'Audio Volume Up';
  static const String keyVolumeDown = 'Audio Volume Down';
  static const String keyVolumeMute = 'Audio Volume Mute';
  
  // Menu Keys
  static const String keyMenu = 'Context Menu';
  static const String keyBack = 'Escape';
  static const String keyHome = 'Home';
  static const String keyInfo = 'Info';
  
  // Number Keys (for channel selection)
  static const String key0 = 'Digit 0';
  static const String key1 = 'Digit 1';
  static const String key2 = 'Digit 2';
  static const String key3 = 'Digit 3';
  static const String key4 = 'Digit 4';
  static const String key5 = 'Digit 5';
  static const String key6 = 'Digit 6';
  static const String key7 = 'Digit 7';
  static const String key8 = 'Digit 8';
  static const String key9 = 'Digit 9';
  
  // Color Keys (Red, Green, Yellow, Blue)
  static const String keyRed = 'F1';
  static const String keyGreen = 'F2';
  static const String keyYellow = 'F3';
  static const String keyBlue = 'F4';
  
  // Channel Keys
  static const String keyChannelUp = 'Page Up';
  static const String keyChannelDown = 'Page Down';
  
  /// Check if key is a navigation key
  static bool isNavigationKey(String key) {
    return [keyUp, keyDown, keyLeft, keyRight, keyCenter, keyOk].contains(key);
  }
  
  /// Check if key is a media control key
  static bool isMediaKey(String key) {
    return [
      keyPlay,
      keyPause,
      keyPlayPause,
      keyStop,
      keyFastForward,
      keyRewind,
      keyNext,
      keyPrevious
    ].contains(key);
  }
  
  /// Check if key is a volume key
  static bool isVolumeKey(String key) {
    return [keyVolumeUp, keyVolumeDown, keyVolumeMute].contains(key);
  }
  
  /// Check if key is a number key
  static bool isNumberKey(String key) {
    return [key0, key1, key2, key3, key4, key5, key6, key7, key8, key9]
        .contains(key);
  }
  
  /// Get number from key
  static int? getNumberFromKey(String key) {
    switch (key) {
      case key0:
        return 0;
      case key1:
        return 1;
      case key2:
        return 2;
      case key3:
        return 3;
      case key4:
        return 4;
      case key5:
        return 5;
      case key6:
        return 6;
      case key7:
        return 7;
      case key8:
        return 8;
      case key9:
        return 9;
      default:
        return null;
    }
  }
}

/// Remote Control Actions
enum RemoteAction {
  navigateUp,
  navigateDown,
  navigateLeft,
  navigateRight,
  select,
  back,
  home,
  menu,
  play,
  pause,
  stop,
  fastForward,
  rewind,
  nextTrack,
  previousTrack,
  volumeUp,
  volumeDown,
  volumeMute,
  channelUp,
  channelDown,
  numberInput,
  info,
  colorRed,
  colorGreen,
  colorYellow,
  colorBlue,
}
