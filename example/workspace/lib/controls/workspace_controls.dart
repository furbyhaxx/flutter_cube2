import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'keyboard_listener.dart';

/// constant for the mousewheel button as pointer
const kMouseWheel = 999;

/// callback for [WorkspaceControls] actions
typedef ControlGestureCallback = void Function(Offset offset);

/// defines a gesture used by [WorkspaceControls]
class ControlGesture {
  ControlGesture({
    required this.button,
    this.key,
    this.keySet = const {},
    this.name = "",
    required this.callback,
  }) {
    _generateKeyList();
  }

  void _generateKeyList() {
    if(key != null) {
      keyList = {key!.keyId};
    } else {

      // List<LogicalKeyboardKey> test = keySet.toList();

      Set<int> temp = {};
      for (var element in keySet) {
        temp.add(element.keyId);
      }
      keyList = temp;
    }
  }

  /// The single key of this [ControlGesture]
  final LogicalKeyboardKey? key;

  /// The keyset key of this [ControlGesture]
  final Set<LogicalKeyboardKey> keySet;

  late Set<int> keyList;

  // static const LogicalKeySet shiftKeys = LogicalKeySet();

  /// The pointer button of this [ControlGesture]
  final int button;

  /// The callback of this [ControlGesture]
  final ControlGestureCallback callback;

  bool isKeyMatch = false;
  bool isButtonMatch = false;

  bool get isValid => isKeyMatch && isButtonMatch;

  final String name;
}

enum ControlState {
  none,
  pan,
  dolly,
  zoom,
}

/// A widget that provides camera controls in a [Workspace]
/// [child] Widget (usually Scaffold)
/// [pan] is the [ControlGesture] object for pan gesture
/// [rotate] is the [ControlGesture] object for rotate gesture
/// [zoom] is the [ControlGesture] object for zoom gesture
class WorkspaceControls extends StatelessWidget {
  WorkspaceControls({
    required this.child,
    required this.pan,
    required this.rotate,
    required this.zoom,
    Key? key,
  }) : super(key: key);

  /// A predefined instance of [WorkspaceControls] to navigate in an orbit around the target
  /// Pan is done trought dragging with the tertiary button (mouse wheel and xxx on touchscreen)
  /// Rotation is done trought holding [Shift] and dragging with [Tertiary] button (MouseWheelButton)
  /// Zoom is done trought scrolling with [MouseWheel]
  /// required [child] The child widget
  /// TODO: test and implement handlers for touch gestures, currently only mouse and keyboard is tested
  factory WorkspaceControls.orbit({
    required Widget child,
    ControlGestureCallback? onPan,
    ControlGestureCallback? onRotate,
    ControlGestureCallback? onZoom,
  }) {
    return WorkspaceControls(
      pan: ControlGesture(
        name: "PAN",
          button: kTertiaryButton,
          key: null,
          callback: (Offset offset) {
            if (onPan == null) {
              print("pan, " + offset.toString());
            } else {
              onPan(offset);
            }
          }),
      rotate: ControlGesture(
          name: "DOLLY",
          button: kTertiaryButton,
          // key: LogicalKeyboardKey.shiftLeft,
          keySet: ControlKeyboardListener.shiftKeys,
          callback: (Offset offset) {
            if (onRotate == null) {
              print("rotate, " + offset.toString());
            } else {
              onRotate(offset);
            }
          }),
      zoom: ControlGesture(
          name: "ZOOM",
          button: kMouseWheel,
          key: null,
          callback: (Offset offset) {
            if (onZoom == null) {
              print("zoom, " + offset.toString());
            } else {
              onZoom(offset);
            }
          }),
      child: child,
    );
  }

  /// The child widget
  final Widget child;

  /// the focus node
  final FocusNode _focusNode = FocusNode(debugLabel: 'KeyboardListener');

  ControlState _state = ControlState.none;

  /// Pan gesture
  final ControlGesture pan;

  /// Rotate gesture
  final ControlGesture rotate;

  /// Zoom gesture
  final ControlGesture zoom;

  Set<LogicalKeyboardKey> _currentDownKeys = {};
  Set<int> _currentDownKeyIds = {};

  /// current key state for the [pan] gesture key
  /// if no key is present [KeyPressState] stays [undefined]
  KeyPressState _panKeyState = KeyPressState.undefined;

  /// current key state for the [rotate] gesture key
  KeyPressState _rotateKeyState = KeyPressState.undefined;

  /// current key state for the [zoom] gesture key
  KeyPressState _zoomKeyState = KeyPressState.undefined;

  /// internal map of callbacks for [ControlKeyboardListener]
  Map<LogicalKeyboardKey, KeyboardKeyCallback>? _keyboardCallbacks;

