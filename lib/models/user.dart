import 'package:firebase_database/firebase_database.dart';

class User {
  String? key;
  int? csiId;
  String? name;
  String? unisonId;

  User({this.key, this.csiId, this.name, this.unisonId});

  User.fromSnapshot(DataSnapshot snapshot) {
    final actualKey = (snapshot.value as Map).keys.first;

    key = actualKey;
    csiId = (snapshot.value as Map)[actualKey]["csiId"];
    name = (snapshot.value as Map)[actualKey]["name"];
    unisonId = (snapshot.value as Map)[actualKey]["unisonId"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};

    json[key!] = {
      "csiId": csiId,
      "name": name,
      "unisonId": unisonId,
    };

    return json;
  }
}
