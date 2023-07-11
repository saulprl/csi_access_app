import 'package:cloud_firestore/cloud_firestore.dart';

class RoleModel {
  final String key;
  final String name;
  final int level;
  final bool canSetRoles;
  final bool canGrantOrRevokeAccess;
  final bool canReadLogs;
  final bool canCreateUsers;

  RoleModel({
    required this.key,
    required this.name,
    required this.level,
    required this.canSetRoles,
    required this.canGrantOrRevokeAccess,
    required this.canReadLogs,
    required this.canCreateUsers,
  });

  factory RoleModel.fromDocSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() as Map<String, dynamic>;
    return RoleModel(
      key: snapshot.id,
      name: data['name'],
      level: data['level'],
      canSetRoles: data['canSetRoles'],
      canGrantOrRevokeAccess: data['canGrantOrRevokeAccess'],
      canReadLogs: data['canReadLogs'],
      canCreateUsers: data['canCreateUsers'],
    );
  }

  factory RoleModel.fromQueryDocSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return RoleModel(
      key: snapshot.id,
      name: data['name'],
      level: data['level'],
      canSetRoles: data['canSetRoles'],
      canGrantOrRevokeAccess: data['canGrantOrRevokeAccess'],
      canReadLogs: data['canReadLogs'],
      canCreateUsers: data['canCreateUsers'],
    );
  }
}
