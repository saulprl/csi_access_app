import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  pending(name: "Pending"),
  approved(name: "Approved"),
  rejected(name: "Rejected");

  const RequestStatus({required this.name});

  final String name;
}

class Request {
  final String key;
  final RequestStatus status;
  final DocumentReference<Map<String, dynamic>> userId;
  final DocumentReference<Map<String, dynamic>> roomId;
  final String? userComment;
  final String? adminComment;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Request({
    required this.key,
    required this.userId,
    required this.roomId,
    this.userComment,
    this.adminComment,
    required this.createdAt,
    required this.updatedAt,
    this.status = RequestStatus.pending,
  });

  Request.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : key = snapshot.id,
        userId = snapshot.data()?["userId"],
        roomId = snapshot.data()?["roomId"],
        userComment = snapshot.data()?["userComment"],
        adminComment = snapshot.data()?["adminComment"],
        createdAt = snapshot.data()?["createdAt"],
        updatedAt = snapshot.data()?["updatedAt"],
        status = RequestStatus.values[snapshot.data()?["status"] ?? 0];

  Request.fromQueryDocSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : key = snapshot.id,
        userId = snapshot.data()["userId"],
        roomId = snapshot.data()["roomId"],
        userComment = snapshot.data()["userComment"],
        adminComment = snapshot.data()["adminComment"],
        createdAt = snapshot.data()["createdAt"],
        updatedAt = snapshot.data()["updatedAt"],
        status = RequestStatus.values[snapshot.data()["status"] ?? 0];
}