  /// builds the callback list for [ControlKeyboardListener]
  Map<LogicalKeyboardKey, KeyboardKeyCallback> _buildKeyboardCallbackList() {
    Map<LogicalKeyboardKey, KeyboardKeyCallback> data = {};
    // assert(pan.key == null && pan.keySet == null, "pan key and keyset can't both be null");
    // assert(rotate.key == null && rotate.keySet == null, "rotate key and keyset can't both be null");
    // assert(zoom.key == null && zoom.keySet == null, "zoom key and keyset can't both be null");

    // assert(pan.key == null && pan.keySet == null, "pan key and keyset can't both be set");
    // assert(rotate.key == null && rotate.keySet == null, "rotate key and keyset can't both be set");
    // assert(zoom.key == null && zoom.keySet == null, "zoom key and keyset can't both be set");

    if (pan.key != null) {
      data[pan.key!] = (down, event) {
        _panKeyState = down ? KeyPressState.down : KeyPressState.up;
      };
    } else {
      for (var key in pan.keySet) {
        data[key] = (down, event) {
          _panKeyState = down ? KeyPressState.down : KeyPressState.up;
        };
      }
    }

    if (rotate.key != null) {
      data[rotate.key!] = (down, event) {
        _rotateKeyState = down ? KeyPressState.down : KeyPressState.up;
      };
    } else {
      for (var key in rotate.keySet) {
        data[key] = (down, event) {
          _rotateKeyState = down ? KeyPressState.down : KeyPressState.up;
        };
      }
    }

    if (zoom.key != null) {
      data[zoom.key!] = (down, event) {
        _zoomKeyState = down ? KeyPressState.down : KeyPressState.up;
      };
    } else {
      for (var key in zoom.keySet) {
        data[key] = (down, event) {
          _zoomKeyState = down ? KeyPressState.down : KeyPressState.up;
        };
      }
    }

    _keyboardCallbacks = data;

    return data;
  }

  bool _checkGestureKeyState(ControlGesture gesture) {
    bool isKeyMatch = false;
    if(gesture.keyList.isEmpty) {
      isKeyMatch = _currentDownKeys.isEmpty ? true : false;
    } else {

      if(_currentDownKeyIds.intersection(gesture.keyList).isNotEmpty) {
        isKeyMatch = true;
      } else {
        isKeyMatch = false;
      }
      
      // // if(_currentDownKeys.toList().singleWhere((element) => gesture.keyList.contains(element.keyId)))
      //
      // LogicalKeyboardKey? result = _currentDownKeys.toList().firstWhereOrNull((e) => e == 'D');
      //
      // if ((_currentDownKeys.toList().singleWhere((it) => gesture.keyList.contains(it.keyId))) != null) {
      //
      //   print('Already exists!');
      // }
      //
      //
      // LogicalKeyboardKey key1 = gesture.keySet.elementAt(0);
      // LogicalKeyboardKey key2 = _currentDownKeys.elementAt(0);
      //
      // isKeyMatch = gesture.keySet.intersection(_currentDownKeys).isNotEmpty;
      // int keyMatchCount = 0;
      // for (var key in gesture.keySet) {
      //   keyMatchCount += (_currentDownKeys.contains(key)) ? 1 : 0;
      // }
      // isKeyMatch = (keyMatchCount == gesture.keySet.length && _currentDownKeys.length == gesture.keySet.length) ? true : false;
    }

    gesture.isKeyMatch = isKeyMatch;

    // debugPrint("ControlGesture ::: " + gesture.name + " key = " + isKeyMatch.toString());

    return isKeyMatch;
  }

  bool _checkGestureButtonState(ControlGesture gesture, PointerMoveEvent event) {
    bool isButtonMatch = false;

    isButtonMatch = gesture.button == event.buttons ? true : false;

    gesture.isButtonMatch = isButtonMatch;

    // debugPrint("ControlGesture ::: " + gesture.name + " button = " + isButtonMatch.toString());

    return isButtonMatch;
  }


  KeyEvent? kevent;

