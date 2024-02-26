import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/color.dart';
import '../../Helper/constant.dart';
import '../../Provider/SettingsProvider.dart';
import '../../Widget/parameterString.dart';
import '../../Widget/parameterString.dart';
import '../../Widget/setSnackbar.dart';
import '../../Widget/translateVariable.dart';
import '../../Widget/validation.dart';
import '../CashCollection/cash_collection.dart';
import '../Home/Widget/deleteAccountDialog.dart';
import '../Home/Widget/getHeading.dart';
import '../Home/Widget/getLanguageDialog.dart';
import '../Home/Widget/getLogOutDialog.dart';
import '../NotificationList/notification_lIst.dart';
import '../Privacy policy/privacy_policy.dart';
import '../WalletHistory/wallet_history.dart';
import 'package:http/http.dart'as http;

class GetDrawerWidget extends StatefulWidget {
  const GetDrawerWidget({Key? key}) : super(key: key);

  @override
  State<GetDrawerWidget> createState() => _GetDrawerWidgetState();
}

class _GetDrawerWidgetState extends State<GetDrawerWidget> {
  Widget _getDivider() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Divider(
        height: 1,
      ),
    );
  }

  Widget _getDrawerItem(int index, String title, IconData icn) {
    return ListTile(
      dense: true,
      leading: Icon(
        icn,
        color: secondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: black,
          fontSize: textFontSize15,
        ),
      ),
      onTap: () {
        // if (title == getTranslated(context, ChangeLanguage)!) {
        //   LanguageDialog.languageDialog(
        //     context,
        //     setState,
        //   );
        // } else if (title == getTranslated(context, "Delete Account")!) {
        //   DeleteAccountDialog.deleteAccountDailog(context, setState);
        // } else
          if (title == getTranslated(context, NOTIFICATION)) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => NotificationList(),
            ),
          );
        } else if (title == getTranslated(context, LOGOUT)) {
          LogOutDialog.logOutDailog(context);
        } else if (title == getTranslated(context, PRIVACY)) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => PrivacyPolicy(
                title: getTranslated(context, PRIVACY)!,
              ),
            ),
          );
        } else if (title == getTranslated(context, TERM)) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => PrivacyPolicy(
                title: getTranslated(context, TERM)!,
              ),
            ),
          );
        } else if (title == getTranslated(context, WALLET)) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => WalletHistory(
                isBack: true,
              ),
            ),
          );
        }
        //   else if (title == getTranslated(context, CASH_COLL)) {
        //   Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //       builder: (context) => CashCollection(
        //         isBack: true,
        //       ),
        //     ),
        //   );
        // }
      },
    );
  }
  getStatus(int status) async {
    print('__________________');
    var headers = {
      'Cookie': 'ci_session=8380ff83d04889e6ff2ef0c0cd5e47f95872c1d4'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}online_ofline'));
    request.fields.addAll({
      'user_id':"${CUR_USERID}",
      'status':status.toString()
    });
    print('____Som______${request.fields}_________');
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result  = await response.stream.bytesToString();
      var finalResult =  jsonDecode(result);
      print('finalResult__________${finalResult}_________');
      setState(() {

      });
      setSnackbar(finalResult['message'], context);
    }
    else {
      print(response.reasonPhrase);
    }

  }
  getStatus1() async {
    print('__________________');
    var headers = {
      'Cookie': 'ci_session=8380ff83d04889e6ff2ef0c0cd5e47f95872c1d4'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}get_online_status'));
    request.fields.addAll({
      'user_id':"${CUR_USERID}",

    });
    print('____Som___user_id___${request.fields}_________');
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result  = await response.stream.bytesToString();
      var finalResult =  jsonDecode(result);
      print('finalResult__________${finalResult}_________');
      setState(() {
      status=int.parse(finalResult["data"].toString());
      print('____Som______${status}_________');
      });
      setSnackbar(finalResult['message'], context);
    }
    else {
      print(response.reasonPhrase);
    }

  }

  int status = 0;
  @override
  void initState() {
    // TODO: implement initState
    getStatus1();
    super.initState();
  }
   // 0: Offline, 1: Online
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Container(
        color: white,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              GetHeading(update: setState),
              _getDrawerItem(
                7,
                getTranslated(context, WALLET)!,
                Icons.account_balance_wallet_outlined,
              ),
              Row(
                children: [
                  Switch(
                    //activeColor: primary,inactiveThumbColor: secondary,
                    value: status == 1,
                    onChanged: (value) {
                      setState(() {
                        status = value ? 1 : 0;
                        getStatus(status);
                      });
                    },
                  ),
                  status ==  "" ? Center(child: CircularProgressIndicator()): Text(
                    status == 1 ? 'Online' : 'Offline',
                    style: TextStyle(fontSize: 15),
                  ),


                ],
              ),
              // _getDrawerItem(
              //   2,
              //   getTranslated(context, CASH_COLL)!,
              //   Icons.money_outlined,
              // ),
              // _getDrawerItem(
              //   5,
              //   getTranslated(context, ChangeLanguage)!,
              //   Icons.translate,
              // ),
              _getDivider(),
              _getDrawerItem(
                8,
                getTranslated(context, PRIVACY)!,
                Icons.lock_outline,
              ),
              _getDrawerItem(
                9,
                getTranslated(context, TERM)!,
                Icons.speaker_notes_outlined,
              ),
              CUR_USERID == "" || CUR_USERID == null
                  ? Container()
                  : _getDivider(),
              // CUR_USERID == "" || CUR_USERID == null
              //     ? Container()
              //     : _getDrawerItem(13,
              //         getTranslated(context, "Delete Account")!, Icons.delete),
              CUR_USERID == "" || CUR_USERID == null
                  ? Container()
                  : _getDrawerItem(
                      11,
                      getTranslated(context, LOGOUT)!,
                      Icons.input_outlined,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
