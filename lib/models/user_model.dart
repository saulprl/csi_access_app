import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String key;
  final int csiId;
  final String unisonId;
  final String name;
  final String passcode;
  final String email;
  final DateTime dateOfBirth;
  final DateTime createdAt;

  UserModel({
    required this.key,
    required this.csiId,
    required this.unisonId,
    required this.name,
    required this.passcode,
    required this.email,
    required this.dateOfBirth,
    required this.createdAt,
  });

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
}
