// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:hojayegadriverapp/Helper/api.path.dart';
// import 'package:hojayegadriverapp/Screen/HomeScreen.dart';
// import 'package:hojayegadriverapp/Screen/PickupLocation.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Helper/color.dart';
// import '../Model/CurrentorderModel.dart';
// import '../Model/GetPlaceOrdersModel.dart';
// import '../Model/GetProfileModel.dart';
//
// class PickUp extends StatefulWidget {
//   const PickUp({Key? key}) : super(key: key);
//
//   @override
//   State<PickUp> createState() => _PickUpState();
// }
//
// class _PickUpState extends State<PickUp> {
//
//   @override
//   void initState() {
//     /// add origin marker origin marker
//     drivers();
//     _addMarker(
//       LatLng(_originLatitude, _originLongitude),
//       "origin",
//       BitmapDescriptor.defaultMarker,
//     );
//
//     // Add destination marker
//     _addMarker(
//       LatLng(_destLatitude, _destLongitude),
//       "destination",
//       BitmapDescriptor.defaultMarkerWithHue(90),
//     );
//     _startTimer();
//     _getPolyline();
//     getDriverProfile();
//     super.initState();
//     placeOrder();
//     _timer.cancel();
//   }
//
//   drivers() async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     driver_id = prefs.getString('driver_id');
//     print("driver id iss innn ${driver_id}");
//   }
//
//   GetPlaceOrdersModel? placeOrdersModel;
//   placeOrder() async {
//     var headers = {
//       'Cookie': 'ci_session=d8459342063575db9be8014dc1903802af731b37'
//     };
//     var request = http.MultipartRequest('POST', Uri.parse(ApiServicves.getPlaceOrder));
//     request.fields.addAll({
//       'id': driver_id.toString()
//     });
//     request.headers.addAll(headers);
//     http.StreamedResponse response = await request.send();
//     if (response.statusCode == 200) {
//       var finalResponse = await response.stream.bytesToString();
//       final finalResult = GetPlaceOrdersModel.fromJson(json.decode(finalResponse));
//       print("responseeee $finalResponse");
//       setState(() {
//         placeOrdersModel = finalResult;
//       });
//     }
//     else {
//       print(response.reasonPhrase);
//     }
//   }
//
//   double dNewLat = 0.0 ;
//   double dNewLong = 0.0 ;
//   late double bearing ;
//   String? driver_id;
//
//   CollectionReference collectionRef=FirebaseFirestore.instance.collection("driverlocation");
//   LatLng driverLocation = LatLng(22.7177, 75.8545);
//   LatLng userLocation = LatLng(22.7281,  75.8042);
//
//   Future<void> getdatadriverData() async {
//     try {
//       DocumentSnapshot document = await collectionRef.doc('${driver_id}').get();
//       if (document.exists) {
//         dNewLat = document.get('homelat');
//         dNewLong = document.get('homeLong');
//         driverLocation = LatLng(dNewLat, dNewLong);
//         bearing = getBearing( LatLng(dNewLat, dNewLong), LatLng(double.parse(homelat ?? '0.0'),double.parse(homeLong ?? '0.0')));
//         print('latitute is herer ${dNewLat}_______');
//         print('longtitute is herer ${dNewLong}_______');
//         setState(() {});
//       }
//     } catch (e) {
//     }
//   }
//
//   double getBearing(LatLng begin, LatLng end) {
//     double lat = (begin.latitude - end.latitude).abs();
//     double lng = (begin.longitude - end.longitude).abs();
//
//     if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
//       return (atan(lng / lat) * (180 / pi));
//     } else if (begin.latitude >= end.latitude && begin.longitude < end.longitude) {
//       return (90 - (atan(lng / lat) * (180 / pi))) + 90;
//     } else if (begin.latitude >= end.latitude && begin.longitude >= end.longitude) {
//       return (atan(lng / lat) * (180 / pi)) + 180;
//     } else if (begin.latitude < end.latitude && begin.longitude >= end.longitude) {
//       return (90 - (atan(lng / lat) * (180 / pi))) + 270;
//     }
//     return -1;
//   }
//
//
//   late Timer _timer;
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       getdatadriverData();
//     });
//   }
//
//   // Starting point latitude
//   double _originLatitude = 22.7500894;
// // Starting point longitude
//   double _originLongitude = 75.9001985;
// // Destination latitude
//   double _destLatitude = 22.6929493;
// // Destination Longitude
//   double _destLongitude = 75.862354;
// // Markers to show points on the map
//   Map<MarkerId, Marker> markers = {};
//
//   PolylinePoints polylinePoints = PolylinePoints();
//   Map<PolylineId, Polyline> polylines = {};
//
//   // Google Maps controller
//   Completer<GoogleMapController> _controller = Completer();
//   // Configure map position and zoom
//   static final CameraPosition _kGooglePlex = const CameraPosition(
//     target: LatLng(22.7500894, 75.9001985),
//     zoom: 12,
//   );
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: colors.backgroundcolor,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF112c48),
//         title: const Text("Pickup", style: TextStyle(color:  Colors.white),),
//         centerTitle: true,
//         toolbarHeight: 60,
//         elevation: 6,
//         actions: const [
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(
//                   Icons.person,
//                   color: colors.secondary),
//             ),
//           ),
//         ],
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Container(
//               margin: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(4),
//                 color: Colors.white,
//               ),
//               child: InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Icon(Icons.arrow_back, color: colors.primary))
//           ),
//         ),
//       ),
//       body:
//       Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 height: 380,
//                 child: GoogleMap(
//                   mapType: MapType.normal,
//                   initialCameraPosition: _kGooglePlex,
//                   myLocationEnabled: true,
//                   tiltGesturesEnabled: true,
//                   compassEnabled: true,
//                   scrollGesturesEnabled: true,
//                   zoomGesturesEnabled: true,
//                   polylines: Set<Polyline>.of(polylines.values),
//                   markers: Set<Marker>.of(markers.values),
//                   onMapCreated: (GoogleMapController controller) {
//                     _controller.complete(controller);
//                   },
//                 ),
//               ),
//               Positioned(
//                 top: 320,
//                 bottom: 10,
//                 left: 110,
//                 right: 110,
//                 child: Container(
//                   height: 5,
//                   width: 5,
//                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: colors.red),
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (context) => PickupLocvation()));
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 20),
//                       child: Row(
//                         children: const [
//                           Text("Get Started", style: TextStyle(fontSize: 17, fontWeight:  FontWeight.w600, color: colors.white)),
//                           Icon(Icons.arrow_forward, color: Colors.white,)
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                           height: 80,
//                           width: 80,
//                           child: Image.network("https://developmentalphawizz.com/hojayega/uploads/profile_pics/${placeOrdersModel?.data?.first.image}",)),
//                       Column(
//                         children:  [
//                           const Text('5:00PM', style: TextStyle(fontWeight: FontWeight.w600, color: colors.red, fontSize: 15),),
//                           Text("KM = ${placeOrdersModel?.data?.first.km}", style: TextStyle(fontWeight: FontWeight.w600, color: colors.black, fontSize: 15)),
//                           const Text("Ready Food", style: TextStyle(fontWeight: FontWeight.w600, color: colors.black, fontSize: 15))
//                         ],
//                       ),
//                       Container(
//                         height: 55,
//                         width: 95,
//                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: colors.primary),
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 10),
//                           child: Column(
//                             children: const [
//                               Center(child: Text("Online -50Rs.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
//                               Center(child: Text("Drop Client", style: TextStyle(color:  Colors.white, fontWeight: FontWeight.w600),))
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 5,),
//                   Row(
//                     children:  [
//                       const Expanded(child: Text("Address:", style: TextStyle(fontSize: 15, color: colors.primary, fontWeight: FontWeight.w600),)),
//                       Expanded(child: Text("${placeOrdersModel?.data?.first.pickupLocation}", overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(fontSize: 15, color: colors.black, fontWeight: FontWeight.w600),))
//                     ],
//                   ),
//                   SizedBox(height: 5),
//                   Row(
//                     children:  [
//                       const Expanded(child: Text("Phone Number:", style: TextStyle(fontSize: 15, color: colors.primary, fontWeight: FontWeight.w600),),),
//                       Expanded(child: Text("${placeOrdersModel?.data?.first.pickupNumber}", style: TextStyle(fontSize: 15, color: colors.black, fontWeight: FontWeight.w600),),)
//                     ],
//                   ),
//                   SizedBox(height: 5),
//                   Row(
//                     children:  [
//                       const Expanded(child: Text("Region:", style: TextStyle(fontSize: 15, color: colors.primary, fontWeight: FontWeight.w600),),),
//                       Expanded(child: Text("${placeOrdersModel?.data?.first.note}", style: TextStyle(fontSize: 15, color: colors.black, fontWeight: FontWeight.w600),),)
//                     ],
//                   ),
//                   SizedBox(height: 5),
//                   Row(
//                     children:  [
//                       const Expanded(child: Text("Note:", style: TextStyle(fontSize: 15, color: colors.primary, fontWeight: FontWeight.w600),),),
//                       Expanded(child: Text("${placeOrdersModel?.data?.first.note}", style: TextStyle(fontSize: 15, color: colors.black, fontWeight: FontWeight.w600),),)
//                     ],
//                   ),
//                 ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
//     MarkerId markerId = MarkerId(id);
//
//     Marker marker =
//     Marker(markerId: markerId, icon: myIcon ?? BitmapDescriptor.defaultMarker, position: position);
//     markers[markerId] = marker;
//   }
//
//   BitmapDescriptor? myIcon ;
//
//   _addPolyLine(List<LatLng> polylineCoordinates) {
//     PolylineId id = PolylineId("poly");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       points: polylineCoordinates,
//       width: 8,
//     );
//     polylines[id] = polyline;
//     setState(() {});
//   }
//
//   void _getPolyline() async {
//     List<LatLng> polylineCoordinates = [];
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       "AIzaSyCKLIBoAca5ptn9A_1UCHNNrtzI81w2KRk",
//       PointLatLng(_originLatitude, _originLongitude),
//       PointLatLng(_destLatitude, _destLongitude),
//       travelMode: TravelMode.driving,
//     );
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     } else {
//       print(result.errorMessage);
//     }
//     _addPolyLine(polylineCoordinates);
//   }
//
//   LatLng showLocation = const LatLng(26.9351975, 75.7915031);
//
//   Widget _mapLocation(BuildContext context) {
//     return GoogleMap(
//       mapType: MapType.normal,
//       initialCameraPosition: _kGooglePlex,
//       myLocationEnabled: true,
//       tiltGesturesEnabled: true,
//       compassEnabled: true,
//       scrollGesturesEnabled: true,
//       zoomGesturesEnabled: true,
//       polylines: Set<Polyline>.of(polylines.values),
//       markers: Set<Marker>.of(markers.values),
//       onMapCreated: (GoogleMapController controller) {
//         _controller.complete(controller);
//       },
//     );
//   }
// }
