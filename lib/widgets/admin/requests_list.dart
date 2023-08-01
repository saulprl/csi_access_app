import 'package:csi_door_logs/models/user_model.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:csi_door_logs/providers/auth_provider.dart';
import 'package:csi_door_logs/providers/requests_provider.dart';
import 'package:csi_door_logs/providers/role_provider.dart';

import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';

import 'package:csi_door_logs/models/request.dart';
import 'package:csi_door_logs/models/room.dart';

import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/utils/utils.dart';

class RequestsList extends StatelessWidget {
  const RequestsList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userData;
    final role = Provider.of<RoleProvider>(context).userRole;
    final requests = Provider.of<RequestsProvider>(context);

    final pendingRequests = requests.roomRequests
        .where(
          (request) => request.status == RequestStatus.pending,
        )
        .toList();

    final resolvedRequests = requests.roomRequests
        .where(
          (request) => request.status != RequestStatus.pending,
        )
        .toList();

    return (user?.isRootUser ?? false) || (role?.canHandleRequests ?? false)
        ? SingleChildScrollView(
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
          )
        : const Center(
            child: Text(
              "You don't have permission to handle requests for this room",
              style: TextStyle(fontSize: 18.0),
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
  final reasonCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _generateStatusColor(),
        borderRadius: BorderRadius.circular(10.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(10.0),
        child: FutureBuilder(
          future: request.userId.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AdaptiveSpinner());
            }

            if (snapshot.hasData) {
              final requestingUser = UserModel.fromDocSnapshot(snapshot.data!);

              return ListTile(
                title: Text(
                  requestingUser.name,
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
                onTap: () => _showRequestDetails(user: requestingUser),
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

  Future<void> _showRequestDetails({required UserModel user}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Request details",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name: ${user.name}",
                style: baseTextStyle,
              ),
              Text(
                "UniSon ID: ${user.unisonId}",
                style: baseTextStyle,
              ),
              RichText(
                text: TextSpan(
                  text: "Status: ",
                  style: baseTextStyle.copyWith(
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
                style: baseTextStyle,
              ),
              Text(
                "Updated at: ${DateFormat("MMMM dd yyyy HH:mm").format(request.updatedAt.toDate())} (${timeago.format(request.updatedAt.toDate())})",
                style: baseTextStyle,
              ),
              Text(
                "User message: ${request.userComment ?? "No user message available"}",
                style: baseTextStyle,
              ),
              FutureBuilder(
                future: request.adminId?.get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "Loading admin data...",
                      style: baseTextStyle,
                    );
                  }

                  if (snapshot.hasData) {
                    final admin = UserModel.fromDocSnapshot(snapshot.data!);

                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text(
                          "Admin: ${admin.name} (${admin.unisonId})",
                          style: baseTextStyle,
                        ),
                        Text(
                          "Admin message: ${request.adminComment ?? "No admin message available"}",
                          style: baseTextStyle,
                        ),
                      ],
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      "Error loading admin data.",
                      style: baseTextStyle,
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
          actions: request.status == RequestStatus.pending
              ? [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      "Approve",
                      style: baseTextStyle.copyWith(color: successColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "Reject",
                      style: baseTextStyle.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      "Close",
                      style: baseTextStyle,
                    ),
                  ),
                ],
        );
      },
    );

    if (request.status != RequestStatus.pending || result == null) return;

    if (result) {
      await _showApproveDialog();
    } else {
      await _showRejectDialog();
    }
  }

  Future<void> _showApproveDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Approve request",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: const Text(
            "Are you sure you want to approve this request?",
            style: baseTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Yes",
                style: baseTextStyle.copyWith(color: successColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "No",
                style: baseTextStyle.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      await request.approve();

      _showSnackBar("Request approved successfully!");
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  Future<void> _showRejectDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Reject request",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to reject this request? You can provide a reason below.",
                style: baseTextStyle,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: "Reason (optional)",
                ),
                maxLength: 120,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Yes",
                style: baseTextStyle.copyWith(
                  fontSize: 16.0,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No", style: baseTextStyle),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      await request.reject(
        message: reasonCtrl.text.isNotEmpty ? reasonCtrl.text : null,
      );

      _showSnackBar("Request rejected successfully.");
    } catch (error) {
      _showErrorDialog(error.toString());
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
            "Something went wrong while rejecting the request. Details: $message",
            style: baseTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
