import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/room_provider.dart';

class RoomField extends StatefulWidget {
  final String? value;
  final void Function(String?) onChange;

  const RoomField({
    required this.value,
    required this.onChange,
    super.key,
  });

  @override
  State<RoomField> createState() => _RoomFieldState();
}

class _RoomFieldState extends State<RoomField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = Provider.of<RoomProvider>(context).rooms;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Room",
        prefixIcon: Icon(Icons.room),
      ),
      value: value,
      items: rooms
          .map((room) => DropdownMenuItem<String>(
                value: room.key,
                child: Text("${room.name} (${room.building}-${room.room})"),
              ))
          .toList(),
      onChanged: onChange,
      isExpanded: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select a room.";
        }

        return null;
      },
    );
  }

  String? get value => widget.value;
  void Function(String?) get onChange => widget.onChange;
}
