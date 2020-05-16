import 'package:adminplacements/home.dart';
import 'package:adminplacements/manageAdmins.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          title: "VNR CSE",
          home: Home(),
          debugShowCheckedModeBanner: false,
          routes: {
            "home": (context) => Home(),
            "manageAdmins": (context) => ManageAdmin(),
          },
        ));
  }
}
