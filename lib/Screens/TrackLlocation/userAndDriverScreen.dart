
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../Helper/Constant.dart';



class UserMapScreen extends StatefulWidget {
  String? driverId,addressId,sellerId,status;
  String?userlat;
  String?userlong;
  UserMapScreen({
    this.driverId,
    this.addressId,
    this.sellerId,
    this.status,
    this.userlat,
    this.userlong
  });
  @override
  _UserMapScreenState createState() => _UserMapScreenState();
}

class _UserMapScreenState extends State<UserMapScreen> {
  //final DocumentReference documentReference = FirebaseFirestore.instance.collection('92').doc('qPoeXMGDCkuWuiDkBnf0');

  LatLng driverLocation = LatLng(22.7177, 75.8545);
  LatLng userLocation = LatLng(22.7281,  75.8042);

  BitmapDescriptor? myIcon ;
  bool isLoading= true;

  List<LatLng> routeCoordinates = [];

  List<Polyline> polyLines = [];

   double bearing  = 0.0;
  double? dNewLat = 0.0 ;
  double? dNewLong = 0.0 ;
  double userLat = 0.0 ;
  double userLong = 0.0 ;


  late Timer _timer;
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
            polylines = {};
            markers = {};
            getUserCurrentLocation();

            print("TIMERRR CALLED");
            _addMarker(
                LatLng(userLat, userLong),
                "start",
                BitmapDescriptor.defaultMarkerWithHue(90),false
            );
            _addMarker(
              LatLng(dNewLat!, dNewLong!),
              "destination",
              BitmapDescriptor.defaultMarkerWithHue(90),false
            );
            _getPolyline();

    });
  }
  getLatLongApi() async {
    setState(() {
    isLoading =true;    });
    var headers = {
      'Cookie': 'ci_session=7180d0f1d25ed806795e94e0a87cf9ea327dd73e'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}get_drop_lat_lang'));
    request.fields.addAll({
      'address_id':widget.addressId.toString(),
      'driver_id':widget.driverId.toString(),
      'store_id':widget.sellerId.toString()
    });
    print('____Som______${request.fields}_________');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result  =  await response.stream.bytesToString();
      var finalResult = jsonDecode(result);

      userLat =  double.parse(finalResult['drop_lat_lang']['latitude'].toString());
      userLong =  double.parse(finalResult['drop_lat_lang']['longitude'].toString());
      userLocation = LatLng(userLat, userLong);
      _getPolyline();
      _addMarker(
        LatLng(userLat, userLong),
        "origin",
        BitmapDescriptor.defaultMarker,true
      );

      // Add destination marker
      // _addMarker(
      //   LatLng(dNewLat, dNewLong),
      //   "destination",
      //   BitmapDescriptor.defaultMarkerWithHue(90),false
      // );
     // init();
    }

    else {
      print(response.reasonPhrase);
    }
    setState(() {
      isLoading =false;    });

  }

  callApis() async{
  await  getLatLongApi();
  }

  @override
  void initState() {
    super.initState();
    _getAddressFromLatLng();
    callApis();

    _startTimer();


    userLocation = LatLng(double.parse(userLat.toString() ?? '0.0'),double.parse(userLong.toString() ?? '0.0'));
    // _startTimer();
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(5, 5)), 'assets/images/PNG/scooter.png')
        .then((onValue) {
      myIcon = onValue;
    });

  }
  double lat = 0.0;
  double long = 0.0;
  Position? currentLocation;
  String? _currentAddress;
  Future getUserCurrentLocation() async {
    var status = await Permission.location.request();
    if(status.isDenied) {
      // setSnackbar1("Permision is requiresd");
    }else if(status.isGranted){
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) {
        if (mounted)
          setState(() {
            currentLocation = position;
            dNewLat = currentLocation?.latitude;
            dNewLong = currentLocation?.longitude;

            print('_____homeLong______${dNewLat}______${dNewLong}____');
          });
      });
     // print("LOCATION===" +currentLocation.toString());
    } else if(status.isPermanentlyDenied) {
     //openAppSettings();
    }
  }

  _getAddressFromLatLng() async {
    await getUserCurrentLocation().then((_) async {
      try {
        print("Addressss function");
        List<Placemark> p = await placemarkFromCoordinates(currentLocation!.latitude, currentLocation!.longitude);
        Placemark place = p[0];
        setState(() {
          // _currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
          // cityName = "${place.locality}";
          // print("-------------------?${cityName}");
        });
      } catch (e) {
        print('errorrrrrrr ${e}');
      }
    });
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor,bool foruser) {
    MarkerId markerId = MarkerId(id);

    Marker marker =
    Marker(markerId: markerId, icon:foruser?BitmapDescriptor.defaultMarker: myIcon ?? BitmapDescriptor.defaultMarker, position: position);
    markers[markerId] = marker;
  }


  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = {};
  static final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(22.7500894, 75.9001985),
    zoom: 12,
  );
  init() async{
    var encodedPoly = await getRouteCoordinates(
        LatLng(dNewLat!,  dNewLong!),
        // const LatLng(22.7281,  75.8042));
        LatLng(double.parse(userLat.toString() ??  '0.0'),double.parse(userLong.toString() ?? '0.0')));

    polyLines.add(Polyline(
        polylineId: const PolylineId("1"), //pass any string here
        width: 7,
        geodesic: true,
        points: convertToLatLng(decodePoly(encodedPoly)),
        color: Colors.red));

    setState(() {

    });
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

  void _getPolyline() async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDPsdTq-a4AHYHSNvQsdAlZgWvRu11T9pM",
      PointLatLng(userLat, userLong),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //     onPressed: (){
      //       init();
      //     },
      //     child: const Icon(Icons.directions)),
        body:


         isLoading?Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,

            child: Center(child: CircularProgressIndicator())):
        GoogleMap(
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
    );
  }


  static List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
    // "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=AIzaSyDi_XlHtopewZHtpWWxIO-EQ7mCegHr5o0";
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=AIzaSyDPsdTq-a4AHYHSNvQsdAlZgWvRu11T9pM";
    http.Response response = await http.get(Uri.parse(url));
    print(url);
    Map values = jsonDecode(response.body);
    print("Predictions " + values.toString());
    return values["routes"][0]["overview_polyline"]["points"];
  }


  static List decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = [];
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      // if value is negative then bitwise not the value /
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }


  double getBearing(LatLng begin, LatLng end) {

    double lat = (begin.latitude - end.latitude).abs();

    double lng = (begin.longitude - end.longitude).abs();



    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {

      return (atan(lng / lat) * (180 / pi));

    } else if (begin.latitude >= end.latitude && begin.longitude < end.longitude) {

      return (90 - (atan(lng / lat) * (180 / pi))) + 90;

    } else if (begin.latitude >= end.latitude && begin.longitude >= end.longitude) {

      return (atan(lng / lat) * (180 / pi)) + 180;

    } else if (begin.latitude < end.latitude && begin.longitude >= end.longitude) {

      return (90 - (atan(lng / lat) * (180 / pi))) + 270;

    }

    return -1;

  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }
}
