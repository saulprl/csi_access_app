import 'package:csi_door_logs/models/room.dart';
import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:provider/provider.dart';

import 'package:csi_door_logs/models/request.dart';
import 'package:csi_door_logs/providers/requests_provider.dart';

import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/utils/utils.dart';

class RequestsList extends StatelessWidget {
  const RequestsList({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = Provider.of<RequestsProvider>(context);

    final pendingRequests = requests.userRequests
        .where(
          (request) => request.status == RequestStatus.pending,
        )
        .toList();

    final resolvedRequests = requests.userRequests
        .where(
          (request) => request.status != RequestStatus.pending,
        )
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          buildDivider(context, "Pending requests"),
          if (pendingRequests.isEmpty)
            const Center(
              child: Text(
                "No pending requests",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: pendingRequests.length,
            itemBuilder: (ctx, index) {
              final request = pendingRequests[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: RequestItem(request: request),
              );
            },
          ),
          buildDivider(context, "Resolved requests"),
          if (resolvedRequests.isEmpty)
            const Center(
              child: Text(
                "No resolved requests",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: resolvedRequests.length,
            itemBuilder: (ctx, index) {
              final request = resolvedRequests[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: RequestItem(request: request),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RequestItem extends StatefulWidget {
  final Request request;

  const RequestItem({required this.request, super.key});

  @override
  State<RequestItem> createState() => _RequestItemState();
}

class _RequestItemState extends State<RequestItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _generateStatusColor(),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: FutureBuilder(
        future: request.roomId.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AdaptiveSpinner());
          }

          if (snapshot.hasData) {
            final room = Room.fromDocSnapshot(snapshot.data!);

            return ListTile(
              title: Text(
                "${room.name} (${room.building}-${room.room})",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${request.status.name} - ${timeago.format(request.updatedAt.toDate())}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () => _showRequestDetails(room: room, request: request),
            );
          }

          return const Center(
            child: Text(
              "Error loading request data",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Request get request => widget.request;

  Color _generateStatusColor() {
    switch (request.status) {
      case RequestStatus.pending:
        return Theme.of(context).colorScheme.error;
      case RequestStatus.approved:
        return successColor;
      case RequestStatus.rejected:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  void _showRequestDetails({required Room room, required Request request}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Request details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Room: ${room.name} (${room.building}-${room.room})",
                style: const TextStyle(fontSize: 16.0),
              ),
              RichText(
                text: TextSpan(
                  text: "Status: ",
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: "Poppins",
                  ),
                  children: [
                    TextSpan(
                      text: request.status.name,
                      style: TextStyle(
                        color: _generateStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Created at: ${DateFormat("MMMM dd yyyy HH:mm").format(request.createdAt.toDate())} (${timeago.format(request.createdAt.toDate())})",
                style: const TextStyle(fontSize: 16.0),
              ),
              Text(
                "Updated at: ${DateFormat("MMMM dd yyyy HH:mm").format(request.updatedAt.toDate())} (${timeago.format(request.updatedAt.toDate())})",
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(fontSize: 16.0)),
            ),
          ],
        );
      },
    );
  }
}
