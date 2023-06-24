import 'package:csi_door_logs/utils/styles.dart';
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
            style: screenSubtitle,
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

                    return FutureBuilder(
                      future: user.role.get(),
                      builder: (ctx, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final userRole = Role.fromDocSnapshot(snapshot.data!);

                          final isEditable = role == null
                              ? false
                              : role.canSetRoles
                                  ? userRole.level < role.level
                                  : false;

                          final isTogglable = role == null
                              ? false
                              : role.canAllowAndRevokeAccess
                                  ? userRole.level < role.level
                                  : false;

                          return UserItem(
                            key: ValueKey(user.key),
                            uid: user.key,
                            name: user.name,
                            isAllowedAccess: user.isAllowedAccess,
                            isEditable: isEditable,
                            isTogglable: isTogglable,
                            role: user.role,
                          );
                        }

                        return const SkeletonList();
                      },
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
