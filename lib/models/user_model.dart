import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String key;
  final int csiId;
  final String unisonId;
  final String name;
  final String passcode;
  final DateTime dateOfBirth;
  String? email;
  DateTime? createdAt;
  bool? isRoot;

  UserModel({
    required this.key,
    required this.csiId,
    required this.unisonId,
    required this.name,
    required this.passcode,
    required this.dateOfBirth,
    this.email,
    this.createdAt,
    this.isRoot,
  });

  set setIsRoot(bool? value) => isRoot = value;

  bool get isRootUser => isRoot ?? false;

  UserModel.fromDocSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : key = snapshot.id,
        csiId = snapshot.data()?['csiId'],
        unisonId = snapshot.data()?['unisonId'],
        name = snapshot.data()?['name'],
        passcode = snapshot.data()?['passcode'],
        email = snapshot.data()?['email'],
        dateOfBirth = (snapshot.data()?['dateOfBirth'] as Timestamp).toDate(),
        createdAt = (snapshot.data()?['createdAt'] as Timestamp).toDate();

  UserModel.fromQueryDocSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : key = snapshot.id,
        csiId = snapshot.data()['csiId'],
        unisonId = snapshot.data()['unisonId'],
        name = snapshot.data()['name'],
        passcode = snapshot.data()['passcode'],
        email = snapshot.data()['email'],
        dateOfBirth = (snapshot.data()['dateOfBirth'] as Timestamp).toDate(),
        createdAt = (snapshot.data()['createdAt'] as Timestamp).toDate();

  Map<String, dynamic> toJson() => {
        'csiId': csiId,
        'unisonId': unisonId,
        'name': name,
        'passcode': passcode,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'createdAt': createdAt,
      };
}
