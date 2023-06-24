import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/csi_users.dart';

import 'package:csi_door_logs/widgets/admin/skeleton_list.dart';
import 'package:csi_door_logs/widgets/admin/user_item.dart';

import 'package:csi_door_logs/models/models.dart';

class RoleUsersList extends StatefulWidget {
  final DocumentReference roleRef;
  final String roleName;

  const RoleUsersList({
    required this.roleRef,
    required this.roleName,
    super.key,
  });

  @override
  State<RoleUsersList> createState() => _RoleUsersListState();
}

class _RoleUsersListState extends State<RoleUsersList> {
  final _firestore = FirebaseFirestore.instance;

  Widget get divider => Row(
        children: [
          Text(
            widget.roleName,
            style: const TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(width: 8.0),
          const Expanded(child: Divider(thickness: 4.0)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<CSIUsers>(context).role;

    return Column(
      children: [
        divider,
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: StreamBuilder(
            stream: _firestore
                .collection("users")
                .where("role", isEqualTo: widget.roleRef)
                .orderBy("isAllowedAccess")
                .orderBy("name")
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.size,
                  itemBuilder: (ctx, index) {
                    final user = CSIUser.fromDocQuerySnapshot(
                      snapshot.data!.docs[index],
                    );

                    final isEditable = role != null
                        ? user.role!.id == role.key
                            ? false
                            : role.canSetRoles
                        : false;
                    final isTogglable = role != null
                        ? user.role!.id == role.key
                            ? false
                            : role.canAllowAndRevokeAccess
                        : false;

                    return UserItem(
                      uid: user.key!,
                      name: user.name!,
                      isAllowedAccess: user.isAllowedAccess!,
                      isEditable: isEditable,
                      isTogglable: isTogglable,
                      role: user.role!,
                    );
                  },
                );
              }

              return const SkeletonList();
            },
          ),
        ),
      ],
    );
  }
}