import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/role_provider.dart';

import 'package:csi_door_logs/widgets/admin/members_list.dart';

import 'package:csi_door_logs/models/role_model.dart';

import 'package:csi_door_logs/utils/styles.dart';

class RolesList extends StatelessWidget {
  const RolesList({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = Provider.of<RoleProvider>(context);

    if (roles.roles.isEmpty) {
      return const Center(
        child: Text(
          "No roles found. This is probably an error.",
          style: baseTextStyle,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0) + const EdgeInsets.only(bottom: 80.0),
      itemCount: roles.roles.length,
      itemBuilder: (ctx, index) => roleList(roles.roles[index]),
    );
  }

  Widget roleList(RoleModel role) {
    return MembersList(
      key: ValueKey("Role ${role.key}"),
      roleId: role.key,
      roleName: role.name,
    );
  }
}
