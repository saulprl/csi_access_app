import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/widgets/admin/members_list.dart';
import 'package:csi_door_logs/widgets/admin/requests_list.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:skeleton_animation/skeleton_animation.dart';

import 'package:csi_door_logs/providers/role_provider.dart';

import 'package:csi_door_logs/screens/create_user_screen.dart';

import 'package:csi_door_logs/widgets/admin/role_users_list.dart';
import 'package:csi_door_logs/widgets/admin/skeleton_list.dart';
import 'package:csi_door_logs/widgets/main/index.dart';

import 'package:csi_door_logs/models/role_model.dart';

import 'package:csi_door_logs/utils/routes.dart';

class ManagementScreen extends StatefulWidget {
  final int page;

  const ManagementScreen({this.page = 0, super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.page;
  }

  static final List<Map<String, dynamic>> _pages = [
    {"title": "User Control", "page": MembersList()},
    {"title": "Access Requests", "page": const RequestsList()},
  ];

  void pushCreateUser(BuildContext ctx) => Navigator.of(ctx).push(
        Routes.pushFromRight(const CreateUserScreen()),
      );

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CSIAppBar(_pages[_currentIndex]["title"], roomSelector: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _pages[_currentIndex]["page"],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(groupIcon),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(requestIcon),
            label: "Access requests",
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
