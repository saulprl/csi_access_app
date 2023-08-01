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

    return AppBar(
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          if (roomSelector && rooms.userRooms.isNotEmpty)
            PopupMenuButton(
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
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
