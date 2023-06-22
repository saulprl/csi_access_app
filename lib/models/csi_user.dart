import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import "package:flutter_bcrypt/flutter_bcrypt.dart";

class CSIUser {
  String? _key;
  int? _csiId;
  String? _name;
  String? _unisonId;
  String? _email;
  String? _passcode;
  DocumentReference? _role;
  bool? _isAllowedAccess;
  Timestamp? _createdAt;
  Timestamp? _dateOfBirth;

  String? get key => _key;

  set key(String? value) {
    _key = value;
  }

  int? get csiId => _csiId;

  set csiId(int? value) {
    _csiId = value;
  }

  String? get name => _name;

  set name(String? value) {
    _name = value;
  }

  String? get unisonId => _unisonId;

  set unisonId(String? value) {
    _unisonId = value;
  }

  String? get email => _email;

  set email(String? value) {
    _email = value;
  }

  String? get passcode => _passcode;

  set passcode(String? value) {
    _passcode = value;
  }

  DocumentReference? get role => _role;

  set role(DocumentReference? value) {
    _role = value;
  }

  bool? get isAllowedAccess => _isAllowedAccess;

  set isAllowedAccess(bool? value) {
    _isAllowedAccess = value;
  }

  Timestamp? get createdAt => _createdAt;

  set createdAt(Timestamp? value) {
    _createdAt = value;
  }

  Timestamp? get dateOfBirth => _dateOfBirth;

  set dateOfBirth(Timestamp? value) {
    _dateOfBirth = value;
  }

  CSIUser({
    String? key,
    int? csiId,
    String? name,
    String? unisonId,
    String? email,
    String? passcode,
    DocumentReference<Object?>? role,
    bool? isAllowedAccess,
    Timestamp? createdAt,
    Timestamp? dateOfBirth,
  })  : _key = key,
        _csiId = csiId,
        _name = name,
        _unisonId = unisonId,
        _email = email,
        _passcode = passcode,
        _role = role,
        _isAllowedAccess = isAllowedAccess,
        _createdAt = createdAt,
        _dateOfBirth = dateOfBirth;

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

  CSIUser.fromDirectSnapshot(DataSnapshot snapshot, String this._key) {
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

    return FlutterBcrypt.verify(password: passcode, hash: this.passcode!);
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

    json[key!] = data;

    return json;
  }
}
