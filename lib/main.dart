import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:marker_icon/marker_icon.dart';
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

  static const LatLng _sourceLocation = LatLng(22.278458, -97.864515);
  static const LatLng _destinationLocation = LatLng(22.275058, -97.864556);
  static const LatLng _ruta2 = LatLng(22.275056, -97.864535);
  static const LatLng _ruta3 = LatLng(22.275940, -97.859392);
  static const LatLng _ruta4 = LatLng(22.278462, -97.864502);

  static const LatLng _paradaPrincipal = LatLng(22.278757, -97.861059);
  static const LatLng _paradaColera = LatLng(22.278201, -97.865356);
  static const LatLng _paradaIngenieria = LatLng(22.276978, -97.865429);
  static const LatLng _paradaDerecho = LatLng(22.275574, -97.865461);
  static const LatLng _paradaArquitectura = LatLng(22.275007, -97.864128);
  static const LatLng _paradaComercio = LatLng(22.275005, -97.862788);
  static const LatLng _paradaGym = LatLng(22.275872, -97.859425);
  static const LatLng _paradaCafeteria = LatLng(22.276978, -97.859392);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  Future<void> addPolyline(source, dest) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(source.latitude, source.longitude),
      PointLatLng(dest.latitude, dest.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
  }

  void getPolyline() async {
    polylineCoordinates.clear();
    await addPolyline(_sourceLocation, _destinationLocation);
    await addPolyline(_ruta2, _ruta3);
    await addPolyline(_ruta3, _ruta4);
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((LocationData locationData) {
      currentLocation = locationData;
      setState(() {});
    });

    // GoogleMapController controller = await _controller.future;
    location.onLocationChanged.listen((LocationData locationData) {
      currentLocation = locationData;
      // controller.animateCamera(
      //   CameraUpdate.newCameraPosition(
      //     CameraPosition(
      //       target: LatLng(
      //         currentLocation!.latitude!,
      //         currentLocation!.longitude!,
      //       ),
      //       zoom: 16,
      //     ),
      //   ),
      // );
      setState(() {});
    });
  }

  getMarkerIcon() async {
    return await MarkerIcon.pictureAsset(
      assetPath: 'assets/bus01.png',
      width: 90,
      height: 90,
    );
  }

  var markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    getPolyline();
    getMarkerIcon().then((value) => markerIcon = value);
    getCurrentLocation();

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
              angleThreshold: -1,
              shouldAnimateCamera: false,
              rippleColor: Colors.green,
              curve: Curves.decelerate,
              duration: const Duration(milliseconds: 500),
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                  icon: markerIcon,
                ),
              },
              mapId: _controller.future.then<int>((value) => value.mapId),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(22.276656, -97.861769),
                  zoom: 16,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    color: Colors.yellow.shade900,
                    points: polylineCoordinates,
                    width: 2,
                  ),
                },
                markers: {
                  RippleMarker(
                    markerId: const MarkerId('paradaPrincipal'),
                    position: _paradaPrincipal,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('paradaColera'),
                    position: _paradaColera,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('paradaIngenieria'),
                    position: _paradaIngenieria,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('paradaDerecho'),
                    position: _paradaDerecho,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('paradaArquitectura'),
                    position: _paradaArquitectura,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('paradaComercio'),
                    position: _paradaComercio,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('paradaGym'),
                    position: _paradaGym,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                  ),
                  // Marker(
                  //   markerId: const MarkerId('paradaCafeteria'),
                  //   position: _paradaCafeteria,
                  //   icon: BitmapDescriptor.defaultMarkerWithHue(
                  //     BitmapDescriptor.hueYellow,
                  //   ),
                  // ),
                },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
    );
  }
}
