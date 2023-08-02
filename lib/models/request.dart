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
  final String userId;
  final String roomId;
  final String? adminId;
  final String? userComment;
  final String? adminComment;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Request({
    required this.key,
    required this.userId,
    required this.roomId,
    this.adminId,
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
        adminId = snapshot.data()?["adminId"],
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
        adminId = snapshot.data()["adminId"],
        userComment = snapshot.data()["userComment"],
        adminComment = snapshot.data()["adminComment"],
        createdAt = snapshot.data()["createdAt"],
        updatedAt = snapshot.data()["updatedAt"],
        status = RequestStatus.values[snapshot.data()["status"] ?? 0];

  static Future<void> createRequest({
    required String userId,
    required String roomId,
    String? message,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final creationDate = Timestamp.now();

    await firestore.collection("requests").add({
      "status": RequestStatus.pending.index,
      "userId": userId,
      "roomId": roomId,
      "userComment": message,
      "createdAt": creationDate,
      "updatedAt": creationDate,
    });
  }

  Future<void> _updateStatus(
    String adminId,
    RequestStatus status,
    String? message,
  ) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection("requests").doc(key).update({
      "status": status.index,
      "adminId": adminId,
      "adminComment": message,
      "updatedAt": Timestamp.now(),
    });
  }

  Future<void> approve({required String adminId, String? message}) async {
    await _updateStatus(adminId, RequestStatus.approved, message);

    final firestore = FirebaseFirestore.instance;

    final guestRole = await firestore
        .collection("roles")
        .where("name", isEqualTo: "Guest")
        .limit(1)
        .get();

    if (guestRole.docs.isEmpty) {
      throw "Something went wrong while submitting the adding the user to the room's guest list.";
    }

    final guestRoleRef = guestRole.docs.first.reference;

    await firestore
        .collection("user_roles")
        .doc(userId)
        .collection("room_roles")
        .doc(roomId)
        .set({
      "roleId": guestRoleRef,
      "accessGranted": true,
      "key": roomId,
    });
  }

  Future<void> reject({required String adminId, String? message}) async {
    await _updateStatus(adminId, RequestStatus.rejected, message);
  }
}
