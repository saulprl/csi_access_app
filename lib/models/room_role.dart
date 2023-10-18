import 'package:cloud_firestore/cloud_firestore.dart';

class RoomRole {
  final String key;
  final bool accessGranted;
  final String roleId;

  RoomRole({
    required this.key,
    required this.accessGranted,
    required this.roleId,
  });

  RoomRole.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : key = snapshot.id,
        accessGranted = snapshot.data()?["accessGranted"],
        roleId = snapshot.data()?["roleId"];

  RoomRole.fromQueryDocSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : key = snapshot.id,
        accessGranted = snapshot.data()["accessGranted"],
        roleId = snapshot.data()["roleId"];
}
