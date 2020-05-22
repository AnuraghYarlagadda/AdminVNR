import 'package:adminplacements/DataModels/companyDetails.dart';
import 'package:adminplacements/displayCompanyDetailsandSubmit.dart';
import 'package:adminplacements/settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:collection';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:grouped_buttons/grouped_buttons.dart';

class AddCompany extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddCompanyState();
  }
}

enum Status { start, running, completed }

class AddCompanyState extends State<AddCompany> {
  String companyName, filter;
  LinkedHashMap<dynamic, dynamic> ec, jd;

  //TextEditingControllers
  TextEditingController company = new TextEditingController();
  TextEditingController keyEC = new TextEditingController();
  TextEditingController valueEC = new TextEditingController();
  TextEditingController keyJD = new TextEditingController();
  TextEditingController valueJD = new TextEditingController();

  List<String> filterTypes = [
    "Core",
    "Software and Service",
    "Software and Product"
  ];

  bool showWidgetEC = false;
  bool showWidgetJD = false;

  File file;
  String interviewDetails, interviewQuestions;
  int interviewDetailsStatus, interviewQuestionsStatus;

  @override
  void initState() {
    super.initState();
    this.companyName = "";
    this.filter = "";
    this.ec = new LinkedHashMap();
    this.jd = new LinkedHashMap();

    this.interviewDetails = "";
    this.interviewQuestions = "";
    this.interviewDetailsStatus = Status.start.index;
    this.interviewQuestionsStatus = Status.start.index;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    company.dispose();
    keyEC.dispose();
    keyJD.dispose();
    valueEC.dispose();
    valueJD.dispose();
    super.dispose();
  }

