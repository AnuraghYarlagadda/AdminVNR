import 'package:adminplacements/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return (MaterialApp(
      title: "VNR CSE",
      home: Home(),
      debugShowCheckedModeBanner: false,
      routes: {
        "home": (context) => Home(),
      },
    ));
  }
}
