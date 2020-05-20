import 'package:adminplacements/DataModels/admins.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ManageAdmin extends StatefulWidget {
  @override
  ManageAdminState createState() => ManageAdminState();
}

class ManageAdminState extends State<ManageAdmin> {
  TextEditingController emailController = new TextEditingController();
  var admins;
  final fb = FirebaseDatabase.instance;
  double width, height;
  var defaultAdmins;
  AdminDetails adminDetails;
  @override
  void initState() {
    super.initState();
    this.admins = <AdminDetails>{};
    print(this.admins);
    this.defaultAdmins = <dynamic>{
      "anuraghyarlagadda@gmail.com",
      "ramakrishna_p@vnrvjiet.in",
      "bharathkumarchowdary@gmail.com"
    };
    getData();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    super.dispose();
  }

  getData() {
    final ref = fb.reference().child("Admins");
    ref.onChildAdded.listen((onData) {
      adminDetails = AdminDetails.fromSnapshot(onData.snapshot);
      setState(() {
        try {
          this.admins.add(adminDetails);
        } catch (identifier) {
          print("Added  ");
          print(identifier);
        }
      });
      print(this.admins.length);
    });
    ref.onChildRemoved.listen((onData) {
      print(onData.snapshot.value);
      adminDetails = AdminDetails.fromSnapshot(onData.snapshot);
      setState(() {
        try {
          this.admins.removeWhere((value) => value.email == adminDetails.email);
        } catch (identifier) {
          print("Removed  ");
          print(identifier);
        }
      });
      print("Manage");
      print(this.admins.length);
    });
    ref.onChildChanged.listen((onData) {
      adminDetails = AdminDetails.fromSnapshot(onData.snapshot);
      setState(() {
        try {
          this.admins.forEach((value) {
            if (adminDetails.email == value.email) {
              value.permission = adminDetails.permission;
            }
          });
        } catch (identifier) {
          print("Changed  ");
          print(identifier);
        }
      });
      print(this.admins.length);
    });
  }

  postFirebase(AdminDetails adminDetails) {
    //print(adminDetails.email + "    " + (adminDetails.permission.toString()));
    String id = adminDetails.email.replaceAll('.', ',');
    id = id.replaceAll('@', ',');
    id = id.replaceAll('#', ',');
    id = id.replaceAll('[', ',');
    id = id.replaceAll(']', ',');
    final ref = fb.reference();
    ref.child("Admins").child(id).set(adminDetails.toJson());
  }

  delFirebase(String email) {
    final ref = fb.reference();
    //print(email);
    String id = email.replaceAll('.', ',');
    id = id.replaceAll('@', ',');
    id = id.replaceAll('#', ',');
    id = id.replaceAll('[', ',');
    id = id.replaceAll(']', ',');
    ref.child("Admins").child(id).remove();
  }

