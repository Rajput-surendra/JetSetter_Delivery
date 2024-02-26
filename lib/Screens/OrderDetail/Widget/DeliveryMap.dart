import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryAddMap extends StatefulWidget {
  final String DeliveryAdd;

  const DeliveryAddMap({Key? key, required this.DeliveryAdd}) : super(key: key);
  @override
  State<DeliveryAddMap> createState() => _DeliveryAddMapState();
}

class _DeliveryAddMapState extends State<DeliveryAddMap> {
  var custLat, custLon;
  Position? currentLocation;
  double? dNewLat = 0.0;
  double? dNewLong = 0.0;
  double userLat = 0.0;
  double userLong = 0.0;
  double sellerLat = 0.0;
  double sellerLong = 0.0;
  BitmapDescriptor? myIcon;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Completer<GoogleMapController> _controller = Completer();

  getLatLong() async {
    try {
      List<Location> locations = await locationFromAddress(widget.DeliveryAdd);
      custLat = locations.first.latitude;
      custLon = locations.first.longitude;
      print("custLat: $custLat, custLon: $custLon");
      await getUserCurrentLocation();
    } catch (e, stackTrace) {
      print(stackTrace);
      throw Exception(e);
    }
  }

  late Timer _timer;
  Future getUserCurrentLocation() async {
    polylines = {};
    markers = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dNewLat = double.parse(prefs.getString('Lat').toString());
    dNewLong = double.parse(prefs.getString('Lon').toString());
    print("dNewLat: $dNewLat, dNewLong: $dNewLong");

    print("TIMERRR CALLED");
    _addMarker(LatLng(custLat, custLon), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90), false);
    _addMarker(LatLng(dNewLat!, dNewLong!), "start",
        BitmapDescriptor.defaultMarkerWithHue(90), false);
    _getPolyline();
    //call update  location api
  }

  void _getPolyline() async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDPsdTq-a4AHYHSNvQsdAlZgWvRu11T9pM",
      PointLatLng(custLat, custLon),
      PointLatLng(dNewLat!, dNewLong!),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _addMarker(
      LatLng position, String id, BitmapDescriptor descriptor, bool foruser) {
    MarkerId markerId = MarkerId(id);

    Marker marker = Marker(
        markerId: markerId,
        icon: foruser
            ? BitmapDescriptor.defaultMarker
            : myIcon ?? BitmapDescriptor.defaultMarker,
        position: position);
    markers[markerId] = marker;
  }

  @override
  void initState() {
    getLatLong();

    super.initState();
  }

  static final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(22.7500894, 75.9001985),
    zoom: 12,
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          tiltGesturesEnabled: true,
          compassEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          polylines: Set<Polyline>.of(polylines.values),
          markers: Set<Marker>.of(markers.values),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
