import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:skeleton_animation/skeleton_animation.dart';

import 'package:csi_door_logs/providers/role_provider.dart';

import 'package:csi_door_logs/widgets/admin/role_users_list.dart';
import 'package:csi_door_logs/widgets/admin/skeleton_list.dart';

import 'package:csi_door_logs/models/role_model.dart';

class MembersList extends StatelessWidget {
  MembersList({super.key});

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final roles = Provider.of<RoleProvider>(context);

    return ListView.builder(
      padding: const EdgeInsets.all(8.0) +
          const EdgeInsets.only(
            bottom: 80.0,
          ),
      itemCount: roles.roles.length,
      itemBuilder: (ctx, index) => roleList(roles.roles[index].key),
    );
  }

  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>> roleList(
    String roleId,
  ) {
    return FutureBuilder(
      future: _firestore.collection("roles").doc(roleId).get(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          final roleSnap = snapshot.data!;
          final role = RoleModel.fromDocSnapshot(roleSnap);

          return RoleUsersList(roleId: roleSnap.id, roleName: role.name);
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading roles"),
          );
        }

        return skeleton;
      },
    );
  }

  Column get skeleton => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonText(
                height: 28.0,
              ),
            ],
          ),
          SizedBox(height: 4.0),
          SkeletonList(count: 1),
        ],
      );
}