  @override
  Widget build(BuildContext context) {
    this.height = MediaQuery.of(context).size.height;
    this.width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text("Manage Admins"),
          leading: Icon(Icons.group_add),
        ),
        body: OfflineBuilder(
            connectivityBuilder: (
              BuildContext context,
              ConnectivityResult connectivity,
              Widget child,
            ) {
              final bool connected = connectivity != ConnectivityResult.none;
              return Stack(
                fit: StackFit.expand,
                children: [
                  child,
                  Positioned(
                    height: 20.0,
                    left: 0.0,
                    right: 0.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      color: connected ? Colors.transparent : Colors.red,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: connected
                            ? Text(
                                '',
                                style: TextStyle(color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Offline',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 8.0),
                                  SizedBox(
                                    width: 12.0,
                                    height: 12.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  (this.admins == null || this.admins.length == 0)
                      ? Container(
                          padding: EdgeInsets.all(15),
                          child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: this.admins.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (this.admins.elementAt(index) != null) {
                              return new Column(
                                children: <Widget>[
                                  new ListTile(
                                      title: new Text(
                                        this.admins.elementAt(index).email,
                                        style: TextStyle(
                                            //fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal),
                                      ),
                                      trailing: this.defaultAdmins.contains(this
                                              .admins
                                              .elementAt(index)
                                              .email)
                                          ? Text("")
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Switch(
                                                  value: this
                                                      .admins
                                                      .elementAt(index)
                                                      .permission,
                                                  onChanged: (value) {
                                                    value
                                                        ? Fluttertoast.showToast(
                                                            msg: "Granted Permission to " +
                                                                this
                                                                    .admins
                                                                    .elementAt(
                                                                        index)
                                                                    .email,
                                                            toastLength: Toast
                                                                .LENGTH_LONG,
                                                            backgroundColor:
                                                                Colors.green,
                                                            textColor:
                                                                Colors.white)
                                                        : Fluttertoast.showToast(
                                                            msg: "Revoked Permission to " +
                                                                this
                                                                    .admins
                                                                    .elementAt(
                                                                        index)
                                                                    .email,
                                                            toastLength: Toast
                                                                .LENGTH_LONG,
                                                            backgroundColor:
                                                                Colors.red,
                                                            textColor:
                                                                Colors.white);
                                                    AdminDetails adminDetails =
                                                        new AdminDetails(
                                                            this
                                                                .admins
                                                                .elementAt(
                                                                    index)
                                                                .email,
                                                            !this
                                                                .admins
                                                                .elementAt(
                                                                    index)
                                                                .permission);
                                                    postFirebase(adminDetails);
                                                  },
                                                  activeTrackColor:
                                                      Colors.green,
                                                  activeColor: Colors.white,
                                                  inactiveTrackColor:
                                                      Colors.red,
                                                ),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      showAlertDialog(
                                                          context,
                                                          this
                                                              .admins
                                                              .elementAt(index)
                                                              .email);
                                                    }),
                                              ],
                                            )),
                                  new Divider(
                                    height: 2.0,
                                    thickness: 2.5,
                                  ),
                                ],
                              );
                            } else {
                              return (Text(""));
                            }
                          },
                        ),
                  this.admins.length == 0
                      ? Text("")
                      : Padding(padding: EdgeInsets.all(25)),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            width: this.width / 1.5,
                            child: TextField(
                              controller: emailController,
                              obscureText: false,
                              autofocus: false,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Email-ID',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: this.width / 3.5,
                            child: RaisedButton(
                              onPressed: () async {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                if (validateGoogleEmail(
                                        emailController.text.trim()) ||
                                    validateVnrEmail(
                                        emailController.text.trim())) {
                                  await (Connectivity().checkConnectivity())
                                      .then((onValue) {
                                    if (onValue == ConnectivityResult.none) {
                                      Fluttertoast.showToast(
                                          msg: "No Active Internet Connection!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white);
                                    } else {
                                      AdminDetails adminDetails =
                                          new AdminDetails(
                                              emailController.text.trim(),
                                              false);
                                      postFirebase(adminDetails);
                                      Fluttertoast.showToast(
                                          msg: "User Added " +
                                              adminDetails.email,
                                          toastLength: Toast.LENGTH_SHORT,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white);
                                      emailController.clear();
                                    }
                                  });
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Enter Valid Mail\nGoogle or VNRVJIET Domain",
                                      toastLength: Toast.LENGTH_LONG,
                                      backgroundColor: Colors.orange,
                                      textColor: Colors.white);
                                  //emailController.clear();
                                }
                              },
                              color: Colors.green,
                              textColor: Colors.white,
                              child: Text("Add Admin"),
                            ),
                          )
                        ],
                      )),
                ],
              ),
            )));
  }

  bool validateGoogleEmail(String value) {
    int i = 0;
    bool flag = true;
    String check = "gmail.com";
    for (i = 0; i < value.length; i++) {
      if (value[i] == '@') {
        break;
      }
    }
    if (value.length - (i + 1) == check.length) {
      for (int c = i + 1, d = 0;
          c < value.length && d < check.length;
          c++, d++) {
        if (value[c] != check[d]) {
          flag = false;
          break;
        }
      }
      return flag;
    } else {
      return false;
    }
  }

  bool validateVnrEmail(String value) {
    int i = 0;
    bool flag = true;
    String check = "vnrvjiet.in";
    for (i = 0; i < value.length; i++) {
      if (value[i] == '@') {
        break;
      }
    }
    if (value.length - (i + 1) == check.length) {
      for (int c = i + 1, d = 0;
          c < value.length && d < check.length;
          c++, d++) {
        if (value[c] != check[d]) {
          flag = false;
          break;
        }
      }
      return flag;
    } else {
      return false;
    }
  }

  showAlertDialog(BuildContext context, String email) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(
            color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continue",
        style: TextStyle(
            color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        delFirebase(email);
        Fluttertoast.showToast(
            msg: "User Removed " + email,
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.red,
            textColor: Colors.white);
        Navigator.of(context).pop(); // dismiss dialog
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Admin"),
      content: Text(email),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
