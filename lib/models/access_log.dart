import "package:firebase_database/firebase_database.dart";

import "package:csi_door_logs/models/attempt.dart";

class AccessLog {
  String? key;
  int? csiId;
  bool? accessed;
  int? timestamp;
  Attempt? attemptData;

  AccessLog({this.csiId, this.accessed, this.timestamp, this.attemptData});

  AccessLog.fromSnapshot(DataSnapshot snapshot) {
    key = snapshot.key;
    csiId = (snapshot.value as Map)["csiId"];
    accessed = (snapshot.value as Map)["accessed"];
    timestamp = (snapshot.value as Map)["timestamp"];
    attemptData = (snapshot.value as Map)["attemptData"] != null
        ? Attempt(
            csiId: ((snapshot.value as Map)["attemptData"] as Map)["csiId"],
            passcode:
                ((snapshot.value as Map)["attemptData"] as Map)["passcode"],
          )
        : null;
  }

  AccessLog.fromValue(dynamic key, dynamic value) {
    this.key = key.toString();
    csiId = value["csiId"];
    accessed = value["accessed"];
    timestamp = value["timestamp"];
    attemptData = value["attemptData"] != null
        ? Attempt(
            csiId: value["attemptData"]["csiId"],
            passcode: value["attemptData"]["passcode"])
        : null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    Map<String, dynamic> data = <String, dynamic>{};

    data["csiId"] = csiId;
    data["accessed"] = accessed;
    data["timestamp"] = timestamp;
    data["attemptData"] = attemptData != null ? attemptData!.toJson() : null;

    json[key!] = data;

    return json;
  }
}
