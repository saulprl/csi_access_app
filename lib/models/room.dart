import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String key;
  final String name;
  final String building;
  final String room;

  Room({
    required this.key,
    required this.name,
    required this.building,
    required this.room,
  });

  Room.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : key = snapshot.id,
        name = snapshot.data()?["name"],
        building = snapshot.data()?["building"],
        room = snapshot.data()?["room"];

  Room.fromQueryDocSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : key = snapshot.id,
        name = snapshot.data()["name"],
        building = snapshot.data()["building"],
        room = snapshot.data()["room"];
}
