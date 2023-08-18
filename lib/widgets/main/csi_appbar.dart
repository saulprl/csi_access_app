import "package:csi_door_logs/providers/auth_provider.dart";
import "package:csi_door_logs/providers/role_provider.dart";
import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:csi_door_logs/providers/room_provider.dart";

class CSIAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;
  final bool roomSelector;

  const CSIAppBar(
    this.title, {
    this.roomSelector = false,
    Key? key,
  })  : preferredSize = const Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final rooms = Provider.of<RoomProvider>(context);
    final isRoot =
        Provider.of<AuthProvider>(context).userData?.isRootUser ?? false;
    final hasAccess = Provider.of<RoleProvider>(context).hasAccess;

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      bottom: !isRoot
          ? !hasAccess
              ? PreferredSize(
                  preferredSize: const Size(double.infinity, 16.0),
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.error,
                    child: const Text(
                      "You currently have no access to this room",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : null
          : null,
      actions: [
        if (roomSelector && rooms.userRooms.isNotEmpty)
          PopupMenuButton(
            tooltip: "Show rooms",
            itemBuilder: (ctx) => rooms.userRooms
                .map(
                  (room) => PopupMenuItem(
                    value: room.key,
                    child: Text(room.name),
                  ),
                )
                .toList(),
            onSelected: (value) => rooms.selectRoom(value),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    rooms.userRooms
                        .firstWhere((room) => room.key == rooms.selectedRoom)
                        .name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ],
              ),
            ),
          ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
