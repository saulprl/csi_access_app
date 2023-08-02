import 'package:csi_door_logs/models/request.dart';
import 'package:csi_door_logs/providers/auth_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/room_provider.dart';

import 'package:csi_door_logs/models/room.dart';

import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/utils/utils.dart';

class RoomsList extends StatelessWidget {
  const RoomsList({super.key});

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

    return SingleChildScrollView(
      child: Column(
        children: [
          buildDivider(context, "Your Rooms"),
          ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: rooms.userRooms.length,
            itemBuilder: (ctx, index) {
              final room = rooms.userRooms[index];

              return RoomItem(key: ValueKey(room.key), room: room);
            },
          ),
          buildDivider(context, "Available Rooms"),
          if (availableRooms.isEmpty)
            const Center(
              child: Text(
                "No rooms available",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: availableRooms.length,
            itemBuilder: (ctx, index) {
              final room = availableRooms[index];

              return RoomItem(key: ValueKey(room.key), room: room);
            },
          ),
        ],
      ),
    );
  }
}

class RoomItem extends StatefulWidget {
  final Room room;

  const RoomItem({required this.room, super.key});

  @override
  State<RoomItem> createState() => _RoomItemState();
}

class _RoomItemState extends State<RoomItem> {
  final messageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final rooms = Provider.of<RoomProvider>(context);

    return Padding(
      key: ValueKey(room.key),
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: room.key == rooms.selectedRoom
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.15)
              : null,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
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
          trailing: room.key == rooms.selectedRoom
              ? Icon(checkIcon)
              : !rooms.userRooms.contains(room)
                  ? FilledButton(
                      onPressed: _showRequestDialog,
                      child: const Text("Request"),
                    )
                  : null,
          onTap: rooms.userRooms.contains(room)
              ? () {
                  rooms.selectRoom(room.key);
                }
              : null,
        ),
      ),
    );
  }

  Room get room => widget.room;

  Future<void> _showRequestDialog() async {
    final userId =
        Provider.of<AuthProvider>(context, listen: false).userData?.key;

    if (userId == null) {
      _showErrorDialog("Something went wrong while retrieving user data.");

      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Access request",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  text: "You're submitting a request to access ",
                  style: baseTextStyle.copyWith(
                    fontFamily: "Poppins",
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "${room.name} (${room.building}-${room.room})",
                      style: baseTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const TextSpan(
                      text: ". You can provide a request message below.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: messageCtrl,
                decoration: const InputDecoration(
                  labelText: "Message (optional)",
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 120,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Send request",
                style: baseTextStyle.copyWith(
                  fontSize: 16.0,
                  color: successColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: baseTextStyle.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      messageCtrl.clear();

      return;
    }

    try {
      await Request.createRequest(
        userId: userId,
        roomId: room.key,
        message: messageCtrl.text.isNotEmpty ? messageCtrl.text : null,
      );

      _showSnackBar("Request created successfully.");
    } catch (error) {
      _showErrorDialog(error.toString());
      rethrow;
    } finally {
      messageCtrl.clear();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: baseTextStyle),
    ));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Error",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          content: Text(
            "Something went wrong while handling the request. Details: $message",
            style: baseTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: baseTextStyle),
            ),
          ],
        );
      },
    );
  }
}
