import 'package:flutter/material.dart';
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
      body: MouseGestureDetector(
        // onFocusChange: (bool status) {
        //   setState(() {
        //     _hasFocus = status;
        //   });
        // },
        onIncrementCallback: (int count) {
          print("count changed to -> " + count.toString());
        },
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

class IncrementIntent extends Intent {
  const IncrementIntent();
}

class DecrementIntent extends Intent {
  const DecrementIntent();
}

typedef OnIncrementCallback = void Function(int value);
//
// class MouseGestureDetector extends StatelessWidget {
//   MouseGestureDetector({
//     required this.child,
//     Key? key,
//     this.autofocus = false,
//     this.onFocusChange,
//     this.onIncrementCallback,
//   }) : super(key: key);
//
//   final Widget child;
//
//   final bool autofocus;
//
//   final ValueChanged<bool>? onFocusChange;
//
//   final OnIncrementCallback? onIncrementCallback;
//
//   int count = 0;
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   return Focus(
//   //     autofocus: autofocus,
//   //     onFocusChange: onFocusChange,
//   //     child: Shortcuts(
//   //       shortcuts: <ShortcutActivator, Intent>{
//   //         LogicalKeySet(LogicalKeyboardKey.arrowUp): const IncrementIntent(),
//   //         LogicalKeySet(LogicalKeyboardKey.arrowDown): const DecrementIntent(),
//   //       },
//   //       child: Actions(
//   //         actions: <Type, Action<Intent>>{
//   //           IncrementIntent: CallbackAction<IncrementIntent>(
//   //             onInvoke: (IncrementIntent intent) => () {
//   //               count = count + 1;
//   //               if(onIncrementCallback != null) {
//   //
//   //                 onIncrementCallback!(count);
//   //               }
//   //             },
//   //           ),
//   //           DecrementIntent: CallbackAction<DecrementIntent>(
//   //             onInvoke: (DecrementIntent intent) => () {
//   //               count = count - 1;
//   //               if(onIncrementCallback != null) {
//   //                 onIncrementCallback!(count);
//   //               }
//   //             },
//   //           ),
//   //         },
//   //         child: Focus(
//   //           autofocus: true,
//   //           child: MouseRegion(
//   //             child: Listener(
//   //               child: child,
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Shortcuts(
//       shortcuts: <ShortcutActivator, Intent>{
//         LogicalKeySet(LogicalKeyboardKey.arrowUp): const IncrementIntent(),
//         LogicalKeySet(LogicalKeyboardKey.arrowDown): const DecrementIntent(),
//       },
//       child: Actions(
//         actions: <Type, Action<Intent>>{
//           IncrementIntent: CallbackAction<IncrementIntent>(
//             onInvoke: (IncrementIntent intent) => () {
//               count = count + 1;
//               if(onIncrementCallback != null) {
//                 onIncrementCallback!(count);
//               }
//             },
//           ),
//           DecrementIntent: CallbackAction<DecrementIntent>(
//             onInvoke: (DecrementIntent intent) => () {
//               count = count - 1;
//               if(onIncrementCallback != null) {
//                 onIncrementCallback!(count);
//               }
//             },
//           ),
//         },
//         child: Focus(
//           autofocus: true,
//           child: Column(
//             children: <Widget>[
//               const Text('Add to the counter by pressing the up arrow key'),
//               const Text(
//                   'Subtract from the counter by pressing the down arrow key'),
//               Text('count: $count'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class MouseGestureDetector extends StatefulWidget {
  const MouseGestureDetector({
    required this.child,
    this.autofocus = false,
    this.onFocusChange,
    this.onIncrementCallback,
    Key? key,
  }) : super(key: key);

  final Widget child;

  final bool autofocus;

  final ValueChanged<bool>? onFocusChange;

  final OnIncrementCallback? onIncrementCallback;

  @override
  State<MouseGestureDetector> createState() => _MouseGestureDetectorState();
}

class _MouseGestureDetectorState extends State<MouseGestureDetector> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const IncrementIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const DecrementIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          IncrementIntent: CallbackAction<IncrementIntent>(
            onInvoke: (IncrementIntent intent) => setState(() {
              count = count + 1;
              if(widget.onIncrementCallback != null) {
                widget.onIncrementCallback!(count);
              }
            }),
          ),
          DecrementIntent: CallbackAction<DecrementIntent>(
            onInvoke: (DecrementIntent intent) => setState(() {
              count = count - 1;
            }),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Column(
            children: <Widget>[
              const Text('Add to the counter by pressing the up arrow key'),
              const Text(
                  'Subtract from the counter by pressing the down arrow key'),
              Text('count: $count'),
            ],
          ),
        ),
      ),
    );
  }
}
