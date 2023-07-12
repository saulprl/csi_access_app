import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csi_door_logs/widgets/auth/role_field.dart';

import 'package:csi_door_logs/models/role_model.dart';

import 'package:csi_door_logs/utils/styles.dart';

class UserItem extends StatefulWidget {
  final String uid;
  final String name;
  final bool isAllowedAccess;
  final bool isEditable;
  final bool isTogglable;
  final RoleModel role;
  final DocumentReference roomRoleRef;

  const UserItem({
    required this.uid,
    required this.name,
    required this.isAllowedAccess,
    required this.isEditable,
    required this.isTogglable,
    required this.role,
    required this.roomRoleRef,
    super.key,
  });

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  final _firestore = FirebaseFirestore.instance;
  late String roleKey;

  MaterialStateProperty<Icon?> get thumbIcon =>
      MaterialStateProperty.resolveWith<Icon?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return Icon(checkIcon, color: Theme.of(context).colorScheme.primary);
        } else {
          return Icon(cancelIcon);
        }
      });

  void toggleAccessPermission(bool value) {
    roomRoleRef.set({
      "accessGranted": value,
    }, SetOptions(merge: true));
  }

  void popBack(bool updated) {
    Navigator.of(context).pop(updated);
  }

  void onRoleChange(String? value) {
    if (value == null) return;

    roleKey = value;
  }

  Future<bool?> showUpdateDialog() async {
    roleKey = role.key;

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
              RoleField(value: roleKey, onChange: onRoleChange),
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
    final result = await showUpdateDialog();
    if (result == null) return;
    if (!result) return;

    final updatedRole = (await _firestore.doc("roles/$roleKey").get());

    await roomRoleRef.set({
      "roleId": updatedRole.reference,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          editIcon,
          color: isEditable
              ? Theme.of(context).colorScheme.primary
              : Colors.black38,
        ),
        onPressed: isEditable ? updateRole : null,
      ),
      title: Text(
        widget.name,
        style: const TextStyle(
          fontSize: 18.0,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Switch(
        value: isAllowedAccess,
        thumbIcon: thumbIcon,
        onChanged: isTogglable ? toggleAccessPermission : null,
      ),
    );
  }

  String get uid => widget.uid;
  String get name => widget.name;
  bool get isAllowedAccess => widget.isAllowedAccess;
  bool get isEditable => widget.isEditable;
  bool get isTogglable => widget.isTogglable;
  RoleModel get role => widget.role;
  DocumentReference get roomRoleRef => widget.roomRoleRef;
}