  Future filePicker(BuildContext context, String fileName, String what) async {
    try {
      file = await FilePicker.getFile(
          type: FileType.custom, allowedExtensions: ['pdf']);
      if (file != null) {
        _uploadFile(file, fileName, what);
      } else {
        setState(() {
          if (fileName == this.interviewDetails) {
            this.interviewDetailsStatus = Status.start.index;
          } else if (fileName == this.interviewQuestions) {
            this.interviewQuestionsStatus = Status.start.index;
          }
        });
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

  Future<void> _uploadFile(File file, String filename, String what) async {
    StorageReference storageReference;
    storageReference =
        FirebaseStorage.instance.ref().child(what).child(filename);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    if (url != null) {
      if (filename == this.interviewDetails) {
        setState(() {
          this.interviewDetailsStatus = Status.completed.index;
          Fluttertoast.showToast(
              msg: this.interviewDetails + " Uploaded Successfully!",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.blue,
              textColor: Colors.white);
        });
      } else if (filename == this.interviewQuestions) {
        setState(() {
          this.interviewQuestionsStatus = Status.completed.index;
          Fluttertoast.showToast(
              msg: this.interviewQuestions + " Uploaded Successfully!",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.blue,
              textColor: Colors.white);
        });
      }
    }
    print("URL is $url");
  }

  Future<bool> _onBackPressed() {
    Widget cancelButton = FlatButton(
      child: Text(
        "YES",
        style: TextStyle(
            color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "NO",
        style: TextStyle(
            color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Data not submitted! \nDo you want to go Back?'),
        actions: [
          cancelButton,
          continueButton,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "Add Company Details",
            style: new TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: company,
                    obscureText: false,
                    autofocus: false,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.multiline,
                    inputFormatters: [
                      new WhitelistingTextInputFormatter(
                          RegExp("[A-Za-z0-9 ]")),
                    ],
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                        border: InputBorder.none,
                        labelText: 'Enter Company Name',
                        labelStyle: TextStyle(color: Colors.blueGrey)),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: Text(
                      "Select Category :",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SingleChildScrollView(
                    //padding: EdgeInsets.all(10),
                    scrollDirection: Axis.horizontal,
                    child: RadioButtonGroup(
                      orientation: GroupedButtonsOrientation.HORIZONTAL,
                      onSelected: (String selected) => setState(() {
                        filter = selected;
                        print(this.filter);
                      }),
                      labels: filterTypes,
                      labelStyle:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      picked: filter,
                      activeColor: Colors.green,
                      itemBuilder: (Radio rb, Text txt, int i) {
                        return Row(
                          children: <Widget>[
                            rb,
                            txt,
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  new Container(
                      decoration: new BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: new ListTile(
                          title: Text(
                            'Add Eligibility Criteria',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.remove, color: Colors.white),
                                  onPressed: () {
                                    if (this.showWidgetEC != false) {
                                      setState(() {
                                        this.showWidgetEC = false;
                                      });
                                    }
                                  }),
                              IconButton(
                                  icon: Icon(Icons.add, color: Colors.white),
                                  onPressed: () {
                                    if (this.showWidgetEC != true) {
                                      setState(() {
                                        this.showWidgetEC = true;
                                      });
                                    }
                                  }),
                            ],
                          ))),
                  this.showWidgetEC
                      ? keyValue(true)
                      : Padding(padding: EdgeInsets.all(0)),
                  Padding(padding: EdgeInsets.all(5)),
                  new Container(
                      decoration: new BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: new ListTile(
                          title: Text(
                            'Add Job Decription',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.remove, color: Colors.white),
                                  onPressed: () {
                                    if (this.showWidgetJD != false) {
                                      setState(() {
                                        this.showWidgetJD = false;
                                      });
                                    }
                                  }),
                              IconButton(
                                  icon: Icon(Icons.add, color: Colors.white),
                                  onPressed: () {
                                    if (this.showWidgetJD != true) {
                                      setState(() {
                                        this.showWidgetJD = true;
                                      });
                                    }
                                  }),
                            ],
                          ))),
                  this.showWidgetJD
                      ? keyValue(false)
                      : Padding(padding: EdgeInsets.all(0)),
                  Padding(padding: EdgeInsets.all(5)),
                  new Container(
                      decoration: new BoxDecoration(
                        border: Border.all(width: 1.5, color: Colors.cyan),
                      ),
                      child: new ListTile(
                          title: Text(
                            'Interview Details',
                            style: TextStyle(
                                color: Colors.pink,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                          ),
                          trailing:
                              whatToLoadwhileUploading("Interview Details"))),
                  Padding(padding: EdgeInsets.all(5)),
                  new Container(
                      decoration: new BoxDecoration(
                        border: Border.all(width: 1.5, color: Colors.cyan),
                      ),
                      child: new ListTile(
                          title: Text(
                            'Interview Questions',
                            style: TextStyle(
                                color: Colors.pink,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                          ),
                          trailing:
                              whatToLoadwhileUploading("Interview Questions"))),
                ],
              ),
            )),
        bottomNavigationBar: BottomAppBar(
          child: RaisedButton(
            textColor: Colors.black,
            onPressed: () {
              setState(() {
                this.companyName = company.text.trim().toString().toLowerCase();
              });
              if (this.companyName == null || this.companyName.length == 0) {
                Fluttertoast.showToast(
                    msg: "Company Name can't be EMPTY!",
                    toastLength: Toast.LENGTH_LONG,
                    backgroundColor: Colors.deepOrange,
                    textColor: Colors.white);
              }
              if (this.filter == null || this.filter.length == 0) {
                Fluttertoast.showToast(
                    msg: "Filter can't be EMPTY!",
                    toastLength: Toast.LENGTH_LONG,
                    backgroundColor: Colors.deepOrange,
                    textColor: Colors.white);
              }
              if (this.companyName.length != 0 && this.filter.length != 0) {
                CompanyDetails companyDetails =
                    new CompanyDetails(companyName, filter, ec, jd);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return DisplayandSubmitCompanyDetails(
                          companyDetails, "Review and Submit");
                    },
                  ),
                );
              }
            },
            color: Colors.orange,
            child: Text(
              "R E V I E W   &   S U B M I T",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget keyValue(bool what) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(10),
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            children: <Widget>[
              TextField(
                controller: what ? keyEC : keyJD,
                obscureText: false,
                autofocus: false,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.multiline,
                inputFormatters: [
                  new WhitelistingTextInputFormatter(RegExp("[A-Za-z0-9 ]")),
                ],
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  hintText: 'Enter Key',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextField(
                controller: what ? valueEC : valueJD,
                obscureText: false,
                autofocus: false,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  hintText: 'Enter Value',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  if (what) {
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                    setState(() {
                      if (keyEC.text.length == 0 || valueEC.text.length == 0) {
                        Fluttertoast.showToast(
                            msg: "Field Values can't be EMPTY!",
                            toastLength: Toast.LENGTH_LONG,
                            backgroundColor: Colors.deepOrange,
                            textColor: Colors.white);
                      } else {
                        if (this.ec.containsKey(keyEC.text.trim().toString())) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 5), () {
                                  Navigator.of(context).pop();
                                });
                                return AlertDialog(
                                  title: Text('Key already Exists!'),
                                  content: Text("Key    : " +
                                      keyEC.text.trim().toString() +
                                      "\n" +
                                      "Value : " +
                                      this.ec[keyEC.text.trim().toString()]),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Still Update?",
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          this.ec[keyEC.text
                                                  .trim()
                                                  .toString()] =
                                              valueEC.text.trim().toString();
                                          this.showWidgetEC = false;
                                          keyEC.clear();
                                          valueEC.clear();
                                        });
                                        Navigator.of(context)
                                            .pop(); // dismiss dialog
                                      },
                                    )
                                  ],
                                );
                              });
                        } else {
                          this.ec[keyEC.text.trim().toString()] =
                              valueEC.text.trim().toString();
                          this.showWidgetEC = false;
                          keyEC.clear();
                          valueEC.clear();
                        }
                      }
                    });
                  } else {
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                    setState(() {
                      if (keyJD.text.length == 0 || valueJD.text.length == 0) {
                        Fluttertoast.showToast(
                            msg: "Field Values can't be EMPTY!",
                            toastLength: Toast.LENGTH_LONG,
                            backgroundColor: Colors.deepOrange,
                            textColor: Colors.white);
                      } else {
                        if (this.jd.containsKey(keyJD.text.trim().toString())) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 5), () {
                                  Navigator.of(context).pop();
                                });
                                return AlertDialog(
                                  title: Text('Key already Exists!'),
                                  content: Text("Key    : " +
                                      keyJD.text.trim().toString() +
                                      "\n" +
                                      "Value : " +
                                      this.jd[keyJD.text.trim().toString()]),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Still Update?",
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          this.jd[keyJD.text
                                                  .trim()
                                                  .toString()] =
                                              valueJD.text.trim().toString();
                                          this.showWidgetJD = false;
                                          keyJD.clear();
                                          valueJD.clear();
                                        });
                                        Navigator.of(context)
                                            .pop(); // dismiss dialog
                                      },
                                    )
                                  ],
                                );
                              });
                        } else {
                          this.jd[keyJD.text.trim().toString()] =
                              valueJD.text.trim().toString();
                          this.showWidgetJD = false;
                          keyJD.clear();
                          valueJD.clear();
                        }
                      }
                    });
                  }
                },
                color: Colors.pink,
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ));
  }

  Widget whatToLoadwhileUploading(String whatToDownload) {
    if (whatToDownload == "Interview Details") {
      if (this.interviewDetailsStatus == Status.start.index) {
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
                setState(() {
                  this.companyName =
                      company.text.trim().toString().toLowerCase();
                });
                if (this.companyName.length == 0) {
                  Fluttertoast.showToast(
                      msg: "Enter Company Name to upload",
                      toastLength: Toast.LENGTH_SHORT,
                      backgroundColor: Colors.cyan,
                      textColor: Colors.white);
                } else {
                  setState(() {
                    this.interviewDetails = this.companyName + "_details.pdf";
                    this.interviewDetailsStatus = Status.running.index;
                  });
                  filePicker(context, this.interviewDetails, "details");
                }
              }
            });
          },
        ));
      } else if (this.interviewDetailsStatus == Status.running.index) {
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
    } else if (whatToDownload == "Interview Questions") {
      if (this.interviewQuestionsStatus == Status.start.index) {
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
                setState(() {
                  this.companyName =
                      company.text.trim().toString().toLowerCase();
                });
                if (this.companyName.length == 0) {
                  Fluttertoast.showToast(
                      msg: "Enter Company Name to upload",
                      toastLength: Toast.LENGTH_SHORT,
                      backgroundColor: Colors.cyan,
                      textColor: Colors.white);
                } else {
                  setState(() {
                    this.interviewQuestions =
                        this.companyName + "_questions.pdf";
                    this.interviewQuestionsStatus = Status.running.index;
                  });
                  filePicker(context, this.interviewQuestions, "questions");
                }
              }
            });
          },
        ));
      } else if (this.interviewQuestionsStatus == Status.running.index) {
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
