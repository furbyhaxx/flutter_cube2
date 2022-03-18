// import 'dart:html';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cube/flutter_cube.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cube Workspace Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Cube Workspace Demo'),
      scrollBehavior: MouseScrollBehavior(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Position {
  double x;
  double y;
  double z;

  Position([this.x = 0, this.y = 0, this.z = 0]);

  Position copyWith({double? x, double? y, double? z}) {
    return Position(x ?? this.x, y ?? this.y, z ?? this.z);
  }
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late Scene _scene;
  double _ambient = 0.1;
  double _diffuse = 0.8;
  double _specular = 0.5;
  double _shininess = 0.0;

  Vector3 cameraPosition = Vector3(0, 0, 25);
  Vector3 cameraTarget = Vector3(0, 0, 0);

  Object? _groundPlane;
  Object? _cube;

  double zoomFactor = 0.1;

  // mouse
  Position mousePosition = Position();
  bool primaryButtonDown = false;
  bool secondaryButtonDown = false;
  bool tertiaryButtonDown = false;


  void generateGroundPlaneObject(Object parent) async {
    final Mesh mesh = await generatePlane(width: 50, height: 100);
    // parent.add(Object(name: name, mesh: mesh, backfaceCulling: backfaceCulling));
    // _scene.updateTexture();
    parent.add(Object(name: 'GroundPlane', mesh: mesh, backfaceCulling: false));
  }

  void _zoom(double value) {
    setState(() {
      print("zoom old = " + _scene.camera.zoom.toString());
      print("zoom value = " + value.toString());
      double zoomNew = _scene.camera.zoom;
      if (_scene.camera.zoom < 1.5) {
        zoomNew += value * (zoomFactor * 0.1);
      } else {
        zoomNew += value * zoomFactor;
      }
      print("zoomNew = " + zoomNew.toString());
      _scene.camera.zoom = zoomNew < 0 ? 0 : zoomNew;
      print("zoom new = " + _scene.camera.zoom.toString());
    });
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    scene.camera.position.x = cameraPosition.x;
    scene.camera.position.y = cameraPosition.y;
    scene.camera.position.z = cameraPosition.z;
    scene.camera.target.x = cameraTarget.x;
    scene.camera.target.y = cameraTarget.y;
    scene.camera.target.z = cameraTarget.z;

    generateGroundPlaneObject(scene.world);

    _cube = Object(
      scale: Vector3(1.0, 1.0, 1.0),
      backfaceCulling: false,
      fileName: 'assets/workspace/w20.obj',
      // fileName: 'assets/workspace/w20_ascii.stl',
    );
    scene.light.position.setFrom(Vector3(0, 10, 10));
    scene.light.setColor(Colors.white, _ambient, _diffuse, _specular);
    // _bunny = Object(position: Vector3(0, -1.0, 0), scale: Vector3(10.0, 10.0, 10.0), lighting: true, fileName: 'assets/bunny/bunny.obj');
    // scene.world.add(_bunny!);
    scene.world.add(_cube!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              // child: Cube(
              //   onSceneCreated: _onSceneCreated,
              // ),
              child: MouseRegion(
                onHover: (PointerEvent details) {
                  // x = details.position.dx;
                  // y = details.position.dy;
                  mousePosition.x = details.position.dx;
                  mousePosition.y = details.position.dy;
                  // print("hover");

                  if(tertiaryButtonDown) {
                    // pan
                    print(details);
                    print("pan");

                  }
                },
                child: GestureDetector(
                  // onTertiaryLongPressStart: (LongPressStartDetails details) {
                  //   print(details);
                  // },
                  // onTertiaryLongPress: () {
                  //   print('logn press');
                  // },
                  child: Listener(
                    onPointerDown: (PointerDownEvent event) {
                      switch (event.buttons) {
                        case kPrimaryButton:
                          primaryButtonDown = true;
                          break;
                        case kSecondaryButton:
                          secondaryButtonDown = true;
                          break;
                        case kMiddleMouseButton:
                          tertiaryButtonDown = true;
                          print("middle down");
                          break;
                      }
                      print(event.buttons);
                    },
                    onPointerCancel: (PointerCancelEvent event) {
                      print("c:" + event.buttons.toString());
                    },
                    onPointerUp: (PointerUpEvent event) {
                      print("upo");
                      primaryButtonDown = false;
                      secondaryButtonDown = false;
                      tertiaryButtonDown = false;

                    },
                    onPointerSignal: (PointerSignalEvent event) {
                      if (event is PointerScrollEvent) {
                        // print('x: ${event.position.dx}, y: ${event.position.dy}');
                        // print('scroll delta: ${event.scrollDelta}');
                        PointerScrollEvent e = event as PointerScrollEvent;
                        _zoom(event.scrollDelta.dy);
                        // Offset
                      }
                      if(tertiaryButtonDown) {
                        print(event);
                      }
                      // if(event is PointerDownEvent) {
                      //   PointerDownEvent e = event as PointerDownEvent;
                      //   print(e);
                      // }
                    },
                    child: Cube(
                      onSceneCreated: _onSceneCreated,
                      interactive: false,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.grey,
              height: 125,
            ),
          ],
        ),
      ),
    );
  }
}

Future<Mesh> generatePlane({double width = 100, double height = 100}) async {
  List<Vector3> vertices = [
    Vector3(0, 0, 0),
    Vector3(width, 0, 0),
    Vector3(width, height, 0),
    Vector3(0, height, 0),
  ];
  List<Polygon> indices = [
    Polygon(0, 1, 3),
    Polygon(1, 2, 3),
  ];

  final Mesh mesh = Mesh(
      vertices: vertices,
      // texcoords: texcoords,
      indices: indices,
      // texture: texture,
      // texturePath: texturePath,
      // colors: [
      //   Colors.red,
      //   Colors.red,
      // ],
      material: Materials.emerald,
      name: "GroundPlane");
  return mesh;
}

/// Custom ScrollBehavior to support scrolling with mouse pan
class MouseScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
