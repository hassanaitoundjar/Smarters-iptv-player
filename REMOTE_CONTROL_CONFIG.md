# 📺 TV Remote Control Configuration

## 🎮 Remote Control Key Mapping

### Navigation Keys
| Remote Button | Key Code | Action |
|--------------|----------|---------|
| **↑ UP** | Arrow Up | Navigate Up |
| **↓ DOWN** | Arrow Down | Navigate Down |
| **← LEFT** | Arrow Left | Navigate Left |
| **→ RIGHT** | Arrow Right | Navigate Right |
| **OK/SELECT** | Enter/Select | Confirm Selection |

### Media Control Keys
| Remote Button | Key Code | Action |
|--------------|----------|---------|
| **▶ PLAY** | Media Play | Play content |
| **⏸ PAUSE** | Media Pause | Pause content |
| **⏹ STOP** | Media Stop | Stop playback |
| **⏩ FAST FORWARD** | Media Fast Forward | Skip forward 10s |
| **⏪ REWIND** | Media Rewind | Skip backward 10s |
| **⏭ NEXT** | Media Track Next | Next channel/episode |
| **⏮ PREVIOUS** | Media Track Previous | Previous channel/episode |

### Volume Keys
| Remote Button | Key Code | Action |
|--------------|----------|---------|
| **🔊 VOL +** | Audio Volume Up | Increase volume |
| **🔉 VOL -** | Audio Volume Down | Decrease volume |
| **🔇 MUTE** | Audio Volume Mute | Toggle mute |

### Menu & Navigation Keys
| Remote Button | Key Code | Action |
|--------------|----------|---------|
| **🏠 HOME** | Home | Go to home screen |
| **⬅ BACK** | Escape/Back | Go back |
| **☰ MENU** | Context Menu | Open menu |
| **ℹ INFO** | Info | Show info overlay |

### Channel Keys
| Remote Button | Key Code | Action |
|--------------|----------|---------|
| **CH ▲** | Page Up | Next channel |
| **CH ▼** | Page Down | Previous channel |

### Number Keys (Direct Channel Input)
| Remote Button | Key Code | Channel |
|--------------|----------|---------|
| **0-9** | Digit 0-9 | Direct channel number |

### Color Keys (Quick Actions)
| Remote Button | Key Code | Action |
|--------------|----------|---------|
| **🔴 RED** | F1 | Favorites |
| **🟢 GREEN** | F2 | Search |
| **🟡 YELLOW** | F3 | Settings |
| **🔵 BLUE** | F4 | Info/EPG |

---

## 🛠️ Implementation Guide

### 1. Basic Usage in Your Screen

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final FocusNode _remoteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _remoteFocus.requestFocus();
  }

  @override
  void dispose() {
    _remoteFocus.dispose();
    super.dispose();
  }

  void _handleRemoteKey(RawKeyEvent event) {
    final action = RemoteControlHandler.handleKeyEvent(event);
    
    if (action == null) return;
    
    switch (action) {
      case RemoteAction.navigateUp:
        // Handle up navigation
        break;
      case RemoteAction.navigateDown:
        // Handle down navigation
        break;
      case RemoteAction.select:
        // Handle selection
        break;
      case RemoteAction.back:
        Navigator.pop(context);
        break;
      case RemoteAction.play:
        // Play video
        break;
      case RemoteAction.pause:
        // Pause video
        break;
      // Add more cases as needed
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _remoteFocus,
      onKey: _handleRemoteKey,
      child: Scaffold(
        // Your UI here
      ),
    );
  }
}
```

### 2. Number Input for Channel Selection

```dart
String _channelBuffer = '';
Timer? _channelInputTimer;

void _handleRemoteKey(RawKeyEvent event) {
  final action = RemoteControlHandler.handleKeyEvent(event);
  
  if (action == RemoteAction.numberInput) {
    final number = RemoteControlHandler.getNumberFromKeyEvent(event);
    if (number != null) {
      _channelBuffer += number.toString();
      
      // Cancel previous timer
      _channelInputTimer?.cancel();
      
      // Wait 2 seconds for more input
      _channelInputTimer = Timer(Duration(seconds: 2), () {
        _selectChannelByNumber(int.parse(_channelBuffer));
        _channelBuffer = '';
      });
    }
  }
}

void _selectChannelByNumber(int channelNumber) {
  // Navigate to channel by number
  print('Selecting channel: $channelNumber');
}
```

### 3. Video Player Controls

```dart
void _handleVideoPlayerRemote(RawKeyEvent event) {
  final action = RemoteControlHandler.handleKeyEvent(event);
  
  switch (action) {
    case RemoteAction.play:
      videoPlayer.play();
      break;
    case RemoteAction.pause:
      videoPlayer.pause();
      break;
    case RemoteAction.fastForward:
      videoPlayer.seekForward(Duration(seconds: 10));
      break;
    case RemoteAction.rewind:
      videoPlayer.seekBackward(Duration(seconds: 10));
      break;
    case RemoteAction.volumeUp:
      volumeController.increaseVolume(0.1);
      break;
    case RemoteAction.volumeDown:
      volumeController.decreaseVolume(0.1);
      break;
    case RemoteAction.volumeMute:
      volumeController.toggleMute();
      break;
    default:
      break;
  }
}
```

---

## 📱 Supported TV Platforms

✅ **Android TV** - Full support  
✅ **Fire TV** - Full support  
✅ **Samsung Tizen** - Full support  
✅ **LG webOS** - Full support  
✅ **Apple TV** - Full support  
✅ **Google TV** - Full support  

---

## 🎯 Best Practices

1. **Always request focus** - Make sure your `FocusNode` is focused
2. **Handle back button** - Always implement back navigation
3. **Visual feedback** - Show which item is focused
4. **Debounce number input** - Wait for complete channel number
5. **Test on real device** - Remote behavior differs from keyboard

---

## 🔧 Troubleshooting

### Remote not working?
1. Check if `RawKeyboardListener` is properly set up
2. Ensure `FocusNode` is focused
3. Verify remote is paired with TV
4. Check if app has input focus

### Keys not detected?
1. Some TVs map keys differently
2. Use `event.logicalKey.debugName` to see actual key codes
3. Add custom mappings if needed

---

## 📝 Example: Complete TV Screen

See `register_tv.dart` for a complete implementation example with remote control support.

---

## 🚀 Quick Start

1. Import helpers: `import 'package:evoflix/helpers/helpers.dart';`
2. Add `RawKeyboardListener` to your widget
3. Use `RemoteControlHandler.handleKeyEvent()` to process keys
4. Handle actions in your switch statement

That's it! Your app now supports TV remote control! 📺✨
