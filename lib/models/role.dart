import 'package:cloud_firestore/cloud_firestore.dart';

class Role {
  late String key;
  late String name;
  late int level;
  late bool canAccess;
  late bool canAllowAndRevokeAccess;
  late bool canReadLogs;
  late bool canSetRoles;
  late bool canCreateUsers;

  Role({
    required this.key,
    required this.name,
    this.level = 0,
    this.canAccess = false,
    this.canAllowAndRevokeAccess = false,
    this.canReadLogs = false,
    this.canSetRoles = false,
    this.canCreateUsers = false,
  });

  Role.fromDocQuerySnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    key = snapshot.id;
    name = data["name"];
    level = data["level"];
    canAccess = data["canAccess"];
    canAllowAndRevokeAccess = data["canAllowAndRevokeAccess"];
    canReadLogs = data["canReadLogs"];
    canSetRoles = data["canSetRoles"];
    canCreateUsers = data["canCreateUsers"];
  }

  Role.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return;

    key = snapshot.id;
    name = data["name"];
    level = data["level"];
    canAccess = data["canAccess"];
    canAllowAndRevokeAccess = data["canAllowAndRevokeAccess"];
    canReadLogs = data["canReadLogs"];
    canSetRoles = data["canSetRoles"];
    canCreateUsers = data["canCreateUsers"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{
      "name": name,
      "level": level,
      "canAccess": canAccess,
      "canAllowAndRevokeAccess": canAllowAndRevokeAccess,
      "canReadLogs": canReadLogs,
      "canSetRoles": canSetRoles,
      "canCreateUsers": canCreateUsers,
    };

    return json;
  }
}
