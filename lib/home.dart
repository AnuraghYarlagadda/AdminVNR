import 'package:adminplacements/DataModels/admins.dart';
import 'package:adminplacements/login.dart';
import 'package:adminplacements/restrictUser.dart';
import 'package:adminplacements/settings.dart';
import 'package:adminplacements/signin.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:adminplacements/addCompany.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

enum Status { start, running, completed }

class HomeState extends State<Home> {
  bool userLoggedIn;
  FirebaseUser user;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String userEmail, userName;
  var currentAdmins;
  var defaultAdmins;
  final fb = FirebaseDatabase.instance;
  AdminDetails adminDetails;

  String fileType = '';
  File file;
  String alumniDetails, listOfCompanies, sampleresume;
  int alumniDetailsStatus, listOfCompaniesStatus, sampleresumeStatus;

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

    this.alumniDetails = "AlumniDetails.xlsx";
    this.listOfCompanies = "listofcompanies.xlsx";
    this.sampleresume = "sampleresume.pdf";
    this.alumniDetailsStatus = Status.start.index;
    this.listOfCompaniesStatus = Status.start.index;
    this.sampleresumeStatus = Status.start.index;

    checkUserStatus();
    getCurrentAdmins();
  }

  checkUserStatus() async {
    await googleSignIn.isSignedIn().then((onValue) {
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
          print(identifier);
        }
      });
      print(this.currentAdmins.length);
    });
    ref.onChildRemoved.listen((onData) {
      adminDetails = AdminDetails.fromSnapshot(onData.snapshot);
      setState(() {
        try {
          this
              .currentAdmins
              .removeWhere((value) => value.email == adminDetails.email);
        } catch (identifier) {
          print(identifier);
        }
      });
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

  Future filePicker(BuildContext context, String fileName) async {
    try {
      if (fileType == 'pdf') {
        file = await FilePicker.getFile(
            type: FileType.custom, allowedExtensions: ['pdf']);
        if (file != null) {
          _uploadFile(file, fileName);
        } else {
          setState(() {
            if (fileName == this.sampleresume) {
              this.sampleresumeStatus = Status.start.index;
            }
          });
        }
      }
      if (fileType == 'xlsx') {
        file = await FilePicker.getFile(
            type: FileType.custom, allowedExtensions: ['xlsx']);
        if (file != null) {
          _uploadFile(file, fileName);
        } else {
          setState(() {
            if (fileName == this.alumniDetails) {
              this.alumniDetailsStatus = Status.start.index;
            } else if (fileName == this.listOfCompanies) {
              this.listOfCompaniesStatus = Status.start.index;
            }
          });
        }
      }
    } on PlatformException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  Future<void> _uploadFile(File file, String filename) async {
    StorageReference storageReference;
    storageReference = FirebaseStorage.instance.ref().child(filename);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    if (url != null) {
      if (filename == this.alumniDetails) {
        setState(() {
          this.alumniDetailsStatus = Status.completed.index;
          Fluttertoast.showToast(
              msg: this.alumniDetails + " Uploaded Successfully!",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.blue,
              textColor: Colors.white);
        });
      } else if (filename == this.listOfCompanies) {
        setState(() {
          this.listOfCompaniesStatus = Status.completed.index;
          Fluttertoast.showToast(
              msg: this.listOfCompanies + " Uploaded Successfully!",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.blue,
              textColor: Colors.white);
        });
      } else if (filename == this.sampleresume) {
        setState(() {
          this.sampleresumeStatus = Status.completed.index;
          Fluttertoast.showToast(
              msg: this.sampleresume + " Uploaded Successfully!",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.blue,
              textColor: Colors.white);
        });
      }
    }
    print("URL is $url");
  }

  void handleClick(String value) async {
    await signOutGoogle().then((onValue) {
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
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    this.defaultAdmins.contains(this.userEmail)
                                        ? ListTile(
                                            //isThreeLine: true,
                                            title: Text(
                                              "Manage Admins",
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.indigo,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            subtitle: Text(
                                              "- Add or Delete Admins \n- Grant or Revoke Permissions",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87),
                                            ),
                                            trailing: IconButton(
                                                icon: Icon(
                                                  Icons.settings,
                                                  size: 35,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          "manageAdmins");
                                                }))
                                        : Padding(
                                            padding: EdgeInsets.all(0),
                                          ),
                                    new Divider(
                                      height: 2.0,
                                      thickness: 2.5,
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Alumni Details",
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      trailing: whatToLoadwhileUploading(
                                          "Alumni Details"),
                                      subtitle: Text(
                                        "- An Excel Sheet with the details of Alumni's Contact and the companies they got placed into.",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87),
                                      ),
                                    ),
                                    new Divider(
                                      height: 2.0,
                                      thickness: 2.5,
                                    ),
                                    ListTile(
                                      title: Text(
                                        "List Of Companies",
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      trailing: whatToLoadwhileUploading(
                                          "List Of Companies"),
                                      subtitle: Text(
                                        "- An Excel with the details of the Companies that visited our college for recruitment last year and the packages they offered.",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87),
                                      ),
                                    ),
                                    new Divider(
                                      height: 2.0,
                                      thickness: 2.5,
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Requirements and Sample Resume",
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      trailing: whatToLoadwhileUploading(
                                          "Requirements and Sample Resume"),
                                      subtitle: Text(
                                        "- A PDF Document with the details of requirements that companies have been looking for and Few Sample Resumes to refer.",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87),
                                      ),
                                    ),
                                    new Divider(
                                      height: 2.0,
                                      thickness: 2.5,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(50),
                                      child: Center(
                                        child: RaisedButton(
                                          onPressed: () async {
                                            await (Connectivity()
                                                    .checkConnectivity())
                                                .then((onValue) {
                                              if (onValue ==
                                                  ConnectivityResult.none) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "No Active Internet Connection!",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white);
                                                openWIFISettingsVNR();
                                              } else {
                                                if (this
                                                        .currentAdmins
                                                        .where((item) => (item
                                                                    .email ==
                                                                this.userEmail &&
                                                            item.permission))
                                                        .length >
                                                    0) {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return AddCompany();
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: "Permission Denied ",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.white);
                                                }
                                              }
                                            });
                                          },
                                          child: Text(
                                            "Add Company Details",
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          elevation: 15,
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            scrollDirection: Axis.vertical,
                          )
                        : NoAccess());
  }

  Widget whatToLoadwhileUploading(String whatToDownload) {
    if (whatToDownload == "Alumni Details") {
      if (this.alumniDetailsStatus == Status.start.index) {
        return (IconButton(
          icon: Icon(Icons.cloud_upload),
          color: Colors.blue,
          iconSize: 35,
          onPressed: () async {
            await (Connectivity().checkConnectivity()).then((onValue) {
              if (onValue == ConnectivityResult.none) {
                Fluttertoast.showToast(
                    msg: "No Active Internet Connection!",
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.red,
                    textColor: Colors.white);
                openWIFISettingsVNR();
              } else {
                if (this
                        .currentAdmins
                        .where((item) =>
                            (item.email == this.userEmail && item.permission))
                        .length >
                    0) {
                  setState(() {
                    this.alumniDetailsStatus = Status.running.index;
                    fileType = "xlsx";
                  });
                  filePicker(context, this.alumniDetails);
                } else {
                  Fluttertoast.showToast(
                      msg: "Permission Denied ",
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                }
              }
            });
          },
        ));
      } else if (this.alumniDetailsStatus == Status.running.index) {
        return CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.pink),
        );
      } else {
        return (MaterialButton(
          onPressed: () {
            Fluttertoast.showToast(
                msg: "Already Uploaded!",
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.green,
                textColor: Colors.white);
          },
          color: Colors.green,
          textColor: Colors.white,
          child: Icon(
            Icons.check,
            size: 24,
          ),
          //padding: EdgeInsets.all(8),
          shape: CircleBorder(),
        ));
      }
    } else if (whatToDownload == "List Of Companies") {
      if (this.listOfCompaniesStatus == Status.start.index) {
        return (IconButton(
          icon: Icon(Icons.cloud_upload),
          color: Colors.blue,
          iconSize: 35,
          onPressed: () async {
            await (Connectivity().checkConnectivity()).then((onValue) {
              if (onValue == ConnectivityResult.none) {
                Fluttertoast.showToast(
                    msg: "No Active Internet Connection!",
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.red,
                    textColor: Colors.white);
                openWIFISettingsVNR();
              } else {
                if (this
                        .currentAdmins
                        .where((item) =>
                            (item.email == this.userEmail && item.permission))
                        .length >
                    0) {
                  setState(() {
                    this.listOfCompaniesStatus = Status.running.index;
                    fileType = "xlsx";
                  });
                  filePicker(context, this.listOfCompanies);
                } else {
                  Fluttertoast.showToast(
                      msg: "Permission Denied ",
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                }
              }
            });
          },
        ));
      } else if (this.listOfCompaniesStatus == Status.running.index) {
        return CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.pink),
        );
      } else {
        return (MaterialButton(
          onPressed: () {
            Fluttertoast.showToast(
                msg: "Already Uploaded!",
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.green,
                textColor: Colors.white);
          },
          color: Colors.green,
          textColor: Colors.white,
          child: Icon(
            Icons.check,
            size: 24,
          ),
          //padding: EdgeInsets.all(8),
          shape: CircleBorder(),
        ));
      }
    } else if (whatToDownload == "Requirements and Sample Resume") {
      if (this.sampleresumeStatus == Status.start.index) {
        return (IconButton(
          icon: Icon(Icons.cloud_upload),
          color: Colors.blue,
          iconSize: 35,
          onPressed: () async {
            await (Connectivity().checkConnectivity()).then((onValue) {
              if (onValue == ConnectivityResult.none) {
                Fluttertoast.showToast(
                    msg: "No Active Internet Connection!",
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.red,
                    textColor: Colors.white);
                openWIFISettingsVNR();
              } else {
                if (this
                        .currentAdmins
                        .where((item) =>
                            (item.email == this.userEmail && item.permission))
                        .length >
                    0) {
                  setState(() {
                    this.sampleresumeStatus = Status.running.index;
                    fileType = "pdf";
                  });
                  filePicker(context, this.sampleresume);
                } else {
                  Fluttertoast.showToast(
                      msg: "Permission Denied ",
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                }
              }
            });
          },
        ));
      } else if (this.sampleresumeStatus == Status.running.index) {
        return CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.pink),
        );
      } else {
        return (MaterialButton(
          onPressed: () {
            Fluttertoast.showToast(
                msg: "Already Uploaded!",
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.green,
                textColor: Colors.white);
          },
          color: Colors.green,
          textColor: Colors.white,
          child: Icon(
            Icons.check,
            size: 24,
          ),
          //padding: EdgeInsets.all(8),
          shape: CircleBorder(),
        ));
      }
    }
  }
}
