import 'package:csi_door_logs/utils/globals.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/room_provider.dart';

import 'package:csi_door_logs/widgets/main/csi_appbar.dart';

import 'package:csi_door_logs/models/room.dart';

import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/utils/utils.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  Widget _buildRoomItem(BuildContext ctx, Room room) {
    final rooms = Provider.of<RoomProvider>(ctx);

    final isUserRoom = rooms.userRooms.contains(room);

    final trailing = room.key == rooms.selectedRoom
        ? Icon(
            checkIcon,
            color: Theme.of(ctx).colorScheme.primary,
          )
        : !rooms.userRooms.contains(room)
            ? FilledButton(
                onPressed: () {
                  try {
                    rooms.requestAccess(room.key);

                    showAlertDialog(
                      context: ctx,
                      title: "Request sent",
                      message: requestAccessDisclaimer,
                    );
                  } catch (error) {
                    showAlertDialog(
                      context: ctx,
                      title: "Error",
                      message: error.toString(),
                    );
                  }
                },
                child: const Text("Request"),
              )
            : null;

    final onTap = isUserRoom ? () => rooms.selectRoom(room.key) : null;

    return Padding(
      key: ValueKey(room.key),
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: room.key == rooms.selectedRoom
              ? Theme.of(ctx).colorScheme.secondary.withOpacity(0.15)
              : null,
          border: Border.all(
            color: Theme.of(ctx).colorScheme.secondary,
          ),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          title: Text(
            "${room.name} (${room.building}-${room.room})",
            overflow: TextOverflow.ellipsis,
          ),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = Provider.of<RoomProvider>(context);

    final availableRooms = rooms.rooms.where(
      (room) {
        return rooms.userRooms
            .where((userRoom) => userRoom.key == room.key)
            .isEmpty;
      },
    ).toList();

    return Scaffold(
      appBar: const CSIAppBar("Rooms"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildDivider(context, "Your Rooms"),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: rooms.userRooms.length,
                  itemBuilder: (ctx, index) {
                    final room = rooms.userRooms[index];

                    return _buildRoomItem(ctx, room);
                  },
                ),
                buildDivider(context, "Available Rooms"),
                if (availableRooms.isEmpty)
                  const Center(
                    child: Text(
                      "No rooms available",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: availableRooms.length,
                  itemBuilder: (ctx, index) {
                    final room = availableRooms[index];

                    return _buildRoomItem(ctx, room);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
