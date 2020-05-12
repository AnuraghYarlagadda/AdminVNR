import 'package:adminplacements/login.dart';
import 'package:adminplacements/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  bool userLoggedIn;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  void initState() {
    super.initState();
    this.userLoggedIn = false;
    checkUserStatus();
  }

  checkUserStatus() async {
    print("ocha");
    await googleSignIn.isSignedIn().then((onValue) {
      print("Status" + onValue.toString());
      setState(() {
        this.userLoggedIn = onValue;
      });
    });
  }

  void handleClick(String value) async {
    await signOutGoogle().then((onValue) {
      print(onValue);
      Navigator.of(context).pushReplacementNamed("home");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return ['Sign-Out'].map((String choice) {
                return PopupMenuItem<String>(
                  enabled: this.userLoggedIn,
                  height: MediaQuery.of(context).size.height / 18,
                  value: choice,
                  child: Text(
                    choice,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: this.userLoggedIn == false ? Login() : Text("Hi  "),
    );
  }
}

// actions: <Widget>[
//           IconButton(
//               onPressed: () async {
//                 await signOutGoogle().then((onValue) {
//                   print(onValue);
//                   Navigator.of(context).pushReplacementNamed("home");
//                 });
//               },

//               icon: Icon(Icons.more_vert))
//         ],
