import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:notification/globals.dart';
import 'package:notification/main.dart';
import 'package:permission_handler/permission_handler.dart';

class Info extends StatefulWidget {
  const Info({Key? key}) : super(key: key);

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  String? token;
  bool? loading = false;
  Future<void> getToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = fcmToken;
    });
    print(fcmToken);
    return;
  }

  Future<List<String>> getLocation() async {
    //LocationPermission permission = await Geolocator.requestPermission();
    await Permission.location.request();
    var status = await Permission.location.status;
    if (status.isGranted) {
      var position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best)
          .timeout(Duration(seconds: 5));

      try {
        /*List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );*/
        //print('locationssd--${placemarks[0]}');
        print('lat--${position.latitude}');
        print('lon--${position.longitude}');
        return [position.latitude.toString(), position.longitude.toString()];
      } catch (err) {
        return ['err', 'err'];
      }
    } else {
      return ['err', 'err'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: name,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
                //inputFormatters: [FilteringTextInputFormatter.deny(' ')],
                style: const TextStyle(
                  fontFamily: "SemiBold",
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  focusColor: Colors.black,
                  filled: false,
                  fillColor: Colors.black.withOpacity(0.05),
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(
                    fontFamily: "SemiBold",
                    fontSize: 14, //16,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: city,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'City cannot be empty';
                  }
                  return null;
                },
                //inputFormatters: [FilteringTextInputFormatter.deny(' ')],
                style: const TextStyle(
                  fontFamily: "SemiBold",
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  focusColor: Colors.black,
                  filled: false,
                  fillColor: Colors.black.withOpacity(0.05),
                  hintText: 'Enter your city',
                  hintStyle: TextStyle(
                    fontFamily: "SemiBold",
                    fontSize: 14, //16,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                elevation: 0,
                splashColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  var coordinates = await getLocation();

                  await getToken();
                  await FirebaseFirestore.instance
                      .collection('People')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .set({
                    'fcm': token,
                    'coordinates': coordinates,
                    'number': FirebaseAuth.instance.currentUser!.phoneNumber,
                    'city': city.text,
                    'name': name.text
                  });
                  setState(() {
                    loading = false;
                  });
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(
                          title: 'Flutter Demo Home Page',
                        ),
                      ),
                      ((route) => false));
                },
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: Container(
                  height: 60,
                  width: 140,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.blue),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: loading!
                              ? Container(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Next')),
                    ],
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
