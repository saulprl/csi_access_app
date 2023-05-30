import 'package:firebase_database/firebase_database.dart';

import "package:flutter_bcrypt/flutter_bcrypt.dart";

class CSIUser {
  String? key;
  int? csiId;
  String? name;
  String? unisonId;
  String? email;
  String? passcode;

  CSIUser({
    this.key,
    this.csiId,
    this.name,
    this.unisonId,
    this.email,
    this.passcode,
  });

  CSIUser.fromSnapshot(DataSnapshot snapshot) {
    final actualKey = (snapshot.value as Map).keys.first;

    key = actualKey;
    csiId = (snapshot.value as Map)[actualKey]["csiId"];
    name = (snapshot.value as Map)[actualKey]["name"];
    unisonId = (snapshot.value as Map)[actualKey]["unisonId"];
    email = (snapshot.value as Map)[actualKey]["email"];
    passcode = (snapshot.value as Map)[actualKey]["passcode"];
  }

  CSIUser.fromDirectSnapshot(DataSnapshot snapshot, String this.key) {
    csiId = (snapshot.value as Map)["csiId"];
    name = (snapshot.value as Map)["name"];
    unisonId = (snapshot.value as Map)["unisonId"];
    email = (snapshot.value as Map)["email"];
    passcode = (snapshot.value as Map)["passcode"];
  }

  Future<bool> compareCredentials(
      String unisonId, String csiId, String passcode) async {
    if (int.parse(csiId) != this.csiId || unisonId != this.unisonId) {
      return false;
    }

    return FlutterBcrypt.verify(password: passcode, hash: this.passcode!);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};

    json[key!] = {
      "csiId": csiId,
      "name": name,
      "unisonId": unisonId,
      "email": email,
      "passcode": passcode,
    };

    return json;
  }
}
