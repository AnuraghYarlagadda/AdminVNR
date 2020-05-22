import 'dart:collection';

import 'package:adminplacements/DataModels/companyDetails.dart';
import 'package:adminplacements/displayCompanyDetailsandSubmit.dart';
import 'package:adminplacements/settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum Status { loading, loaded }

class DisplayCompaniesList extends StatefulWidget {
  DisplayCompaniesListState createState() => DisplayCompaniesListState();
}

class DisplayCompaniesListState extends State<DisplayCompaniesList> {
  TextEditingController editingController = TextEditingController();
  final fb = FirebaseDatabase.instance;

  SplayTreeSet companies, items;
  int _status;

  CompanyDetails companyDetails;

  @override
  void dispose() {
    editingController.clear();
    editingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    this._status = Status.loading.index;
    this.companies = new SplayTreeSet<dynamic>();
    this.items = new SplayTreeSet<dynamic>();
    firebaseListeners();
    super.initState();
  }

  firebaseListeners() {
    final ref = fb.reference();
    ref.child("Filter").child("Core").once().then((DataSnapshot data) {
      setState(() {
        this.companies.addAll(data.value.values.toList());
        this.items.addAll(this.companies);
        this._status = Status.loaded.index;
      });
    });
    ref
        .child("Filter")
        .child("Software and Service")
        .once()
        .then((DataSnapshot data) {
      setState(() {
        this.companies.addAll(data.value.values.toList());
        this.items.addAll(this.companies);
        this._status = Status.loaded.index;
      });
    });
    ref
        .child("Filter")
        .child("Software and Product")
        .once()
        .then((DataSnapshot data) {
      setState(() {
        this.companies.addAll(data.value.values.toList());
        this.items.addAll(this.companies);
        items.addAll(this.companies);
        this._status = Status.loaded.index;
      });
    });
    ref
        .child("Filter")
        .child("Software and Service")
        .onChildRemoved
        .listen((onData) {
      print(onData.snapshot.value);
      setState(() {
        try {
          this.companies.remove(onData.snapshot.value);
          this.items.remove(onData.snapshot.value);
        } catch (identifier) {
          print("Removed  ");
          print(identifier);
        }
      });
    });
    ref
        .child("Filter")
        .child("Software and Product")
        .onChildRemoved
        .listen((onData) {
      print(onData.snapshot.value);
      setState(() {
        try {
          this.companies.remove(onData.snapshot.value);
          this.items.remove(onData.snapshot.value);
        } catch (identifier) {
          print("Removed  ");
          print(identifier);
        }
      });
    });
    ref.child("Filter").child("Core").onChildRemoved.listen((onData) {
      print(onData.snapshot.value);
      setState(() {
        try {
          this.companies.remove(onData.snapshot.value);
          this.items.remove(onData.snapshot.value);
        } catch (identifier) {
          print("Removed  ");
          print(identifier);
        }
      });
    });
  }

  getData(BuildContext context, String companyName) {
    final ref = fb.reference();
    String id = companyName.trim().toLowerCase();
    ref.child("Company").child(id).once().then((DataSnapshot data) {
      setState(() {
        this.companyDetails = CompanyDetails.fromSnapshot(data);
        if (this.companyDetails != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return DisplayandSubmitCompanyDetails(
                    this.companyDetails, "Edit and Submit");
              },
            ),
          );
        }
      });
    });
  }

  delFirebase(String companyName) {
    final ref = fb.reference();
    String id = companyName.trim().toLowerCase();
    print(id);
    ref.child("Filter").child("Core").child(id).remove();
    ref.child("Filter").child("Software and Service").child(id).remove();
    ref.child("Filter").child("Software and Product").child(id).remove();
    ref.child("Company").child(id).remove();
  }

  void filterSearchResults(String query) {
    List<dynamic> dummySearchList = List<dynamic>();
    dummySearchList.addAll(this.companies);
    if (query.isNotEmpty) {
      List<dynamic> dummyListData = List<dynamic>();
      dummySearchList.forEach((item) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(this.companies);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.search),
          centerTitle: true,
          title: TextField(
            controller: editingController,
            cursorColor: Colors.white,
            cursorWidth: 2.5,
            style: new TextStyle(
              color: Colors.white,
            ),
            onChanged: (value) {
              filterSearchResults(value.toLowerCase());
            },
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Search ",
                hintStyle: new TextStyle(color: Colors.white)),
          ),
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
          child: this._status == Status.loading.index
              ? Center(
                  child: SpinKitWave(
                      color: Colors.blue, type: SpinKitWaveType.start))
              : Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      ),
                      Expanded(
                        child: items.length == 0
                            ? Text("No such Company found..!")
                            : Scrollbar(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Card(
                                          elevation: 5,
                                          child: ListTile(
                                            title: Text(
                                              '${items.elementAt(index).toString().trim().toUpperCase()}',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    onPressed: () async {
                                                      await (Connectivity()
                                                              .checkConnectivity())
                                                          .then((onValue) {
                                                        if (onValue ==
                                                            ConnectivityResult
                                                                .none) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "No Active Internet Connection!",
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              textColor:
                                                                  Colors.white);
                                                          openWIFISettingsVNR();
                                                        } else {
                                                          getData(
                                                              context,
                                                              items.elementAt(
                                                                  index));
                                                        }
                                                      });
                                                    }),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.redAccent,
                                                    ),
                                                    onPressed: () async {
                                                      await (Connectivity()
                                                              .checkConnectivity())
                                                          .then((onValue) {
                                                        if (onValue ==
                                                            ConnectivityResult
                                                                .none) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "No Active Internet Connection!",
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              textColor:
                                                                  Colors.white);
                                                          openWIFISettingsVNR();
                                                        } else {
                                                          showAlertDialog(
                                                              context,
                                                              items
                                                                  .elementAt(
                                                                      index)
                                                                  .toString()
                                                                  .trim()
                                                                  .toUpperCase());
                                                        }
                                                      });
                                                    })
                                              ],
                                            ),
                                          )),
                                    );
                                  },
                                ),
                              ),
                      )
                    ],
                  ),
                ),
        ));
  }

  showAlertDialog(BuildContext context, String companyName) {
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
        delFirebase(companyName);
        Fluttertoast.showToast(
            msg: companyName + " Deleted!",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.red,
            textColor: Colors.white);
        Navigator.of(context).pop(); // dismiss dialog
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Company?"),
      content: Text(companyName),
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
