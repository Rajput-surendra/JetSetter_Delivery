import 'dart:async';
import 'dart:convert';
import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/push_notification_service.dart';
import 'package:deliveryboy_multivendor/Widget/setSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Localization/Language_Constant.dart';
import '../../Provider/SettingsProvider.dart';
import '../../Provider/homeProvider.dart';
import '../../Widget/desing.dart';
import '../../Widget/networkAvailablity.dart';
import '../../Widget/noNetwork.dart';
import '../../Widget/parameterString.dart';
import '../../Widget/translateVariable.dart';
import '../../Widget/validation.dart';
import 'Widget/DetailHeader.dart';
import 'Widget/orderIteam.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

SettingProvider? settingProvider;
HomeProvider? homeProvider;
int currentSelected = 0;

class StateHome extends State<Home> with TickerProviderStateMixin {
  update() {
    setState(() {
      _refresh();
    });
  }

  setStateNow() {
    setState(() {});
  }

  DateTime? currentBackPressTime;

//==============================================================================
//============================= For Animation ==================================

  getSaveDetail() async {
    String getlng = await settingProvider!.getPrefrence(LAGUAGE_CODE) ?? '';

    homeProvider!.selectLan =
        homeProvider!.langCode.indexOf(getlng == '' ? "en" : getlng);
  }

