import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// enum for tracking the current state of a Button
enum KeyPressState {
  down,
  up,
  undefined,
}

/// Callback for a Keyboard event
typedef KeyboardKeyCallback = void Function(bool isDown, RawKeyEvent key);

/// Widget that watches keyboard keys and provides callbacks
/// [child] Widget (usually Scaffold)
/// [keyboard] Keyboard variable that was instatiated in the initState
/// [autofocus] if the widget need to be focus on build
/// [focusNode] focus to use when in need to manage focus manually
/// [onKeyCallbacks] a Map<LogicalKeyboardKey, KeyboardKeyCallback> which provides callbacks for the specified keys
class ControlKeyboardListener extends StatelessWidget {
  ControlKeyboardListener({
    required this.child,
    this.autofocus = false,
    FocusNode? focusNode,
    this.onKeyCallbacks = const {},
    Key? key, this.onAnyKeyDown, this.onAnyKeyUp,
  }) : super(key: key) {
    _focusNode = focusNode ?? FocusNode(debugLabel: 'KeyboardListener');
  }

  /// the child
  final Widget child;

  /// if the listener should automatically pull the focus (usually true)
  final bool autofocus;

  /// the callbacks for this listner
  final Map<LogicalKeyboardKey, KeyboardKeyCallback> onKeyCallbacks;

  /// callback when ANY key is down
  final KeyboardKeyCallback? onAnyKeyDown;

  /// callback when ANY key is up
  final KeyboardKeyCallback? onAnyKeyUp;


  /// the current key states
  Map<LogicalKeyboardKey, KeyPressState> _keyState = {};

  /// the focus node
  late FocusNode _focusNode;

  /// static KeySet for all [Shift] keys
  static Set<LogicalKeyboardKey> shiftKeys = {LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.shift, LogicalKeyboardKey.shiftRight};

  /// static KeySet for all [Control] keys
  static Set<LogicalKeyboardKey> controlKeys = {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.controlRight, LogicalKeyboardKey.control};

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: autofocus,
      onKey: (RawKeyEvent key) async {

        /// check if key up and maybe call callback
        if(key is RawKeyUpEvent) {
          // RawKeyUpEvent ruk = key as RawKeyUpEvent;
          // LogicalKeyboardKey lk = ruk.logicalKey;
          // print("");
          if(onAnyKeyUp != null) {
            onAnyKeyUp!(false, key);
          }
        }

        /// check if key down and maybe call callback
        if(key is RawKeyDownEvent) {
          // RawKeyDownEvent rdk = key as RawKeyDownEvent;
          // LogicalKeyboardKey lk = rdk.logicalKey;
          // print("");
          if(onAnyKeyDown != null) {
            onAnyKeyDown!(false, key);
          }
        }



        if (onKeyCallbacks.containsKey(key.logicalKey)) {
          final keyState = getKeyState(key);
          if (!_keyState.containsKey(key.logicalKey)) {
            _keyState[key.logicalKey] = KeyPressState.undefined;
          }

          if (_keyState[key.logicalKey]! != keyState) {
            // print("hay key" + key.logicalKey.toString());
            _keyState[key.logicalKey] = keyState;
            onKeyCallbacks[key.logicalKey]!(key is RawKeyDownEvent, key);
          }
        }
      },
      child: child,
    );
  }

  KeyPressState getKeyState(RawKeyEvent event) {
    return (event is RawKeyDownEvent) ? KeyPressState.down : KeyPressState.up;
  }

  bool isKeyDown(RawKeyEvent event) {
    return (event is RawKeyDownEvent) ? true : false;
  }
}
