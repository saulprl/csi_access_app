import "package:csi_door_logs/providers/room_provider.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:csi_door_logs/screens/screens.dart";

import "package:csi_door_logs/widgets/dashboard/personal/personal_summary.dart";
import "package:csi_door_logs/widgets/dashboard/summary/summary.dart";
import "package:csi_door_logs/widgets/main/index.dart";

import "package:csi_door_logs/utils/routes.dart";
import "package:provider/provider.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _hasStorage = false;
  bool _shouldPop = false;

  @override
  void initState() {
    super.initState();

    _readStorage();
  }

  Future<void> _readStorage() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await Future.delayed(const Duration(milliseconds: 750));

    final storage = await _storage.readAll();
    if (storage.isNotEmpty) {
      if (mounted) {
        setState(() {
          _hasStorage = storage.containsKey("CSIPRO-PASSCODE");
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _hasStorage = false;
          _isLoading = false;
        });
      }
    }
  }

  SnackBar get snackBar => const SnackBar(
        content: Text(
          "Press again to exit",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18.0,
          ),
        ),
        duration: Duration(seconds: 2),
      );

  Future<bool> willPopHandler() async {
    if (_shouldPop) {
      SystemNavigator.pop();

      return true;
    }

    _shouldPop = true;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _shouldPop = false;
    });

    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = Provider.of<RoomProvider>(context);

    return WillPopScope(
      onWillPop: willPopHandler,
      child: Scaffold(
        appBar: const CSIAppBar("Dashboard", roomSelector: true),
        drawer: CSIDrawer(),
        body: SafeArea(
          child: !rooms.isRoomless
              ? SingleChildScrollView(
                  child: Builder(
                    builder: builder,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text:
                              "You're not a member of any rooms yet! Check out the ",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18.0,
                            fontFamily: "Poppins",
                          ),
                          children: [
                            TextSpan(
                              text: "Rooms",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  " screen to request access to a room or look at your active ",
                            ),
                            TextSpan(
                              text: "Requests",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            Routes.pushFromRight(const RoomsScreen(page: 1)),
                          );
                        },
                        child: const Text(
                          "Go to Requests",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            Routes.pushFromRight(const RoomsScreen()),
                          );
                        },
                        child: const Text(
                          "Go to Rooms",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        floatingActionButton: !rooms.isRoomless ? floatingActionButton : null,
      ),
    );
  }

  Widget builder(BuildContext ctx) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 3) {
          Scaffold.of(ctx).openDrawer();
        }

        if (details.delta.dx < -7 && !_isLoading) {
          onAttemptAccess();
        }
      },
      child: dashboardContent,
    );
  }

  Padding get dashboardContent {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Summary(),
          PersonalSummary(),
          SizedBox(height: 80.0),
        ],
      ),
    );
  }

  Widget get floatingActionButton => FloatingActionButton(
        onPressed: _isLoading ? null : onAttemptAccess,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: _isLoading
            ? const SizedBox(
                width: 26.0,
                height: 26.0,
                child: AdaptiveSpinner(color: Colors.white),
              )
            : floatingChild,
      );

  void Function() get onAttemptAccess => _hasStorage
      ? () => Navigator.of(context).push(
            Routes.pushFromRight(const PibleScreen()),
          )
      : () async {
          await Navigator.of(context).push(
            Routes.pushFromRight(const CSICredentialsScreen()),
          );
          _readStorage();
        };

  Widget get floatingChild => _hasStorage
      ? Image.asset("assets/access_logo_fg.png")
      : const Icon(
          Icons.error_rounded,
          size: 34.0,
          color: Colors.white,
        );
}
