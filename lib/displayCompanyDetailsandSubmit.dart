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

  TextEditingController keyEC = new TextEditingController();
  TextEditingController valueEC = new TextEditingController();
  TextEditingController keyJD = new TextEditingController();
  TextEditingController valueJD = new TextEditingController();

  bool showWidgetEC = false;
  bool showWidgetJD = false;

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
                                                0, 10, 0, 0),
                                          ),
                                          this.ec.length != 0
                                              ? new Container(
                                                  child: ListTile(
                                                      title: Text(
                                                        "Eligibility Criteria",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle: FontStyle
                                                                .italic),
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          IconButton(
                                                              icon: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black),
                                                              onPressed: () {
                                                                if (this.showWidgetEC !=
                                                                    false) {
                                                                  setState(() {
                                                                    this.showWidgetEC =
                                                                        false;
                                                                  });
                                                                }
                                                              }),
                                                          IconButton(
                                                              icon: Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .black),
                                                              onPressed: () {
                                                                if (this.showWidgetEC !=
                                                                    true) {
                                                                  setState(() {
                                                                    this.showWidgetEC =
                                                                        true;
                                                                  });
                                                                }
                                                              }),
                                                        ],
                                                      )))
                                              : Padding(
                                                  padding: EdgeInsets.all(0),
                                                ),
                                          this.showWidgetEC
                                              ? keyValue(true)
                                              : Padding(
                                                  padding: EdgeInsets.all(0)),
                                          ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: this.ec.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              String key =
                                                  this.ec.keys.elementAt(index);
                                              print(key);
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
                                                  this.ecEdit.containsKey(key)
                                                      ? ListTile(
                                                          trailing: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              this.ecEdit[key]
                                                                  ? IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .green,
                                                                        size:
                                                                            35,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        String
                                                                            newKey = this.eckeyTextEditingControllers[key].text.toString().trim(),
                                                                            newValue =
                                                                                this.ecvalueTextEditingControllers[key].text.toString().trim();
                                                                        if (newKey.length ==
                                                                                0 ||
                                                                            newValue.length ==
                                                                                0) {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Field Values can't be EMPTY!",
                                                                              toastLength: Toast.LENGTH_LONG,
                                                                              backgroundColor: Colors.deepOrange,
                                                                              textColor: Colors.white);
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            if (key != newKey &&
                                                                                this.ec[key] != newValue) {
                                                                              this.ec.remove(key);
                                                                              this.ecEdit.remove(key);
                                                                              this.ec[newKey] = newValue;
                                                                              this.ecEdit[newKey] = false;
                                                                            } else if (key == newKey &&
                                                                                this.ec[key] != newValue) {
                                                                              this.ec[key] = newValue;
                                                                              this.ecEdit[key] = false;
                                                                            } else if (key != newKey &&
                                                                                this.ec[key] == newValue) {
                                                                              this.ec.remove(key);
                                                                              this.ecEdit.remove(key);
                                                                              this.ec[newKey] = newValue;
                                                                              this.ecEdit[newKey] = false;
                                                                            } else {
                                                                              this.ecEdit[newKey] = false;
                                                                            }
                                                                          });
                                                                        }
                                                                      })
                                                                  : IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: Colors
                                                                            .deepPurple,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          this.ecEdit[key] =
                                                                              !this.ecEdit[key];
                                                                        });
                                                                      }),
                                                              IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .remove_circle,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Do you want to DEL?'),
                                                                            content: Text("Key    : " +
                                                                                key +
                                                                                "\n" +
                                                                                "Value : " +
                                                                                this.ec[key]),
                                                                            actions: <Widget>[
                                                                              FlatButton(
                                                                                child: Text(
                                                                                  "NO",
                                                                                  style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop(); // dismiss dialog
                                                                                },
                                                                              ),
                                                                              FlatButton(
                                                                                child: Text(
                                                                                  "DEL",
                                                                                  style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    this.ec.remove(key);
                                                                                    this.ecEdit.remove(key);
                                                                                  });
                                                                                  Navigator.of(context).pop(); // dismiss dialog
                                                                                },
                                                                              ),
                                                                            ],
                                                                          );
                                                                        });
                                                                  })
                                                            ],
                                                          ),
                                                          title:
                                                              this.ecEdit[key]
                                                                  ? TextField(
                                                                      controller:
                                                                          this.eckeyTextEditingControllers[
                                                                              key],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .multiline,
                                                                      maxLines:
                                                                          null,
                                                                      inputFormatters: [
                                                                        new WhitelistingTextInputFormatter(
                                                                            RegExp("[A-Za-z0-9 ]")),
                                                                      ],
                                                                      decoration:
                                                                          InputDecoration(
                                                                        enabledBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.blueGrey),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : new Text(
                                                                      "$key"
                                                                          .toString()
                                                                          .trim(),
                                                                      style: TextStyle(
                                                                          //fontSize: 20,
                                                                          color: Colors.blue,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontStyle: FontStyle.normal),
                                                                    ),
                                                          subtitle:
                                                              this.ecEdit[key]
                                                                  ? TextField(
                                                                      controller:
                                                                          this.ecvalueTextEditingControllers[
                                                                              key],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .multiline,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        enabledBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.blueGrey),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : new Text(
                                                                      "${ec[key]}"
                                                                          .toString()
                                                                          .trim(),
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.all(0),
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
                                                0, 10, 0, 0),
                                          ),
                                          this.jd.length != 0
                                              ? new Container(
                                                  child: ListTile(
                                                      title: Text(
                                                        "Job Decription",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle: FontStyle
                                                                .italic),
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          IconButton(
                                                              icon: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black),
                                                              onPressed: () {
                                                                if (this.showWidgetJD !=
                                                                    false) {
                                                                  setState(() {
                                                                    this.showWidgetJD =
                                                                        false;
                                                                  });
                                                                }
                                                              }),
                                                          IconButton(
                                                              icon: Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .black),
                                                              onPressed: () {
                                                                if (this.showWidgetJD !=
                                                                    true) {
                                                                  setState(() {
                                                                    this.showWidgetJD =
                                                                        true;
                                                                  });
                                                                }
                                                              }),
                                                        ],
                                                      )))
                                              : Padding(
                                                  padding: EdgeInsets.all(0),
                                                ),
                                          this.showWidgetJD
                                              ? keyValue(false)
                                              : Padding(
                                                  padding: EdgeInsets.all(0)),
                                          ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: this.jd.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              String key =
                                                  this.jd.keys.elementAt(index);
                                              print(key);
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
                                                  this.jdEdit.containsKey(key)
                                                      ? ListTile(
                                                          trailing: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              this.jdEdit[key]
                                                                  ? IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .green,
                                                                        size:
                                                                            35,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        String
                                                                            newKey = this.jdkeyTextEditingControllers[key].text.toString().trim(),
                                                                            newValue =
                                                                                this.jdvalueTextEditingControllers[key].text.toString().trim();
                                                                        if (newKey.length ==
                                                                                0 ||
                                                                            newValue.length ==
                                                                                0) {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Field Values can't be EMPTY!",
                                                                              toastLength: Toast.LENGTH_LONG,
                                                                              backgroundColor: Colors.deepOrange,
                                                                              textColor: Colors.white);
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            if (key != newKey &&
                                                                                this.jd[key] != newValue) {
                                                                              this.jd.remove(key);
                                                                              this.jdEdit.remove(key);
                                                                              this.jd[newKey] = newValue;
                                                                              this.jdEdit[newKey] = false;
                                                                            } else if (key == newKey &&
                                                                                this.jd[key] != newValue) {
                                                                              this.jd[key] = newValue;
                                                                              this.jdEdit[key] = false;
                                                                            } else if (key != newKey &&
                                                                                this.jd[key] == newValue) {
                                                                              this.jd.remove(key);
                                                                              this.jdEdit.remove(key);
                                                                              this.jd[newKey] = newValue;
                                                                              this.jdEdit[newKey] = false;
                                                                            } else {
                                                                              this.jdEdit[newKey] = false;
                                                                            }
                                                                          });
                                                                        }
                                                                      })
                                                                  : IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: Colors
                                                                            .deepPurple,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          this.jdEdit[key] =
                                                                              !this.jdEdit[key];
                                                                        });
                                                                      }),
                                                              IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .remove_circle,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Do you want to DEL?'),
                                                                            content: Text("Key    : " +
                                                                                key +
                                                                                "\n" +
                                                                                "Value : " +
                                                                                this.jd[key]),
                                                                            actions: <Widget>[
                                                                              FlatButton(
                                                                                child: Text(
                                                                                  "NO",
                                                                                  style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop(); // dismiss dialog
                                                                                },
                                                                              ),
                                                                              FlatButton(
                                                                                child: Text(
                                                                                  "DEL",
                                                                                  style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    this.jd.remove(key);
                                                                                    this.jdEdit.remove(key);
                                                                                  });
                                                                                  Navigator.of(context).pop(); // dismiss dialog
                                                                                },
                                                                              ),
                                                                            ],
                                                                          );
                                                                        });
                                                                  })
                                                            ],
                                                          ),
                                                          title:
                                                              this.jdEdit[key]
                                                                  ? TextField(
                                                                      controller:
                                                                          this.jdkeyTextEditingControllers[
                                                                              key],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .multiline,
                                                                      maxLines:
                                                                          null,
                                                                      inputFormatters: [
                                                                        new WhitelistingTextInputFormatter(
                                                                            RegExp("[A-Za-z0-9 ]")),
                                                                      ],
                                                                      decoration:
                                                                          InputDecoration(
                                                                        enabledBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.blueGrey),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : new Text(
                                                                      "$key"
                                                                          .toString()
                                                                          .trim(),
                                                                      style: TextStyle(
                                                                          //fontSize: 20,
                                                                          color: Colors.blue,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontStyle: FontStyle.normal),
                                                                    ),
                                                          subtitle:
                                                              this.jdEdit[key]
                                                                  ? TextField(
                                                                      controller:
                                                                          this.jdvalueTextEditingControllers[
                                                                              key],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .multiline,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        enabledBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.blueGrey),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : new Text(
                                                                      "${jd[key]}"
                                                                          .toString()
                                                                          .trim(),
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.all(0),
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
                                  print(companyDetails.companyName);
                                  print(companyDetails.filter);
                                  print(companyDetails.ec);
                                  print(companyDetails.jd);
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
                                          this.ecEdit[keyEC.text
                                              .trim()
                                              .toString()] = false;
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
                          this.ecEdit[keyEC.text.trim().toString()] = false;
                          keyEC.clear();
                          valueEC.clear();
                        }
                      }
                    });
                    print(this.ec.length);
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
                                          this.jdEdit[keyJD.text
                                              .trim()
                                              .toString()] = false;
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
                          this.jdEdit[keyJD.text.trim().toString()] = false;
                          this.showWidgetJD = false;
                          keyJD.clear();
                          valueJD.clear();
                        }
                      }
                    });
                    print(this.jd.length);
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
}
