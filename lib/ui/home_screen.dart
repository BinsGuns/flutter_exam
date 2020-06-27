import 'dart:convert';
import 'dart:io';

import 'package:fluttertest/ui/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertest/ui/weather_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  String token;

  HomeScreen(this.token);

  @override
  _HomeScreenState createState() => _HomeScreenState(this.token);
}

class _HomeScreenState extends State<HomeScreen> {
  String location = "";
  String token;
  FirebaseUser _user;
  double lat;
  double lon;
  var userData;

  _HomeScreenState(this.token);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    final response = await http.get(
      'https://api.github.com/user',
      headers: {HttpHeaders.authorizationHeader: "token  $token"},
    );
    setState(() {
      this.userData = jsonDecode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: Text('Home')),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: DrawerHeader(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("assets/headerbg.png"),
                                  fit: BoxFit.cover)),
                          child: Text(
                            "Welcome!",
                            style:
                                TextStyle(color: Colors.white, fontSize: 30.0),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Home'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text('Weather'),
                      onTap: () {
                        askPermission(context);
                      },
                    ),
                  ],
                ),
              ),
              MaterialButton(
                padding: EdgeInsets.all(20),
                color: Colors.blueGrey,
                child: Align(
                  child: Text(
                    'LOGOUT',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut(); 
                   Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              )
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
              child: userData != null
                  ? Container(
                      width: 200,
                      height: 200,
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            NetworkImage(userData["avatar_url"].toString()),
                      ),
                    )
                  : CircularProgressIndicator()),
          SizedBox(
            height: 20,
          ),
          Center(
            child: userData != null ? Text(
              userData["login"].toString(),
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70),
            ):Text(''),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: userData != null ? Text(
              userData["url"].toString(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                  color: Colors.white70),
            ) : Text(''),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "$location",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                  color: Colors.white70),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            width: double.infinity,
            height: 50,
            child: FlatButton(
              onPressed: () {
                Future<Position> position = Geolocator()
                    .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                position.then((value) {
                  setState(() {
                    this.lat = value.latitude;
                    this.lon = value.longitude;
                    this.location = "LAT:$lat  LON:$lon";
                  });
                });
              },
              color: Colors.blueAccent,
              child: Text(
                "MY LOCATION",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          )
          
        ],
      ),
    );
  }

  Future<void> askPermission(BuildContext context) async {
    PermissionStatus permission =
        await LocationPermissions().checkPermissionStatus();

    if (PermissionStatus.granted == permission) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => WeatherScreen(token)));
    } else {
      await LocationPermissions().requestPermissions();
      askPermission(context);
    }
  }
}
