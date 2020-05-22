import 'package:adminplacements/addCompany.dart';
import 'package:adminplacements/displayCompaniesList.dart';
import 'package:adminplacements/settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ManageCompanies extends StatefulWidget {
  ManageCompaniesState createState() => ManageCompaniesState();
}

class ManageCompaniesState extends State<ManageCompanies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.track_changes),
        title: Text("Manage Companies"),
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
                Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                ListTile(
                  title: Text(
                    "Add Company Details",
                    style: TextStyle(
                        fontSize: 21,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal),
                  ),
                  subtitle: Text(
                    "- Add Company Name\n- Select Filter\n- Eligibility Criteria and Job Description has to be added like Key Value pairs.\n- Ex: {Package,18 LPA}",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 25,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      await (Connectivity().checkConnectivity())
                          .then((onValue) {
                        if (onValue == ConnectivityResult.none) {
                          Fluttertoast.showToast(
                              msg: "No Active Internet Connection!",
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.red,
                              textColor: Colors.white);
                          openWIFISettingsVNR();
                        } else {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return AddCompany();
                          }));
                        }
                      });
                    },
                  ),
                ),
                Divider(
                  thickness: 2.5,
                  height: 2.5,
                ),
                ListTile(
                  title: Text(
                    "Modify Existing Company Details",
                    style: TextStyle(
                        fontSize: 21,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal),
                  ),
                  subtitle: Text(
                    "-Delete a Company\n- Modify/Append Eligibility Criteria and Job Description details",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.mode_edit,
                      size: 25,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      await (Connectivity().checkConnectivity())
                          .then((onValue) {
                        if (onValue == ConnectivityResult.none) {
                          Fluttertoast.showToast(
                              msg: "No Active Internet Connection!",
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.red,
                              textColor: Colors.white);
                          openWIFISettingsVNR();
                        } else {
                          Navigator.of(context)
                              .pushNamed("displayCompaniesList");
                        }
                      });
                    },
                  ),
                ),
                Divider(
                  thickness: 2.5,
                  height: 2.5,
                )
              ],
            )),
      ),
    );
  }
}
