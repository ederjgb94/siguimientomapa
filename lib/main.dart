import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:siguimientomapa/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Pages'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng _sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng _destinationLocation = LatLng(37.33429383, -122.0660055);

  List<LatLng> polylineCoordinates = [];

  Future<Object?>? getPolyline() async {
    polylineCoordinates.clear();
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(_sourceLocation.latitude, _sourceLocation.longitude),
      PointLatLng(
          _destinationLocation.latitude, _destinationLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    return polylineCoordinates;
  }

  @override
  void initState() {
    //getPolyline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: getPolyline(),
          builder: (context, snapshot) {
            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _sourceLocation,
                zoom: 12.5,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.red,
                  points: polylineCoordinates,
                ),
              },
              markers: {
                const Marker(
                  markerId: MarkerId('source'),
                  position: _sourceLocation,
                ),
                const Marker(
                  markerId: MarkerId('destination'),
                  position: _destinationLocation,
                ),
              },
            );
          }),
    );
  }
}
