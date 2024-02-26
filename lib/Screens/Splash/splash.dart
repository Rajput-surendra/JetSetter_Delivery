import 'dart:async';
import 'package:deliveryboy_multivendor/Widget/desing.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/push_notification_service.dart';
import '../../Provider/SettingsProvider.dart';
import '../../Widget/parameterString.dart';
import '../../Widget/systemChromeSettings.dart';
import '../Authentication/Login/LoginScreen.dart';
import '../Authentication/send_otp.dart';
import '../Deshboard/Deshboard.dart';

//splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isFirstTime = false;
  @override
  void initState() {
    // FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    //   alert: true, // Required to display a heads up notification
    //   badge: true,
    //   sound: true,
    // );
   // FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
    SystemChromeSettings.setSystemButtomNavigationonlyTop();
    SystemChromeSettings.setSystemUIOverlayStyleWithLightBrightNessStyle();
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 0),
              child: Image.asset('assets/images/PNG/splashlogo.png',height:350,width:350,)
          ),
          Image.asset(
            DesignConfiguration.setPngPath('doodle'),
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }

  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  Future<void> navigationPage() async {
    SettingProvider settingProvider =
        Provider.of<SettingProvider>(context, listen: false);
    isFirstTime = await settingProvider.getPrefrenceBool(isLogin);
    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => Dashboard(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => Login(),
        ),
      );
    }
  }

  @override
  void dispose() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    if (isFirstTime) {
      SystemChromeSettings.setSystemUIOverlayStyleWithLightBrightNessStyle();
    } else {
      SystemChromeSettings.setSystemUIOverlayStyleWithDarkBrightNessStyle();
    }
    super.dispose();
  }
}
