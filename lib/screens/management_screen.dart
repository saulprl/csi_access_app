import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:skeleton_animation/skeleton_animation.dart';

import 'package:csi_door_logs/providers/auth_provider.dart';
import 'package:csi_door_logs/providers/role_provider.dart';

import 'package:csi_door_logs/screens/create_user_screen.dart';

import 'package:csi_door_logs/widgets/admin/role_users_list.dart';
import 'package:csi_door_logs/widgets/admin/skeleton_list.dart';
import 'package:csi_door_logs/widgets/main/index.dart';

import 'package:csi_door_logs/models/role_model.dart';

import 'package:csi_door_logs/utils/routes.dart';
import 'package:csi_door_logs/utils/styles.dart';

class ManagementScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  ManagementScreen({super.key});

  void pushCreateUser(BuildContext ctx) => Navigator.of(ctx).push(
        Routes.pushFromRight(const CreateUserScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final roles = Provider.of<RoleProvider>(context);

    return Scaffold(
      appBar: const CSIAppBar("User Control", roomSelector: true),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0) +
              const EdgeInsets.only(
                bottom: 80.0,
              ),
          itemCount: roles.roles.length,
          itemBuilder: (ctx, index) => roleList(roles.roles[index].key),
        ),
      ),
      floatingActionButton: (roles.userRole?.canCreateUsers ?? false) ||
              (auth.userData?.isRootUser ?? false)
          ? FloatingActionButton(
              onPressed: () => pushCreateUser(context),
              child: Icon(
                createUserIcon,
                color: Colors.white,
              ),
            )
          : null,
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

          return RoleUsersList(
            roleRef: roleSnap.reference,
            roleName: role.name,
          );
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
