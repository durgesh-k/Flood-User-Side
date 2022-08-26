import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

TextEditingController city = TextEditingController();
TextEditingController name = TextEditingController();
TextEditingController mobile = TextEditingController();
TextEditingController address = TextEditingController();


double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

void showToast(String? str) {
  Fluttertoast.showToast(
      msg: str!,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade100,
      textColor: Colors.black.withOpacity(0.9),
      fontSize: 16.0);
}
