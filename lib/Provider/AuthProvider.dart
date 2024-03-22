import 'dart:async';
import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/ApiBaseHelper.dart';
import '../Repository/AuthRepository.dart';
import '../Provider/signupProvider.dart';
import '../Screens/Authentication/Login/LoginScreen.dart';
import '../Screens/Authentication/otp_screen.dart';
import '../Widget/api.dart';
import '../Widget/parameterString.dart';
import 'loginProvider.dart';

class AuthenticationProvider extends ChangeNotifier {
  // value for parameter
  String? mobilennumberPara, passwordPara;

  //user data
  String? id, userName, email, mobile;

  // for reset password
  String? newPassword;

  // data
  bool? error;
  String errorMessage = '';

  get mobilenumbervalue => mobilennumberPara;

  setMobileNumber(String? value) {
    mobilennumberPara = value;
    notifyListeners();
  }

  setNewPassword(String? value) {
    newPassword = value;
    notifyListeners();
  }

  setPassword(String? value) {
    passwordPara = value;
    notifyListeners();
  }

  //get System Policies
  Future<Map<String, dynamic>> getLoginData(fId) async {
    try {
      var parameter = {MOBILE: mobilennumberPara, 'fcm_id': fId};

      print("this is a parameter==>$parameter");
      var result = await AuthRepository.fetchLoginData(parameter: parameter);

      errorMessage = result['message'];
      error = result['error'];
      if (!error!) {
        var getdata = result['data'][0];
        id = getdata[ID];
        userName = getdata[USERNAME];
        email = getdata[EMAIL];
        mobile = getdata[MOBILE];
        CUR_USERID = id;
        return result;
      } else {
        return result;
      }
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  Future<void> sendOTP(
      BuildContext context,
      GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
      Function updateNow,
      String? fId,
      mobile1) async {
    var data = {
      Mobile: mobile1,
      //Password: password,
      'device_token': fId
    };
    print('____data______${data}_________');
    ApiBaseHelper().postAPICall(getUserSendOtpApi, data).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        print('_____error_____${error}_________');
        if (!error) {
          // setSnackbarScafold(scaffoldMessengerKey, context, msg!);
          String mobile = getdata["mobile"].toString();
          String otp = getdata["otp"].toString();
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OTPScreen(mobile, otp),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: fontColor,
                ),
              ),
              duration: const Duration(
                milliseconds: 3000,
              ),
              backgroundColor: lightWhite,
              elevation: 1.0,
            ),
          );
          updateNow();
        }
      },
      onError: (error) {
        setSnackbarScafold(scaffoldMessengerKey, context, error.toString());
      },
    );
  }

  //for login
  Future<Map<String, dynamic>> getVerifyUser(String mobile) async {
    try {
      var parameter = {
        MOBILE: mobile,
      };
      print('______sdsdsd____${parameter}_________');
      var result =
          await AuthRepository.fetchverificationData(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  // for reset password
  Future<Map<String, dynamic>> getReset() async {
    try {
      var parameter = {
        MOBILENO: mobilennumberPara,
        NEWPASS: newPassword,
      };

      var result = await AuthRepository.fetchFetchReset(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }
}
