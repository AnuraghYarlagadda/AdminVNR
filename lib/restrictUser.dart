import 'package:flutter/material.dart';

class NoAccess extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("You've no access to view the content!"),
      ),
    );
  }
}