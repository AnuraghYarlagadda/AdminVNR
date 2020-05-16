import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';

class CompanyDetails {
  String companyName, filter;
  LinkedHashMap<dynamic, dynamic> ec, jd;

  CompanyDetails(this.companyName, this.filter, this.ec, this.jd);

  CompanyDetails.fromSnapshot(DataSnapshot snapshot)
      : companyName = snapshot.value["companyName"],
        filter = snapshot.value["filter"],
        ec = snapshot.value["ec"],
        jd = snapshot.value["jd"];

  toJson() {
    return {"companyName": companyName, "filter": filter, "jd": jd, "ec": ec};
  }
}