import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:notification/auth/number.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FirebaseAuth.instance.currentUser != null
            ? MyHomePage(
                title: 'My home page',
              )
            : PhoneNumberScreen());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> getToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print(fcmToken);
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

  String? locality = "loading..";

  void setCoordinates() async {
    var coordinates = await getLocation();

    await FirebaseFirestore.instance
        .collection('People')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'coordinates': coordinates,
    });
    List<Placemark> placemarks = await placemarkFromCoordinates(
      double.parse(coordinates[0]),
      double.parse(coordinates[1]),
    );
    setState(() {
      locality = placemarks[0].name;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
    setCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(locality!),
        actions: [
          InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PhoneNumberScreen()),
                  );
                });
              },
              child: Icon(Icons.logout_rounded))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
