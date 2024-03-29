import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/auth_provider.dart';
import 'package:csi_door_logs/providers/role_provider.dart';
import 'package:csi_door_logs/providers/room_provider.dart';

import 'package:csi_door_logs/widgets/admin/skeleton_list.dart';
import 'package:csi_door_logs/widgets/admin/user_item.dart';

import 'package:csi_door_logs/models/user_model.dart';

import 'package:csi_door_logs/utils/utils.dart';

class MembersList extends StatefulWidget {
  final String roleId;
  final String roleName;

  const MembersList({
    required this.roleId,
    required this.roleName,
    super.key,
  });

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context).userData;
    final roles = Provider.of<RoleProvider>(context);
    final rooms = Provider.of<RoomProvider>(context);

    return Column(
      children: [
        buildDivider(context, roleName),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: StreamBuilder(
            stream: _firestore
                .collectionGroup("room_roles")
                .where("key", isEqualTo: rooms.selectedRoom)
                .where("roleId", isEqualTo: roleId)
                .snapshots(),
            builder: (ctx, roleSnap) {
              if (roleSnap.hasData) {
                return ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: roleSnap.data!.size,
                  itemBuilder: (ctx, index) {
                    final currentItem = roleSnap.data!.docs[index];

                    return FutureBuilder(
                      future: currentItem.reference.parent.parent!.get(),
                      builder: (ctx, userIdSnap) {
                        if (userIdSnap.hasData && userIdSnap.data != null) {
                          return StreamBuilder(
                            stream: _firestore
                                .collection("users")
                                .doc(userIdSnap.data?.id)
                                .snapshots(),
                            builder: (ctx, userSnap) {
                              if (!userSnap.hasData) {
                                return const SkeletonList();
                              }

                              final user = UserModel.fromDocSnapshot(
                                userSnap.data!,
                              );

                              final peerRole = roles.roles.firstWhere(
                                (role) => role.name == roleName,
                              );

                              final isEditable =
                                  roles.userRole?.canSetRoles ?? false
                                      ? peerRole.level < roles.userRole!.level
                                      : false;

                              final isTogglable =
                                  roles.userRole?.canGrantOrRevokeAccess ??
                                          false
                                      ? peerRole.level < roles.userRole!.level
                                      : false;

                              return UserItem(
                                key: ValueKey("User item: ${user.key}"),
                                uid: user.key,
                                name: user.name,
                                isAllowedAccess: roleSnap.data!.docs[index]
                                    .data()["accessGranted"],
                                isEditable:
                                    isEditable || (auth?.isRootUser ?? false),
                                isTogglable:
                                    isTogglable || (auth?.isRootUser ?? false),
                                role: peerRole,
                                roomRoleRef: currentItem.reference,
                              );
                            },
                          );
                        }

                        if (userIdSnap.hasError) {
                          return buildItemSkeleton(
                            message: "User not found",
                            error: true,
                          );
                        }

                        return buildItemSkeleton(message: "Loading");
                      },
                    );
                  },
                );
              }

              return buildItemSkeleton(message: "Loading");
            },
          ),
        ),
      ],
    );
  }

  String get roleId => widget.roleId;
  String get roleName => widget.roleName;

  Widget buildItemSkeleton({required String message, bool error = false}) {
    final color = error
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color.withOpacity(0.15),
        ),
        child: ListTile(
          title: Center(child: Text(message, style: baseTextStyle)),
          trailing: AdaptiveSpinner(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