  Future<bool> onWillPopScope() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar('Press back again to Exit', context);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    _startTimer();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    settingProvider = Provider.of<SettingProvider>(context, listen: false);
    homeProvider!.offset = 0;
    homeProvider!.total = 0;
    currentSelected = 0;
    homeProvider!.isLoading = true;
    homeProvider!.isLoadingItems = true;
    homeProvider!.orderList.clear();
    homeProvider!.getSetting(context);
    homeProvider!.getCurrentOrder(setStateNow, context, lat, long);
    homeProvider!.getUserDetail(setStateNow, context);
    final pushNotificationService = PushNotificationService(context: context);
    pushNotificationService.initialise();
    homeProvider!.buttonController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    homeProvider!.buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: homeProvider!.buttonController!,
        curve: Interval(
          0.0,
          0.150,
        ),
      ),
    );
    homeProvider!.controller.addListener(_scrollListener);

    super.initState();
  }

  var lat = "";
  var long = "";

  Position? currentLocation;

  Future getUserCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
    } else if (status.isGranted) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((position) {
        if (mounted)
          setState(() {
            currentLocation = position;
            lat = currentLocation!.latitude.toString();
            long = currentLocation!.longitude.toString();
          });
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('Lat', lat.toString());
      prefs.setString('Lon', long.toString());
      driverTrack(lat, long);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  late Timer timer;

  void _startTimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    venderId = prefs.getString('venderId');
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await getUserCurrentLocation();
    });
  }

  var venderId;
  // @override
  // void dispose() {
  //   _timer.cancel();
  //
  //   super.dispose();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: homeProvider!.scaffoldKey,
        backgroundColor: lightWhite,
        body: WillPopScope(
          onWillPop: onWillPopScope,
          child: isNetworkAvail
              ?
              // homeProvider!.isLoading || supportedLocale == null
              //         ? const ShimmerEffect()
              //         :
              RefreshIndicator(
                  key: homeProvider!.refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    controller: homeProvider!.controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [grad1Color, grad2Color],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0, 1],
                              tileMode: TileMode.clamp,
                            ),
                          ),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: SafeArea(
                            child: Stack(
                              children: [
                                Opacity(
                                  opacity: 0.17000000178813934,
                                  child: Container(
                                    width: deviceWidth,
                                    height: 1,
                                    decoration: const BoxDecoration(
                                      color: white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 800,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      top: 9.0,
                                      start: 15,
                                      end: 15,
                                    ),
                                    child: Text(
                                      "Welcome, $CUR_USERNAME",
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        color: white,
                                        fontSize: textFontSize16,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.directional(
                                  textDirection: Directionality.of(context),
                                  top: 64,
                                  end: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: lightWhite,
                                    ),
                                    height: 124,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ),
                                Positioned.directional(
                                  textDirection: Directionality.of(context),
                                  top: 38,
                                  end: 15,
                                  start: 15,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              circularBorderRadius15)),
                                      color: white,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: blarColor,
                                          offset: Offset(0, 0),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    height: 130,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                                .only(
                                                            top: 18.0,
                                                            bottom: 15.0,
                                                            start: 18.0),
                                                    child: SvgPicture.asset(
                                                      DesignConfiguration
                                                          .setSvgPath(
                                                              'Balance'),
                                                      width: 30,
                                                      height: 30,
                                                      colorFilter:
                                                          const ColorFilter
                                                                  .mode(primary,
                                                              BlendMode.srcIn),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .only(
                                                      start: 18.0,
                                                      bottom: 10.0,
                                                    ),
                                                    child: Text(
                                                        getTranslated(
                                                            context, BAL_LBL)!,
                                                        style: const TextStyle(
                                                            color: black,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                "PlusJakartaSans",
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize:
                                                                textFontSize14),
                                                        textAlign:
                                                            TextAlign.left),
                                                  ),
                                                  CUR_BALANCE == null
                                                      ? Center(
                                                          child:
                                                              CircularProgressIndicator())
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .only(
                                                            start: 18.0,
                                                            bottom: 10.0,
                                                          ),
                                                          child: Text(
                                                              DesignConfiguration
                                                                  .getPriceFormat(
                                                                      context,
                                                                      double.parse(
                                                                          CUR_BALANCE))!,
                                                              style: const TextStyle(
                                                                  color: black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontFamily:
                                                                      "PlusJakartaSans",
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                  fontSize:
                                                                      textFontSize16),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Opacity(
                                          opacity: 0.05000000074505806,
                                          child: Container(
                                              width: 1,
                                              height: 120,
                                              decoration: const BoxDecoration(
                                                  color: white30)),
                                        ),
                                        // Expanded(
                                        //   child: Column(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.center,
                                        //     children: [
                                        //       Column(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment
                                        //                 .center,
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment
                                        //                 .center,
                                        //         children: [
                                        //           Padding(
                                        //             padding:
                                        //                 const EdgeInsetsDirectional
                                        //                         .only(
                                        //                     top: 18.0,
                                        //                     bottom: 15.0,
                                        //                     start: 18.0),
                                        //             child: SvgPicture.asset(
                                        //               DesignConfiguration
                                        //                   .setSvgPath(
                                        //                       'Report'),
                                        //               width: 30,
                                        //               height: 30,
                                        //               colorFilter:
                                        //                   const ColorFilter
                                        //                           .mode(
                                        //                       primary,
                                        //                       BlendMode
                                        //                           .srcIn),
                                        //             ),
                                        //           ),
                                        //           Padding(
                                        //             padding:
                                        //                 const EdgeInsetsDirectional
                                        //                     .only(
                                        //               start: 18.0,
                                        //               bottom: 10.0,
                                        //             ),
                                        //             child: Text(
                                        //                 getTranslated(
                                        //                     context,
                                        //                     BONUS_LBL)!,
                                        //                 style: const TextStyle(
                                        //                     color: black,
                                        //                     fontWeight:
                                        //                         FontWeight
                                        //                             .w400,
                                        //                     fontFamily:
                                        //                         "PlusJakartaSans",
                                        //                     fontStyle:
                                        //                         FontStyle
                                        //                             .normal,
                                        //                     fontSize:
                                        //                         textFontSize14),
                                        //                 textAlign:
                                        //                     TextAlign.left),
                                        //           ),
                                        //           Padding(
                                        //             padding:
                                        //                 const EdgeInsetsDirectional
                                        //                     .only(
                                        //               start: 18.0,
                                        //               bottom: 10.0,
                                        //             ),
                                        //             child: Text(CUR_BONUS!,
                                        //                 style: const TextStyle(
                                        //                     color: black,
                                        //                     fontWeight:
                                        //                         FontWeight
                                        //                             .w700,
                                        //                     fontFamily:
                                        //                         "PlusJakartaSans",
                                        //                     fontStyle:
                                        //                         FontStyle
                                        //                             .normal,
                                        //                     fontSize:
                                        //                         textFontSize16),
                                        //                 textAlign:
                                        //                     TextAlign.left),
                                        //           )
                                        //         ],
                                        //       ),
                                        //     ],
                                        //   ),
                                        // )

                                        // item.itemList![0].activeStatus==PLACED?!loading?Container(
                                        //  // margin: EdgeInsets.symmetric(horizontal: 4.44.w,vertical: 1.5.h)
                                        //   child: Row(
                                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        //     children: [
                                        //       InkWell(
                                        //         onTap: (){
                                        //           updateOrder(
                                        //             item,
                                        //             CANCLED,
                                        //             updateOrderItemApi,
                                        //             item!.id,
                                        //             true,
                                        //             0,
                                        //           );
                                        //           //acceptStatus(item!.id, "2");
                                        //         },
                                        //         child: Container(
                                        //           width: 32.77.w,
                                        //           height: 4.92.h,
                                        //           margin: EdgeInsets.only(right: 2.w),
                                        //           decoration: boxDecoration(
                                        //             radius: 6.0,
                                        //             bgColor:AppColor().colorTextThird(),
                                        //           ),
                                        //           child: Center(
                                        //             child: text(
                                        //               "Reject",
                                        //               textColor: AppColor().colorBg1(),
                                        //               fontSize: 10.sp,
                                        //               fontFamily: fontRegular,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //       InkWell(
                                        //         onTap: (){
                                        //           updateOrder(item,
                                        //             PROCESSED,
                                        //             updateOrderItemApi,
                                        //             item!.id,
                                        //             true,
                                        //             0,
                                        //           );
                                        //         },
                                        //         child: Container(
                                        //           width: 32,
                                        //           height: 60,
                                        //           margin: EdgeInsets.only(right: 2),
                                        //           decoration: BoxDecoration(
                                        //             borderRadius: BorderRadius.circular(10)
                                        //             // radius: 6.0,
                                        //             // //color:AppColor().colorPrimaryDark(),
                                        //             // bgColor: Color(0xff13CE3F),
                                        //           ),
                                        //           child: Center(
                                        //             child: Text(
                                        //               "Accept",
                                        //               // textColor: AppColor().colorBg1(),
                                        //               // fontSize: 10.sp,
                                        //               // fontFamily: fontRegular,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ):Center(child: CircularProgressIndicator(),):SizedBox()
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        DetailHeader(
                          update: setStateNow,
                          lat: lat,
                          long: long,
                        ),
                        homeProvider!.orderList.isEmpty ||
                                homeProvider!.isLoading
                            ? homeProvider!.isLoadingItems
                                ? Container(
                                    height: deviceHeight * 0.5,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Container(
                                    height: deviceHeight * 0.5,
                                    child: Center(
                                      child: Text(
                                        getTranslated(context, noItem)!,
                                      ),
                                    ),
                                  )
                            : MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: (homeProvider!.offset! <
                                          homeProvider!.total!)
                                      ? homeProvider!.orderList.length + 1
                                      : homeProvider!.orderList.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return (index ==
                                                homeProvider!
                                                    .orderList.length &&
                                            homeProvider!.isLoadingmore)
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : OrderIteam(
                                            lodding: isloding,
                                            index: index,
                                            update: update,
                                            onTopReject: () {
                                              acceptRejectApi(homeProvider!.orderList[index].id, "reject");
                                            },
                                            onTop: () {
                                              acceptRejectApi(homeProvider!.orderList[index].id, "accept");
                                            },
                                          );
                                  },
                                ),
                              )
                      ],
                    ),
                  ),
                )
              : noInternet(
                  context,
                  setStateNoInternate,
                  homeProvider!.buttonSqueezeanimation,
                  homeProvider!.buttonController,
                ),
        ));
  }

  driverTrack(String lat1, long1) async {
    var headers = {
      'Cookie': 'ci_session=869a3e0261b7d606f44a68c823cacaacd8f8fdf2'
    };
    var request =
        http.MultipartRequest('POST', Uri.parse('${baseUrl}update_lat_lang'));
    request.fields.addAll({
      'user_id': CUR_USERID.toString(),
      'lat': "${lat1.toString()}",
      'lang': "${long1.toString()}"
    });
    print('__________${request.fields}_________');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  bool isloding = false;
  acceptRejectApi(String? oId, status) async {
    var headers = {
      'Cookie': 'ci_session=472562483f3cb4d47d07dafc1d799a027c31eec7'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}accept_reject_order'));
    print('____Som______${request}_________');
    request.fields.addAll({
      'user_id': CUR_USERID.toString(),
      'order_id': oId.toString(),
      'status': status
    });
   print('____Som___request.fields___${request.fields}_________');
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      _refresh();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${finalResult['message']}')));
    } else {
      print(response.reasonPhrase);
    }
  }

  _scrollListener() {
    if (homeProvider!.controller.offset >=
            homeProvider!.controller.position.maxScrollExtent &&
        !homeProvider!.controller.position.outOfRange) {
      if (this.mounted) {
        setState(
          () {
            homeProvider!.isLoadingmore = true;

            if (homeProvider!.offset! < homeProvider!.total!)
              homeProvider!.getOrder(setStateNow, context);
            ;
          },
        );
      }
    }
  }

  @override
  void dispose() {
    homeProvider!.passwordController.dispose();
    homeProvider!.buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _refresh() {
    homeProvider!.offset = 0;
    homeProvider!.total = 0;
    homeProvider!.orderList.clear();
    setState(
      () {
        homeProvider!.isLoading = true;
        homeProvider!.isLoadingItems = true;
      },
    );
    homeProvider!.orderList.clear();
    homeProvider!.getSetting(context);
    if (homeProvider!.selectedIndex == 0) {
      return homeProvider!.getCurrentOrder(setStateNow, context, lat, long);
    } else {
      if (homeProvider!.selectedIndex == 2) {
        homeProvider!.activeStatus = "shipped";
      } else if (homeProvider!.selectedIndex == 1) {
        homeProvider!.activeStatus = "";
      } else if (homeProvider!.selectedIndex == 3) {
        homeProvider!.activeStatus = "delivered";
      }

      return homeProvider!.getOrder(setStateNow, context);
    }
  }

  Future<void> _playAnimation() async {
    try {
      await homeProvider!.buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          homeProvider!.getSetting(context);
          homeProvider!.getOrder(setStateNow, context);
        } else {
          await homeProvider!.buttonController!.reverse();
          setState(
            () {},
          );
        }
      },
    );
  }
}
