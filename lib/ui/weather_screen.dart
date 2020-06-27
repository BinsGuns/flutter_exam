import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertest/bloc/weatherbloc.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertest/api/weatherrepo.dart';
import 'package:fluttertest/model/weathermodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:fluttertest/ui/home_screen.dart';
import 'package:fluttertest/ui/login_screen.dart';
class WeatherScreen extends StatelessWidget {
String token;

WeatherScreen(this.token);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather')),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
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
                          style: TextStyle(color: Colors.white, fontSize: 30.0),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(token)));
                    },
                  ),
                  ListTile(
                    title: Text('Weather'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
             MaterialButton(
                  padding: EdgeInsets.all(20),
                  color: Colors.blueGrey,
                 
                  child: Align(
                    child: 
                     
                      Text('LOGOUT', style: TextStyle(color: Colors.white),),
                  ), onPressed: () async {
                   await FirebaseAuth.instance.signOut(); 
                    Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                )
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[900],
      body: BlocProvider(
        builder: (context) => WeatherBloc(WeatherRepo()),
        child: SearchPage(),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
            child: Container(
          child: FlareActor(
            "assets/WorldSpin.flr",
            fit: BoxFit.contain,
            animation: "roll",
          ),
          height: 300,
          width: 300,
        )),
        BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state is WeatherIsNotSearched)
              return Container(
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Search Weather",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70),
                    ),
                    Text(
                      "on your location",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w200,
                          color: Colors.white70),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: FlatButton(
                        onPressed: () {
                          Future<Position> position = Geolocator()
                              .getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high);
                          position.then((value) => weatherBloc.add(FetchWeather(
                              value.latitude.toString(),
                              value.longitude.toString())));
                        },
                        color: Colors.blueAccent,
                        child: Text(
                          "FETCH NOW",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              );
            else if (state is WeatherIsLoading)
              return Center(child: CircularProgressIndicator());
            else if (state is WeatherIsLoaded)
              return ShowWeather(state.getWeather);
            else
              return Center(
                  child: Text('Something went wrong!',
                      style: TextStyle(color: Colors.white)));
          },
        )
      ],
    );
  }
}

class ShowWeather extends StatelessWidget {
  WeatherModel weather;

  ShowWeather(this.weather);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 32, left: 32, top: 5),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                DateFormat('MM/dd/yyyy').format(DateTime.now()),
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                weather.getTemp.toString() + " F",
                // weather.getTemp.round().toString() + "C",
                style: TextStyle(color: Colors.white70, fontSize: 50),
              ),
              Text(
                "Temprature",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: <Widget>[
              //     Column(
              //       children: <Widget>[
              //         Text(
              //           weather.getMinTemp.round().toString() + "C",
              //           style: TextStyle(color: Colors.white70, fontSize: 30),
              //         ),
              //         Text(
              //           "Min Temprature",
              //           style: TextStyle(color: Colors.white70, fontSize: 14),
              //         ),
              //       ],
              //     ),
              //     Column(
              //       children: <Widget>[
              //         Text(
              //           weather.getMaxTemp.round().toString() + "C",
              //           style: TextStyle(color: Colors.white70, fontSize: 30),
              //         ),
              //         Text(
              //           "Max Temprature",
              //           style: TextStyle(color: Colors.white70, fontSize: 14),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 20,
              ),
              // Container(
              //   width: double.infinity,
              //   height: 50,
              //   child: FlatButton(
              //     shape: new RoundedRectangleBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(10))),
              //     onPressed: () {
              //       BlocProvider.of<WeatherBloc>(context).add(ResetWeather());
              //     },
              //     color: Colors.lightBlue,
              //     child: Text(
              //       "Fetch weather again",
              //       style: TextStyle(color: Colors.white70, fontSize: 16),
              //     ),
              //   ),
              // )
            ],
          ),
        ));
  }
}
