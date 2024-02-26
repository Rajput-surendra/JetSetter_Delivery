import 'package:deliveryboy_multivendor/Screens/Home/Widget/getOrderIteam.dart';
import 'package:flutter/material.dart';
import '../../../Widget/parameterString.dart';

class DetailHeader extends StatelessWidget {
  Function update;
  String lat;
  String long;
  DetailHeader({
    Key? key,
    required this.update,
    required this.lat,
    required this.long,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        left: 15,
        right: 15,
      ),
      child: SizedBox(
        width: deviceWidth,
        height: 70,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            CommanDesingWidget(
              index: 0,
              title: 'Current',
              update: update,
              lat: lat,
              long: long,
            ),
            CommanDesingWidget(
              index: 1,
              title: 'Orders',
              update: update,
              lat: lat,
              long: long,
            ),
            // CommanDesingWidget(
            //   index: 2,
            //   title: 'Processed',
            //   update: update,
            //   lat: lat,
            //   long: long,
            // ),
            // CommanDesingWidget(
            //   index: 1,
            //   title: 'Processed',
            //   update: update,
            // ),
            // CommanDesingWidget(
            //   index: 2,
            //   title: 'Picked Up',
            //   update: update,
            //   lat: lat,
            //   long: long,
            // ),
            // CommanDesingWidget(
            //   index: 3,
            //   title: 'Delivered',
            //   lat: lat,
            //   long: long,
            //   update: update,
            // ),
            // CommanDesingWidget(
            //   index: 5,
            //   title: 'Cancelled ',
            //   update: update,
            // ),
            // CommanDesingWidget(
            //   index: 6,
            //   title: 'Returned',
            //   update: update,
            // ),
          ],
        ),
      ),
    );
  }
}
