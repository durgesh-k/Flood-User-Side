import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notification/auth/number.dart';
import 'package:notification/map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

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
                title: 'Map',
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
    var position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best)
        .timeout(Duration(seconds: 5));
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    print(placemarks);
    setState(() {
      locality = placemarks[0].locality;
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  // on below line we have set the camera position
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(19.0759837, 72.8776559),
    zoom: 1,
  );

  Set<Polygon> _polygon = HashSet<Polygon>();

  // created list of locations to display polygon
  List<LatLng> points = [
    LatLng(19.0759837, 72.8776559),
    LatLng(28.679079, 77.069710),
    LatLng(26.850000, 80.949997),
    LatLng(19.0759837, 72.8776559),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
    setCoordinates();
    _polygon.add(Polygon(
      // given polygonId
      polygonId: PolygonId('1'),
      // initialize the list of points to display polygon
      points: points,
      // given color to polygon
      fillColor: Colors.green.withOpacity(0.3),
      // given border color to polygon
      strokeColor: Colors.green,
      geodesic: true,
      // given width of border
      strokeWidth: 4,
    ));
  }

  List<Map<String, dynamic>> data = [
    {
      'title': 'Warning level',
      'text': 'Severe',
      'subtext': ' ',
      'icon': Icons.warning_amber_rounded
    },
    {
      'title': 'Rainfall',
      'text': '133mm',
      'subtext': 'Over-normal',
      'icon': Icons.water_drop_outlined
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.1),
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.black,
            ),
            SizedBox(
              width: 6,
            ),
            Text(
              locality!,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
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
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.black,
                ),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Container(
              height: 200,
              child: GoogleMap(
                //given camera position
                initialCameraPosition: _kGoogle,
                // on below line we have given map type
                mapType: MapType.normal,
                // on below line we have enabled location
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                // on below line we have enabled compass location
                compassEnabled: true,
                // on below line we have added polygon
                polygons: _polygon,
                // displayed google map
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 9 / 11.6,
                padding: EdgeInsets.all(5),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: List.generate(2, (index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            data[index]['icon'],
                            size: 28,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            data[index]['title'],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            data[index]['text'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                          Text(data[index]['subtext']),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
