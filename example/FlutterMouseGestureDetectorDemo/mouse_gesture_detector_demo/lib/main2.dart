import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Mouse Gesture Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: KeyboardListener(
        autofocus: true,
        child: Container(
          color: Colors.grey,
          child: Stack(
            children: [
              const Positioned.fill(
                child: Center(
                  child: Text(
                    "Make mouse gestures here..",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Text("focus: " + _hasFocus.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


typedef KeyboardKeyCallback = void Function(bool isDown);

/// Widget that intercept every button pressed over a bluetooth or external keyboard and pass it to the manager
/// [child] Widget (usually Scaffold)
/// [keyboard] Keyboard variable that was instatiate in the initState
/// [autofocus] if the widget need to be focus on build
/// [focusNode] focus to use when in need to manage focus manually
class KeyboardListener extends StatelessWidget {
  KeyboardListener({required this.child, this.autofocus = false, FocusNode? focusNode, this.onKeyCallbacks = const {}, Key? key, }) : super(key: key) {
    _focusNode = focusNode ?? FocusNode(debugLabel: 'KeyboardListener');
  }

  final Widget child;
  final Map<LogicalKeyboardKey, KeyboardKeyCallback> onKeyCallbacks;
  final bool autofocus;
  // final FocusNode _focusNode;

  late FocusNode _focusNode;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: autofocus,
        onKey: (RawKeyEvent key) async {
          LogicalKeyboardKey ctrl = LogicalKeyboardKey.control;
          print("test");
          if(onKeyCallbacks.containsKey(key.runtimeType)) {

          }
        },
        child: child,
    );
  }
}