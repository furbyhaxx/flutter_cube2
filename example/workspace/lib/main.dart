// import 'dart:html';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cube/flutter_cube.dart';

import 'controls/workspace_controls.dart';
import 'dart:math' as math;

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
  bool primaryButtonDown = false;
  bool secondaryButtonDown = false;
  bool tertiaryButtonDown = false;

  // How far you can zoom in and out ( OrthographicCamera only )
  final double minZoom = 0;
  final double maxZoom = double.infinity;


  void generateGroundPlaneObject(Object parent) async {
    final Mesh mesh = await generatePlane(width: 50, height: 100);
    // parent.add(Object(name: name, mesh: mesh, backfaceCulling: backfaceCulling));
    // _scene.updateTexture();
    parent.add(Object(name: 'GroundPlane', mesh: mesh, backfaceCulling: false));
  }

  void _zoom(Offset offset) {
    setState(() {

      final double zoomValue = offset.dy * zoomFactor;

      double newZoom = math.max(minZoom, math.min(maxZoom, _scene.camera.zoom += zoomValue));

      _scene.camera.zoom = newZoom;

      // debugPrint("current zoom: $newZoom");

      //
      // print("zoom old = " + _scene.camera.zoom.toString());
      // print("zoom value = " + value.toString());
      // double zoomNew = _scene.camera.zoom;
      // if (_scene.camera.zoom < 1.5) {
      //   zoomNew += value * (zoomFactor * 0.1);
      // } else {
      //   zoomNew += value * zoomFactor;
      // }
      // print("zoomNew = " + zoomNew.toString());
      // _scene.camera.zoom = zoomNew < 0 ? 0 : zoomNew;
      // print("zoom new = " + _scene.camera.zoom.toString());
    });
  }

  void _pan(Offset offset) {
    setState(() {


      final Vector3 panValue = Vector3(offset.dx, offset.dy, _scene.camera.target.z);

      panValue.copyInto(_scene.camera.target);
    });
  }

  void _initScene(Scene scene) {
    _scene = scene;

    // setup camera
    scene.camera.position.x = cameraPosition.x;
    scene.camera.position.y = cameraPosition.y;
    scene.camera.position.z = cameraPosition.z;
    scene.camera.target.x = cameraTarget.x;
    scene.camera.target.y = cameraTarget.y;
    scene.camera.target.z = cameraTarget.z;

    // generateGroundPlaneObject(scene.world);

    _cube = Object(
      scale: Vector3(10.0, 10.0, 10.0),
      backfaceCulling: false,
      // fileName: 'assets/workspace/w20.obj',
      fileName: 'assets/workspace/bunny.obj',
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
      body: WorkspaceControls.orbit(
        onPan: (offset) {
          debugPrint("pan: " + offset.toString());
          _pan(offset);
        },
        onRotate: (offset) {
          // print("rotate: " + offset.toString());
          setState(() {
            print(offset);
            // _angle += (offset.dy * 0.1);
          });
        },
        onZoom: (offset) {_zoom(offset);},
        // onZoom: (offset) {
        //   // print("zoom: " + offset.toString());
        //   setState(() {
        //     // _zoom += (offset.dy * 0.1);
        //     _scene.camera.zoom
        //   });
        // },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xffaddeff),
                        Colors.white,
                      ],
                      stops: [
                        0.0,
                        0.6,
                      ],
                    )
                ),
              ),
            ),
            Positioned.fill(
                child: Cube(
                  onSceneCreated: _initScene,
                  interactive: false,
                ),
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
