import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  late String key;
  late String name;
  late String building;
  late String room;

  Room({
    required this.key,
    required this.name,
    required this.building,
    required this.room,
  });

  Room.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return;

    key = snapshot.id;
    name = data["name"];
    building = data["building"];
    room = data["room"];
  }

  Room.fromQueryDocSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    key = snapshot.id;
    name = data["name"];
    building = data["building"];
    room = data["room"];
  }
}
