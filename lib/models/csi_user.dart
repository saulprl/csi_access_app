import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import "package:flutter_bcrypt/flutter_bcrypt.dart";

class CSIUser {
  late String key;
  late int csiId;
  late String name;
  late String unisonId;
  late String email;
  late String passcode;
  late DocumentReference<Map<String, dynamic>> role;
  late bool isAllowedAccess;
  late Timestamp createdAt;
  late Timestamp dateOfBirth;

  CSIUser({
    required this.key,
    required this.csiId,
    required this.name,
    required this.unisonId,
    required this.email,
    required this.passcode,
    required this.role,
    required this.isAllowedAccess,
    required this.createdAt,
    required this.dateOfBirth,
  });

  CSIUser.fromDataSnapshot(DataSnapshot snapshot) {
    final actualKey = (snapshot.value as Map).keys.first;

    key = actualKey;
    csiId = (snapshot.value as Map)[actualKey]["csiId"];
    name = (snapshot.value as Map)[actualKey]["name"];
    unisonId = (snapshot.value as Map)[actualKey]["unisonId"];
    email = (snapshot.value as Map)[actualKey]["email"];
    passcode = (snapshot.value as Map)[actualKey]["passcode"];
    role = (snapshot.value as Map)[actualKey]["role"];
    isAllowedAccess = (snapshot.value as Map)[actualKey]["isAllowedAccess"];
    createdAt = (snapshot.value as Map)[actualKey]["createdAt"];
    dateOfBirth = (snapshot.value as Map)[actualKey]["dateOfBirth"];
  }

  CSIUser.fromDocQuerySnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    key = snapshot.id;
    csiId = data["csiId"];
    name = data["name"];
    unisonId = data["unisonId"];
    email = data["email"];
    passcode = data["passcode"];
    role = data["role"];
    isAllowedAccess = data["isAllowedAccess"];
    createdAt = data["createdAt"];
    dateOfBirth = data["dateOfBirth"];
  }

  CSIUser.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return;

    key = snapshot.id;
    csiId = data["csiId"];
    name = data["name"];
    unisonId = data["unisonId"];
    email = data["email"];
    passcode = data["passcode"];
    role = data["role"];
    isAllowedAccess = data["isAllowedAccess"];
    createdAt = data["createdAt"];
    dateOfBirth = data["dateOfBirth"];
  }

  CSIUser.fromDirectSnapshot(DataSnapshot snapshot, this.key) {
    csiId = (snapshot.value as Map)["csiId"];
    name = (snapshot.value as Map)["name"];
    unisonId = (snapshot.value as Map)["unisonId"];
    email = (snapshot.value as Map)["email"];
    passcode = (snapshot.value as Map)["passcode"];
    role = (snapshot.value as Map)["role"];
    isAllowedAccess = (snapshot.value as Map)["isAllowedAccess"];
    createdAt = (snapshot.value as Map)["createdAt"];
    dateOfBirth = (snapshot.value as Map)["dateOfBirth"];
  }

  Future<bool> compareCredentials(
      String unisonId, String csiId, String passcode) async {
    if (int.parse(csiId) != this.csiId || unisonId != this.unisonId) {
      return false;
    }

    return FlutterBcrypt.verify(password: passcode, hash: this.passcode);
  }

  Map<String, dynamic> toJson({bool keyless = false}) {
    Map<String, dynamic> json = <String, dynamic>{};
    Map<String, dynamic> data = {
      "csiId": csiId,
      "name": name,
      "unisonId": unisonId,
      "email": email,
      "passcode": passcode,
      "role": role,
      "isAllowedAccess": isAllowedAccess,
      "createdAt": createdAt,
      "dateOfBirth": dateOfBirth,
    };

    if (keyless) return data;

    json[key] = data;

    return json;
  }
}
