import 'package:deliveryboy_multivendor/Screens/Home/home.dart';
import 'package:flutter/material.dart';
import '../../../Helper/color.dart';
import '../../../Helper/constant.dart';

class CommanDesingWidget extends StatelessWidget {
  String title;
  int index;
  Function update;
  String lat;
  String long;
  CommanDesingWidget({
    Key? key,
    required this.index,
    required this.title,
    required this.update,
    required this.lat,
    required this.long,
  }) : super(key: key) {
    // TODO: implement CommanDesingWidget
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        width: 95,
        height: 60,
        decoration: BoxDecoration(
          gradient: currentSelected == index
              ? LinearGradient(
                  colors: [grad1Color, grad2Color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: const [
            BoxShadow(
              color: blarColor,
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
          color: white,
          borderRadius: BorderRadius.all(
            Radius.circular(circularBorderRadius10),
          ),
        ),
        child: InkWell(
          onTap: () {
            homeProvider!.activeStatus =
                index == 1 ? "" : homeProvider!.statusList[index];
            homeProvider!.isLoadingmore = true;
            homeProvider!.offset = 0;
            homeProvider!.isLoadingItems = true;
            currentSelected = index;
            update();
            print(homeProvider!.activeStatus + "ACTIVE STATUE");
            homeProvider!.selectedIndex = index;

            if (index == 0) {
              homeProvider!.getCurrentOrder(update, context, lat, long);
            }
            else {
              if (index == 1) {
                homeProvider!.activeStatus = "shipped";
                homeProvider!.getOrder(update, context);
              } else if (index == 3) {
                homeProvider!.activeStatus = "delivered";
                homeProvider!.getOrder(update, context);
              } else {
                homeProvider!.activeStatus = "";

              }
            }

            update();

            // homeProvider!.activeStatus = onTapAction!;
            // // homeProvider!.scrollLoadmore = true;
            // // homeProvider!.scrollOffset = 0;
            // update();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 8.0,
                  start: 15.0,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: currentSelected == index ? white : black,
                    fontSize: textFontSize12,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 15.0,
                  top: 8.0,
                ),
                child: Text(
                  () {
                    if (index == 0) {
                      if (homeProvider!.length != null) {
                        return homeProvider!.length!;
                      } else {
                        return "";
                      }
                      // } else if (index == 1) {
                      //   if (homeProvider!.received != null) {
                      //     return homeProvider!.received!;
                      //   } else {
                      //     return "";
                      //   }
                    } else if (index == 1) {
                      if (homeProvider!.all != null) {
                        return homeProvider!.all!;
                      } else {
                        return "";
                      }
                    // } else if (index == 2) {
                    //   if (homeProvider!.picked != null) {
                    //     return homeProvider!.picked!;
                    //   } else {
                    //     return "";
                    //   }
                    //   //   }
                    //   // else if (index == 3) {
                    //   //   if (homeProvider!.picked != null) {
                    //   //     return homeProvider!.picked!;
                    //   //   } else {
                    //   //     return "";
                    //   //   }
                    // } else if (index == 3) {
                    //   if (homeProvider!.delivered != null) {
                    //     return homeProvider!.delivered!;
                    //   } else {
                    //     return "";
                    //   }

                      // } else if (index == 6) {
                      //   if (homeProvider!.returned != null) {
                      //     return homeProvider!.returned!;
                      //   } else {
                      //     return "";
                      //   }
                    } else {
                      return "";
                    }
                  }(),
                  style: TextStyle(
                    color: currentSelected == index ? white : black,
                    fontWeight: FontWeight.bold,
                    fontSize: textFontSize16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
