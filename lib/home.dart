import 'package:adminplacements/DataModels/admins.dart';
import 'package:adminplacements/login.dart';
import 'package:adminplacements/restrictUser.dart';
import 'package:adminplacements/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  bool userLoggedIn;
  FirebaseUser user;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String userEmail, userName;
  var currentAdmins;
  var defaultAdmins;
  final fb = FirebaseDatabase.instance;
  AdminDetails adminDetails;

  @override
  void initState() {
    super.initState();
    this.user = null;
    this.userLoggedIn = null;
    this.currentAdmins = <AdminDetails>{};
    this.defaultAdmins = <dynamic>{
      "anuraghyarlagadda@gmail.com",
      "ramakrishna_p@vnrvjiet.in",
      "bharathkumarchowdary@gmail.com"
    };
    checkUserStatus();
    getCurrentAdmins();
  }

  checkUserStatus() async {
    await googleSignIn.isSignedIn().then((onValue) {
      // print("Status" + onValue.toString());
      setState(() {
        this.userLoggedIn = onValue;
      });
    });
    if (this.userLoggedIn == true) {
      getUserDetails();
    }
  }

  getCurrentAdmins() {
    final ref = fb.reference().child("Admins");
    ref.onChildAdded.listen((onData) {
      adminDetails = AdminDetails.fromSnapshot(onData.snapshot);
      setState(() {
        try {
          this.currentAdmins.add(adminDetails);
        } catch (identifier) {
          print("Added  ");
          print(identifier);
        }
      });
      print(this.currentAdmins.length);
    });
    ref.onChildRemoved.listen((onData) {
      print(onData.snapshot.value);
      adminDetails = AdminDetails.fromSnapshot(onData.snapshot);
      print(adminDetails.email);
      setState(() {
        try {
          this
              .currentAdmins
              .removeWhere((value) => value.email == adminDetails.email);
        } catch (identifier) {
          print("Removed  ");
          print(identifier);
        }
      });
      print("home");
      print(this.currentAdmins.length);
    });
    ref.onChildChanged.listen((onData) {
      adminDetails = AdminDetails.fromSnapshot(onData.snapshot);
      setState(() {
        try {
          this.currentAdmins.forEach((value) {
            if (adminDetails.email == value.email) {
              value.permission = adminDetails.permission;
            }
          });
        } catch (identifier) {
          print("Changed  ");
          print(identifier);
        }
      });
      print(this.currentAdmins.length);
    });
  }

  getUserDetails() async {
    await FirebaseAuth.instance.currentUser().then((onValue) {
      setState(() {
        this.user = onValue;
        this.userEmail = onValue.email;
        this.userName = onValue.displayName;
        Fluttertoast.showToast(
            msg: "Welcome " + this.userName,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.blue,
            textColor: Colors.white);
      });
    });
  }

  void handleClick(String value) async {
    await signOutGoogle().then((onValue) {
      //print(onValue);
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
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: this.userLoggedIn == null
            ? Center(child: CircularProgressIndicator())
            : this.userLoggedIn == false
                ? Login()
                : this.user == null
                    ? Center(child: CircularProgressIndicator())
                    : this
                                .currentAdmins
                                .where((item) => item.email == this.userEmail)
                                .length >
                            0
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                RaisedButton(
                                  onPressed: () {
                                    this.defaultAdmins.contains(this.userEmail)
                                        ? Navigator.of(context)
                                            .pushNamed("manageAdmins")
                                        : Fluttertoast.showToast(
                                            msg: "Acces Denied",
                                            toastLength: Toast.LENGTH_LONG,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white);
                                  },
                                  child: Text("Manage Admins"),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    if (this
                                            .currentAdmins
                                            .where((item) =>
                                                (item.email == this.userEmail &&
                                                    item.permission))
                                            .length >
                                        0) {
                                      Fluttertoast.showToast(
                                          msg: "HI ",
                                          toastLength: Toast.LENGTH_LONG,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white);
                                      ;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Permission Denied ",
                                          toastLength: Toast.LENGTH_LONG,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white);
                                    }
                                  },
                                  child: Text("Upload Alumni Details"),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    if (this
                                            .currentAdmins
                                            .where((item) =>
                                                (item.email == this.userEmail &&
                                                    item.permission))
                                            .length >
                                        0) {
                                      Fluttertoast.showToast(
                                          msg: "HI ",
                                          toastLength: Toast.LENGTH_LONG,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white);
                                      ;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Permission Denied ",
                                          toastLength: Toast.LENGTH_LONG,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white);
                                    }
                                  },
                                  child: Text("Upload List of Companies"),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    if (this
                                            .currentAdmins
                                            .where((item) =>
                                                (item.email == this.userEmail &&
                                                    item.permission))
                                            .length >
                                        0) {
                                      Fluttertoast.showToast(
                                          msg: "HI ",
                                          toastLength: Toast.LENGTH_LONG,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white);
                                      ;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Permission Denied ",
                                          toastLength: Toast.LENGTH_LONG,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white);
                                    }
                                  },
                                  child: Text(
                                      "Upload Requirements and Sample Resume"),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    if (this
                                            .currentAdmins
                                            .where((item) =>
                                                (item.email == this.userEmail &&
                                                    item.permission))
                                            .length >
                                        0) {
                                      Fluttertoast.showToast(
                                          msg: "HI ",
                                          toastLength: Toast.LENGTH_LONG,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white);
                                      ;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Permission Denied ",
                                          toastLength: Toast.LENGTH_LONG,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white);
                                    }
                                  },
                                  child: Text("Add company"),
                                ),
                              ],
                            ),
                            scrollDirection: Axis.vertical,
                          )
                        : NoAccess());
  }
}
