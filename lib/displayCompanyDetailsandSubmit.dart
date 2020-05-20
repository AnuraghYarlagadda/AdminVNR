import 'dart:collection';
import 'package:adminplacements/DataModels/companyDetails.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DisplayandSubmitCompanyDetails extends StatefulWidget {
  final CompanyDetails companyDetails;
  const DisplayandSubmitCompanyDetails(this.companyDetails);
  @override
  State<StatefulWidget> createState() {
    return DisplayandSubmitCompanyDetailsState();
  }
}

class DisplayandSubmitCompanyDetailsState
    extends State<DisplayandSubmitCompanyDetails> {
  CompanyDetails companyDetails;
  LinkedHashMap ec, jd;
  LinkedHashMap ecEdit, jdEdit;
  double width, height;
  LinkedHashMap eckeyTextEditingControllers,
      jdkeyTextEditingControllers,
      ecvalueTextEditingControllers,
      jdvalueTextEditingControllers;

  final fb = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    this.companyDetails = widget.companyDetails;
    this.ecEdit = new LinkedHashMap<dynamic, bool>();
    this.jdEdit = new LinkedHashMap<dynamic, bool>();
    this.companyDetails.ec.forEach((k, v) => {this.ecEdit[k] = false});
    this.companyDetails.jd.forEach((k, v) => {this.jdEdit[k] = false});
    this.eckeyTextEditingControllers =
        new LinkedHashMap<dynamic, TextEditingController>();
    this.jdkeyTextEditingControllers =
        new LinkedHashMap<dynamic, TextEditingController>();
    this.ecvalueTextEditingControllers =
        new LinkedHashMap<dynamic, TextEditingController>();
    this.jdvalueTextEditingControllers =
        new LinkedHashMap<dynamic, TextEditingController>();
    fetchDetails();
  }

  sort() {
    if (this.companyDetails != null && this.companyDetails.ec != null) {
      var sortedKeys = this.companyDetails.ec.keys.toList(growable: false)
        ..sort((a, b) => a.compareTo(b));
      setState(() {
        this.ec = new LinkedHashMap.fromIterable(sortedKeys,
            key: (k) => k, value: (k) => this.companyDetails.ec[k]);
      });
    }
    if (this.companyDetails != null && this.companyDetails.jd != null) {
      var sortedKeys = this.companyDetails.jd.keys.toList(growable: false)
        ..sort((a, b) => a.compareTo(b));
      setState(() {
        this.jd = new LinkedHashMap.fromIterable(sortedKeys,
            key: (k) => k, value: (k) => this.companyDetails.jd[k]);
      });
    }
  }

  fetchDetails() {
    sort();
  }

  postFirebase(CompanyDetails companyDetails) {
    final ref = fb.reference();
    try {
      ref
          .child("Company")
          .child(companyDetails.companyName)
          .set(companyDetails.toJson());
      ref
          .child("Filter")
          .child(companyDetails.filter)
          .child(companyDetails.companyName)
          .set(companyDetails.companyName);
      Fluttertoast.showToast(
          msg: companyDetails.companyName + " Added Successfully!",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
          textColor: Colors.white);
      Navigator.of(context).pushNamed("home");
    } on PlatformException catch (e) {
      print("Oops! " + e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    print("Dispose");
    this.eckeyTextEditingControllers.forEach((k, v) => {v.dispose()});
    this.ecvalueTextEditingControllers.forEach((k, v) => {v.dispose()});
    this.jdkeyTextEditingControllers.forEach((k, v) => {v.dispose()});
    this.jdvalueTextEditingControllers.forEach((k, v) => {v.dispose()});
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
        content: new Text(
            'Any changes made to the Data will be Lost if you proceed to go back!'),
        actions: [
          cancelButton,
          continueButton,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    this.height = MediaQuery.of(context).size.height;
    this.width = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: AppBar(title: Text("Review and Submit")),
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: companyDetails == null
                      ? Center(
                          child: SpinKitDualRing(color: Colors.pink),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  child: ec == null
                                      ? Text("")
                                      : Column(children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                          ),
                                          this.ec.length != 0
                                              ? Text(
                                                  "Eligibility Criteria",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.all(0),
                                                ),
                                          ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: ec.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              String key =
                                                  ec.keys.elementAt(index);

                                              this.eckeyTextEditingControllers[
                                                      key] =
                                                  new TextEditingController();
                                              this
                                                  .eckeyTextEditingControllers[
                                                      key]
                                                  .text = key;
                                              this
                                                      .eckeyTextEditingControllers[
                                                          key]
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: this
                                                              .eckeyTextEditingControllers[
                                                                  key]
                                                              .text
                                                              .length));
                                              this.ecvalueTextEditingControllers[
                                                      key] =
                                                  new TextEditingController();
                                              this
                                                  .ecvalueTextEditingControllers[
                                                      key]
                                                  .text = this.ec[key];
                                              this
                                                      .ecvalueTextEditingControllers[
                                                          key]
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: this
                                                              .ecvalueTextEditingControllers[
                                                                  key]
                                                              .text
                                                              .length));

                                              return new Column(
                                                children: <Widget>[
                                                  new ListTile(
                                                    trailing: this.ecEdit[key]
                                                        ? IconButton(
                                                            icon: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                              size: 35,
                                                            ),
                                                            onPressed: () {
                                                              String
                                                                  newKey = this
                                                                      .eckeyTextEditingControllers[
                                                                          key]
                                                                      .text
                                                                      .toString()
                                                                      .trim(),
                                                                  newValue = this
                                                                      .ecvalueTextEditingControllers[
                                                                          key]
                                                                      .text
                                                                      .toString()
                                                                      .trim();
                                                              if (newKey.length ==
                                                                      0 ||
                                                                  newValue.length ==
                                                                      0) {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "Field Values can't be EMPTY!",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_LONG,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .deepOrange,
                                                                    textColor:
                                                                        Colors
                                                                            .white);
                                                              } else {
                                                                setState(() {
                                                                  if (key !=
                                                                          newKey &&
                                                                      this.ec[key] !=
                                                                          newValue) {
                                                                    this
                                                                        .ec
                                                                        .remove(
                                                                            key);
                                                                    this
                                                                        .ecEdit
                                                                        .remove(
                                                                            key);
                                                                    this.ec[newKey] =
                                                                        newValue;
                                                                    this.ecEdit[
                                                                            newKey] =
                                                                        false;
                                                                  } else if (key ==
                                                                          newKey &&
                                                                      this.ec[key] !=
                                                                          newValue) {
                                                                    this.ec[key] =
                                                                        newValue;
                                                                    this.ecEdit[
                                                                            key] =
                                                                        false;
                                                                  } else if (key !=
                                                                          newKey &&
                                                                      this.ec[key] ==
                                                                          newValue) {
                                                                    this
                                                                        .ec
                                                                        .remove(
                                                                            key);
                                                                    this
                                                                        .ecEdit
                                                                        .remove(
                                                                            key);
                                                                    this.ec[newKey] =
                                                                        newValue;
                                                                    this.ecEdit[
                                                                            newKey] =
                                                                        false;
                                                                  } else {
                                                                    this.ecEdit[
                                                                            newKey] =
                                                                        false;
                                                                  }
                                                                });
                                                              }
                                                            })
                                                        : IconButton(
                                                            icon: Icon(
                                                              Icons.edit,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                this.ecEdit[
                                                                    key] = !this
                                                                        .ecEdit[
                                                                    key];
                                                              });
                                                            }),
                                                    title: this.ecEdit[key]
                                                        ? TextField(
                                                            controller:
                                                                this.eckeyTextEditingControllers[
                                                                    key],
                                                            textAlign:
                                                                TextAlign.left,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            maxLines: null,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blueGrey),
                                                              ),
                                                            ),
                                                          )
                                                        : new Text(
                                                            "$key"
                                                                .toString()
                                                                .trim(),
                                                            style: TextStyle(
                                                                //fontSize: 20,
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal),
                                                          ),
                                                    subtitle: this.ecEdit[key]
                                                        ? TextField(
                                                            controller:
                                                                this.ecvalueTextEditingControllers[
                                                                    key],
                                                            textAlign:
                                                                TextAlign.left,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blueGrey),
                                                              ),
                                                            ),
                                                          )
                                                        : new Text(
                                                            "${ec[key]}"
                                                                .toString()
                                                                .trim(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                  ),
                                                  new Divider(
                                                    height: 3,
                                                    thickness: 2,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ])),
                              Container(
                                  child: jd == null
                                      ? Text("")
                                      : Column(children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                          ),
                                          this.jd.length != 0
                                              ? Text(
                                                  "Job Description",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.all(0),
                                                ),
                                          ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: jd.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              String key =
                                                  jd.keys.elementAt(index);

                                              this.jdkeyTextEditingControllers[
                                                      key] =
                                                  new TextEditingController();
                                              this
                                                  .jdkeyTextEditingControllers[
                                                      key]
                                                  .text = key;
                                              this
                                                      .jdkeyTextEditingControllers[
                                                          key]
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: this
                                                              .jdkeyTextEditingControllers[
                                                                  key]
                                                              .text
                                                              .length));
                                              this.jdvalueTextEditingControllers[
                                                      key] =
                                                  new TextEditingController();
                                              this
                                                  .jdvalueTextEditingControllers[
                                                      key]
                                                  .text = this.jd[key];
                                              this
                                                      .jdvalueTextEditingControllers[
                                                          key]
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: this
                                                              .jdvalueTextEditingControllers[
                                                                  key]
                                                              .text
                                                              .length));

                                              return new Column(
                                                children: <Widget>[
                                                  new ListTile(
                                                    trailing: this.jdEdit[key]
                                                        ? IconButton(
                                                            icon: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                              size: 35,
                                                            ),
                                                            onPressed: () {
                                                              String
                                                                  newKey = this
                                                                      .jdkeyTextEditingControllers[
                                                                          key]
                                                                      .text
                                                                      .toString()
                                                                      .trim(),
                                                                  newValue = this
                                                                      .jdvalueTextEditingControllers[
                                                                          key]
                                                                      .text
                                                                      .toString()
                                                                      .trim();
                                                              if (newKey.length ==
                                                                      0 ||
                                                                  newValue.length ==
                                                                      0) {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "Field Values can't be EMPTY!",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_LONG,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .deepOrange,
                                                                    textColor:
                                                                        Colors
                                                                            .white);
                                                              } else {
                                                                setState(() {
                                                                  if (key !=
                                                                          newKey &&
                                                                      this.jd[key] !=
                                                                          newValue) {
                                                                    this
                                                                        .jd
                                                                        .remove(
                                                                            key);
                                                                    this
                                                                        .jdEdit
                                                                        .remove(
                                                                            key);
                                                                    this.jd[newKey] =
                                                                        newValue;
                                                                    this.jdEdit[
                                                                            newKey] =
                                                                        false;
                                                                  } else if (key ==
                                                                          newKey &&
                                                                      this.jd[key] !=
                                                                          newValue) {
                                                                    this.jd[key] =
                                                                        newValue;
                                                                    this.jdEdit[
                                                                            key] =
                                                                        false;
                                                                  } else if (key !=
                                                                          newKey &&
                                                                      this.jd[key] ==
                                                                          newValue) {
                                                                    this
                                                                        .jd
                                                                        .remove(
                                                                            key);
                                                                    this
                                                                        .jdEdit
                                                                        .remove(
                                                                            key);
                                                                    this.jd[newKey] =
                                                                        newValue;
                                                                    this.jdEdit[
                                                                            newKey] =
                                                                        false;
                                                                  } else {
                                                                    this.jdEdit[
                                                                            newKey] =
                                                                        false;
                                                                  }
                                                                });
                                                              }
                                                            })
                                                        : IconButton(
                                                            icon: Icon(
                                                              Icons.edit,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                this.jdEdit[
                                                                    key] = !this
                                                                        .jdEdit[
                                                                    key];
                                                              });
                                                            }),
                                                    title: this.jdEdit[key]
                                                        ? TextField(
                                                            controller:
                                                                this.jdkeyTextEditingControllers[
                                                                    key],
                                                            textAlign:
                                                                TextAlign.left,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            maxLines: null,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blueGrey),
                                                              ),
                                                            ),
                                                          )
                                                        : new Text(
                                                            "$key"
                                                                .toString()
                                                                .trim(),
                                                            style: TextStyle(
                                                                //fontSize: 20,
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal),
                                                          ),
                                                    subtitle: this.jdEdit[key]
                                                        ? TextField(
                                                            controller:
                                                                this.jdvalueTextEditingControllers[
                                                                    key],
                                                            textAlign:
                                                                TextAlign.left,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blueGrey),
                                                              ),
                                                            ),
                                                          )
                                                        : new Text(
                                                            "${jd[key]}"
                                                                .toString()
                                                                .trim(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                  ),
                                                  new Divider(
                                                    height: 3,
                                                    thickness: 2,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ])),
                              RaisedButton(
                                onPressed: () {
                                  companyDetails.ec = this.ec;
                                  companyDetails.jd = this.jd;
                                  postFirebase(companyDetails);
                                },
                                child: Text("SUBMIT"),
                                color: Colors.green,
                                textColor: Colors.white,
                                elevation: 15,
                              ),
                            ],
                          ))),
            )));
  }
}
