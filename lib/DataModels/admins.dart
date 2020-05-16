import 'package:firebase_database/firebase_database.dart';

class AdminDetails {
  String email;
  bool permission;

  AdminDetails(this.email, this.permission);

  AdminDetails.fromSnapshot(DataSnapshot snapshot)
      : email = snapshot.value["email"],
        permission = snapshot.value["permission"];

  toJson() {
    return {"email": email, "permission": permission};
  }
}
