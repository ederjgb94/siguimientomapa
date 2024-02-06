import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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

  static const LatLng _sourceLocation = LatLng(22.2784, -97.8645);
  static const LatLng _destinationLocation = LatLng(22.2750, -97.8646);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getPolyline() async {
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
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((LocationData locationData) {
      currentLocation = locationData;
      setState(() {});
    });

    GoogleMapController controller = await _controller.future;
    location.onLocationChanged.listen((LocationData locationData) {
      currentLocation = locationData;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            zoom: 16,
          ),
        ),
      );
      setState(() {});
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyline();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: currentLocation == null
          ? const Text('Cargando')
          : Animarker(
              zoom: 16,
              rippleDuration: const Duration(milliseconds: 1500),
              rippleRadius: 0,
              useRotation: true,
              runExpressAfter: 0,
              angleThreshold: 0,
              rippleColor: Colors.green,
              // curve: Curves.bounceInOut,
              duration: const Duration(milliseconds: 500),
              markers: {
                RippleMarker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                ),
                const Marker(
                  markerId: MarkerId('source'),
                  position: _sourceLocation,
                  // ripple: true,
                ),
                const Marker(
                  markerId: MarkerId('destination'),
                  position: _destinationLocation,
                  // ripple: true,
                ),
              },
              mapId: _controller.future.then<int>((value) => value.mapId),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                  zoom: 16,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    color: Colors.teal,
                    points: polylineCoordinates,
                    width: 5,
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
    );
  }
}
