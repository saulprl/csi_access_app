import 'package:csi_door_logs/providers/csi_users.dart';
import 'package:csi_door_logs/screens/create_user_screen.dart';
import 'package:csi_door_logs/utils/routes.dart';
import 'package:csi_door_logs/utils/styles.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csi_door_logs/widgets/admin/role_users_list.dart';
import 'package:csi_door_logs/widgets/admin/skeleton_list.dart';
import 'package:csi_door_logs/widgets/main/index.dart';

import 'package:csi_door_logs/models/models.dart';

import 'package:csi_door_logs/utils/globals.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_animation/skeleton_animation.dart';

class ManagementScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  ManagementScreen({super.key});

  void pushCreateUser(BuildContext ctx) => Navigator.of(ctx).push(
        Routes.pushFromRight(const CreateUserScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<CSIUsers>(context).role;

    return Scaffold(
      appBar: const CSIAppBar("User Management"),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0) +
              const EdgeInsets.only(
                bottom: 80.0,
              ),
          itemCount: roles.length,
          itemBuilder: (ctx, index) => roleList(roles[index]),
        ),
      ),
      floatingActionButton: role != null
          ? role.canCreateUsers
              ? FloatingActionButton(
                  onPressed: () => pushCreateUser(context),
                  child: Icon(
                    createUserIcon,
                    color: Colors.white,
                  ),
                )
              : null
          : null,
    );
  }

  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> roleList(
    String roleName,
  ) {
    return FutureBuilder(
      future: _firestore
          .collection("roles")
          .where(
            "name",
            isEqualTo: roleName,
          )
          .get(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          final roleSnap = snapshot.data!.docs[0];
          final role = Role.fromDocSnapshot(roleSnap);

          return RoleUsersList(
            roleRef: roleSnap.reference,
            roleName: role.name,
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
            children: [
              SkeletonText(
                height: 18.0,
              ),
              SizedBox(width: 4.0),
              Expanded(child: Divider(thickness: 4.0)),
            ],
          ),
          SizedBox(height: 4.0),
          SkeletonList(count: 2),
        ],
      );
}