  @override
  Widget build(BuildContext context) {

    return KeyboardListener(
      autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          // print(event);
          if(kevent != null) {
            if(kevent != event) {
              print(event);
            }
          }
          kevent = event;
        },
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.red,
        ),
    );

    return ControlKeyboardListener(
      autofocus: true,
      // onKeyCallbacks: _keyboardCallbacks ?? _buildKeyboardCallbackList(),
      onAnyKeyDown: (down, event) {

        if(!_currentDownKeyIds.contains(event.logicalKey.keyId)) {
          _currentDownKeyIds.add((event).logicalKey.keyId);
        }

        // _currentDownKeys.add((event as RawKeyDownEvent).logicalKey);
        // _currentDownKeyIds.add((event).logicalKey.keyId);
        // debugPrint("keyDown ::: " + _currentDownKeyIds.toString());
        // debugPrint("rotateKeys ::: " + rotate.keyList.toString());
      },
      onAnyKeyUp: (down, event) {
        _currentDownKeys.remove((event as RawKeyUpEvent).logicalKey);
        _currentDownKeyIds.remove((event).logicalKey.keyId);
        debugPrint("keyUp ::: " + _currentDownKeyIds.toString());
      },
      child: Listener(
        onPointerDown: (event) {
          // print("down");
          // _currentKeys.add(event.log)
        },
        onPointerUp: (event) {
          // print("up");
        },
        onPointerMove: (event) {
          // only gets called when a button is pressed while moving

          ControlState newState = ControlState.none;

          // _checkGestureButtonState(pan, event);
          // _checkGestureButtonState(rotate, event);
          // _checkGestureButtonState(zoom, event);
          //
          // _checkGestureKeyState(pan);
          // _checkGestureKeyState(rotate);
          // _checkGestureKeyState(zoom);

          // if(pan.isValid) {
          if(_checkGestureKeyState(pan) && _checkGestureButtonState(pan, event)) {
            newState = ControlState.pan;
            // debugPrint("ControlState ::: PAN valid");
          // } else if(rotate.isValid) {
          }
          if(_checkGestureKeyState(rotate) && _checkGestureButtonState(rotate, event)) {
            newState = ControlState.dolly;
            // debugPrint("ControlState ::: DOLLY valid");
          // } else if(zoom.isValid) {
          }
          if(_checkGestureKeyState(zoom) && _checkGestureButtonState(zoom, event)) {
            newState = ControlState.zoom;
            debugPrint("ControlState ::: ZOOM valid");
          }



          // if(pan.button == event.buttons) {
          //   debugPrint("pan button pressed");
          // }
          //
          // // if (isGestureButtonDown("pan", event) && !isAnyKeyDown("pan")) {
          // if (isGestureButtonDown("pan", event) && !isAnyKeyDown("pan")) {
          //   // pan
          //   // pan.callback(event.delta);
          //
          //   print("pan start");
          //
          //   newState = ControlState.pan;
          // }
          // if (isGestureButtonDown("rotate", event) && !isAnyKeyDown("rotate")) {
          //   // rotate
          //   // rotate.callback(event.delta);
          //   print("dolly start");
          //   newState = ControlState.dolly;
          // }
          // if (isGestureButtonDown("zoom", event) && !isAnyKeyDown("zoom")) {
          //   // zoom
          //   // zoom.callback(event.delta);
          //   print("zoom start");
          //   newState = ControlState.zoom;
          // }

          switch (newState) {
            case ControlState.pan:
              // print("pan");
              debugPrint("ControlState ::: PAN valid");
              pan.callback(event.delta);
              break;
            case ControlState.dolly:
              // print("dolly");
              debugPrint("ControlState ::: DOLLY valid");
              rotate.callback(event.delta);
              break;
            case ControlState.zoom:
              // print("zoom");
              zoom.callback(event.delta);
              break;
            case ControlState.none:
              break;
          }

          _state = newState;

          // if (pan != null && event.buttons == pan!.pointer) {}

          // if (event.buttons == kPrimaryButton) {
          //   print("primary move");
          // } else if (event.buttons == kSecondaryButton) {
          //   print("secondary move");
          // } else if (event.buttons == kTertiaryButton) {
          //   print("tertiary move");
          // }
          pan.isButtonMatch = false;
          pan.isKeyMatch = false;
          rotate.isButtonMatch = false;
          rotate.isKeyMatch = false;
          zoom.isButtonMatch = false;
          zoom.isKeyMatch = false;
        },
        onPointerHover: (event) {
          // gets ONLY called also when no button is pressed.
          // print("hover");
        },
        onPointerCancel: (event) {
          // print("cancel");
        },
        onPointerSignal: (PointerSignalEvent event) {
          if (zoom.button == kMouseWheel && _zoomKeyState != KeyPressState.up) {
            if (event is PointerScrollEvent) {
              // PointerScrollEvent e = event as PointerScrollEvent;
              zoom.callback(Offset(0, event.scrollDelta.dy));
            }
          }
          // if (event is PointerScrollEvent) {
          //   // print('x: ${event.position.dx}, y: ${event.position.dy}');
          //   // print('scroll delta: ${event.scrollDelta}');
          //   PointerScrollEvent e = event as PointerScrollEvent;
          //   _zoom(event.scrollDelta.dy);
          //   // Offset
          // }
          // if(tertiaryButtonDown) {
          //   print(event);
          // }
          // // if(event is PointerDownEvent) {
          // //   PointerDownEvent e = event as PointerDownEvent;
          // //   print(e);
          // // }
        },
        child: child,
      ),
    );
  }
}
