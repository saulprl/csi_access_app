import 'package:csi_door_logs/widgets/management/user_requests.dart';
import 'package:flutter/material.dart';

import 'package:csi_door_logs/widgets/main/csi_appbar.dart';
import 'package:csi_door_logs/widgets/management/rooms_list.dart';

import 'package:csi_door_logs/utils/styles.dart';

class RoomsScreen extends StatefulWidget {
  final int page;

  const RoomsScreen({this.page = 0, super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.page;
  }

  static const List<Map<String, dynamic>> _pages = [
    {"title": "Rooms", "page": RoomsList()},
    {"title": "Requests", "page": UserRequests()},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CSIAppBar(_pages[_currentIndex]["title"]),
      body: SafeArea(child: _pages[_currentIndex]["page"]),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(roomIcon),
            label: "Rooms",
          ),
          BottomNavigationBarItem(
            icon: Icon(requestIcon),
            label: "Requests",
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
