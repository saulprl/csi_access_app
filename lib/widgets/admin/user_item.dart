import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csi_door_logs/models/models.dart';
import 'package:csi_door_logs/utils/globals.dart';
import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/widgets/auth/role_field.dart';
import 'package:flutter/material.dart';

class UserItem extends StatefulWidget {
  final String uid;
  final String name;
  final bool isAllowedAccess;
  final bool isEditable;
  final bool isTogglable;
  final DocumentReference<Map<String, dynamic>> role;

  const UserItem({
    required this.uid,
    required this.name,
    required this.isAllowedAccess,
    required this.isEditable,
    required this.isTogglable,
    required this.role,
    super.key,
  });

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  final _firestore = FirebaseFirestore.instance;
  late String roleName;

  void toggleAccessPermission(bool value) {
    _firestore.collection("users").doc(widget.uid).set({
      "isAllowedAccess": value,
    }, SetOptions(merge: true));
  }

  void popBack(bool updated) {
    Navigator.of(context).pop(updated);
  }

  void onRoleChange(String? value) {
    if (value == null) return;

    roleName = value;
  }

  Future<bool?> showUpdateDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Update role"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: "Choose ",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                  ),
                  children: [
                    TextSpan(
                      text: widget.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: "'s new role:"),
                  ],
                ),
              ),
              RoleField(
                value: roleName,
                values: roles,
                onChange: onRoleChange,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => popBack(false),
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => popBack(true),
              child: Text(
                "Submit",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateRole() async {
    roleName = Role.fromDocSnapshot(await widget.role.get()).name;

    final result = await showUpdateDialog();
    if (result == null) return;
    if (!result) return;

    final updatedRole = (await _firestore
            .collection("roles")
            .where("name", isEqualTo: roleName)
            .limit(1)
            .get())
        .docs[0];

    await _firestore.doc("users/${widget.uid}").set({
      "role": updatedRole.reference,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          editIcon,
          color: widget.isEditable
              ? Theme.of(context).colorScheme.primary
              : Colors.black38,
        ),
        onPressed: widget.isEditable ? updateRole : null,
      ),
      title: Text(
        widget.name,
        style: const TextStyle(
          fontSize: 18.0,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Switch(
        value: widget.isAllowedAccess,
        onChanged: widget.isTogglable ? toggleAccessPermission : null,
      ),
    );
  }
}
