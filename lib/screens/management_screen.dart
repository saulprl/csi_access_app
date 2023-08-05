import 'package:flutter/material.dart';

import 'package:csi_door_logs/screens/create_user_screen.dart';

import 'package:csi_door_logs/widgets/admin/roles_list.dart';
import 'package:csi_door_logs/widgets/admin/requests_list.dart';
import 'package:csi_door_logs/widgets/main/index.dart';

import 'package:csi_door_logs/utils/routes.dart';
import 'package:csi_door_logs/utils/styles.dart';

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
    {"title": "User Control", "page": RolesList()},
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
      body: SafeArea(child: _pages[_currentIndex]["page"]),
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
