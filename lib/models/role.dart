import 'package:cloud_firestore/cloud_firestore.dart';

class Role {
  late String key;
  late String name;
  late bool canAccess;
  late bool canAllowAndRevokeAccess;
  late bool canReadLogs;
  late bool canSetRoles;

  Role({
    required this.key,
    required this.name,
    this.canAccess = false,
    this.canAllowAndRevokeAccess = false,
    this.canReadLogs = false,
    this.canSetRoles = false,
  });

  Role.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return;

    key = snapshot.id;
    name = data["name"];
    canAccess = data["canAccess"];
    canAllowAndRevokeAccess = data["canAllowAndRevokeAccess"];
    canReadLogs = data["canReadLogs"];
    canSetRoles = data["canSetRoles"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{
      "name": name,
      "canAccess": canAccess,
      "canAllowAndRevokeAccess": canAllowAndRevokeAccess,
      "canReadLogs": canReadLogs,
      "canSetRoles": canSetRoles,
    };

    return json;
  }
}
