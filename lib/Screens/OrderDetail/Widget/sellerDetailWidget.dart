import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Helper/color.dart';
import '../../../Helper/constant.dart';
import '../../../Model/order_model.dart';
import '../../../Widget/desing.dart';
import '../../../Widget/parameterString.dart';
import '../../../Widget/setSnackbar.dart';
import '../../../Widget/translateVariable.dart';
import '../../../Widget/validation.dart';
import '../../TrackLlocation/seller_driver.dart';
import '../../TrackLlocation/userAndDriverScreen.dart';
import '../order_detail.dart';
import 'otpDialog.dart';

class SellerDetails extends StatefulWidget {
  Order_Model model;
  int index;
  SellerDetails({
    Key? key,
    required this.model,
    required this.index,
  }) : super(key: key);

  @override
  State<SellerDetails> createState() => _SellerDetailsState();
}

class _SellerDetailsState extends State<SellerDetails> {
  setStateNow() {
    setState(() {});
  }

  void _launchCaller(
    String phoneNumber,
    BuildContext context,
  ) async {
    var url = "tel:$phoneNumber";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      setSnackbar('Could not launch $url', context);
      throw 'Could not launch $url';
    }
  }

  _launchMap(lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url =
          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url =
          "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5.0, 0, 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    getTranslated(context, SELLER_DETAILS)!,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontFamily: 'PlusJakartaSans',
                          color: black,
                          fontSize: textFontSize14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                  ),
                  Spacer(),
                  widget.model.itemList![widget.index].status == "driver accept"
                      ? widget.model.itemList![widget.index].storeLatitude !=
                                  "" &&
                              widget.model.itemList![widget.index]
                                      .storeLongitude !=
                                  ""
                          ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                                child: Text(
                                  "Get Direction",
                                  style: TextStyle(
                                      color: primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  if (widget
                                          .model.itemList![widget.index].status ==
                                      "driver accept") {
                                    print(
                                        '____Som______${widget.model.itemList![widget.index].status}_________');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SellerDriver(
                                              driverId: widget
                                                  .model
                                                  .itemList![widget.index]
                                                  .deliveryId,
                                              sellerId: widget
                                                  .model
                                                  .itemList![widget.index]
                                                  .sellerId,
                                              addressId: widget.model.addressId,
                                              status: widget
                                                  .model
                                                  .itemList![widget.index]
                                                  .status),
                                        ));
                                  }

                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen();
                                  // _launchMap(
                                  //     model.itemList![index].storeLatitude,
                                  //     model.itemList![index].storeLongitude);
                                },
                              ),
                          )
                          : Container()
                      : SizedBox.shrink(),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(circularBorderRadius10),
                    child: DesignConfiguration.getCacheNotworkImage(
                      boxFit: BoxFit.cover,
                      context: context,
                      heightvalue: 50,
                      widthvalue: 50,
                      imageurlString:
                          widget.model.itemList![widget.index].storeImage!,
                      placeHolderSize: 150,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                          ),
                          child: Text(
                            widget.model.itemList![widget.index].storeName !=
                                        "" &&
                                    widget.model.itemList![widget.index]
                                        .storeName!.isNotEmpty
                                ? "${StringValidation.capitalize(widget.model.itemList![widget.index].storeName!)}"
                                : " ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 1,
                                ),
                                child: Text(
                                  StringValidation.capitalize(widget.model
                                      .itemList![widget.index].sellerAddress!),
                                  style: const TextStyle(
                                    color: lightBlack2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 1,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.call,
                                      size: 15,
                                      color: primary,
                                    ),
                                    SizedBox(
                                      width: 05,
                                    ),
                                    Text(
                                      "${widget.model.itemList![widget.index].sellerMobileNumber!}",
                                      style: const TextStyle(
                                        color: primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                _launchCaller(
                                  widget.model.itemList![widget.index]
                                      .sellerMobileNumber!,
                                  context,
                                );
                              },
                            ),
                            Spacer(),
                            Visibility(
                              visible: widget.model.itemList!.first.status ==
                                  'driver accept',
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      backgroundColor: Colors.teal.shade300),
                                  onPressed: ()async {
                                    await orderDetailProvider!.updateOrder(
                                      'shipped',
                                      widget.model.id,
                                      true,
                                      widget.index,
                                      widget.model.itemList!.first.item_otp,
                                      setStateNow,
                                      context,
                                      widget.model,
                                    );

                                  },
                                  child: Text(
                                    'Pick Order',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          )),
    );
  }
}
