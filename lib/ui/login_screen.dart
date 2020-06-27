import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:fluttertest/ui/home_screen.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading;
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      this.isLoading = false;
    });
  
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Container(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/github.png'),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Github",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child :  isLoading ?
                    CircularProgressIndicator() : MaterialButton(
                    padding: EdgeInsets.all(20),
                    color: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Align(
                      child:
                          // Provider.of<UserProvider>(context).isLoading() ?
                          // CircularProgressIndicator(backgroundColor: Colors.white, strokeWidth: 2,) :
                          Text(
                        'LOGIN WITH GITHUB',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      _signInWithGithub();
                    },
                  ),
                   
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

// Example code of how to sign in with Github.
  void _signInWithGithub() async {
   setState(() {
      this.isLoading = true;
   });
    final result = await FlutterWebAuth.authenticate(
      url:
          "https://github.com/login/oauth/authorize?client_id=127171417b5236e6e6e6",
      callbackUrlScheme: "fluttertest",
    );

    final code = Uri.parse(result).queryParameters['code'];
    if (code != null) {
      final response =
          await http.post("https://github.com/login/oauth/access_token", body: {
        'client_id': '127171417b5236e6e6e6',
        'client_secret': '54d3abfe54a11e1eda1b633fd3792d8cc4d847eb',
        'code': code,
      });
      final splitString = response.body.split("=")[1];
      final accesstoken = splitString.split("&")[0];

      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: accesstoken,
      );
      
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
    
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      setState(() {
        if (user != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen(accesstoken)));
        }
      });
    }
  }
}
