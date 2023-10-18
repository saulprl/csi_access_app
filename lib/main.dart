import "package:csi_door_logs/providers/pible_provider.dart";
import "package:csi_door_logs/providers/requests_provider.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";

import "package:provider/provider.dart";

import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";

import "package:flutter_dotenv/flutter_dotenv.dart";

import "package:csi_door_logs/providers/auth_provider.dart";
import "package:csi_door_logs/providers/csi_users.dart";
import "package:csi_door_logs/providers/room_provider.dart";
import "package:csi_door_logs/providers/logs_provider.dart";
import "package:csi_door_logs/providers/role_provider.dart";

import "package:csi_door_logs/screens/screens.dart";

import "package:csi_door_logs/utils/styles.dart";

import "package:csi_door_logs/firebase_options.dart";

@pragma("vm:entry-point")
Future<void> _bgMessageHandler(RemoteMessage message) async {
  debugPrint("Incoming message: ${message.notification?.body}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (!await Permission.notification.isPermanentlyDenied) {
    await Permission.notification.request();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (await Permission.notification.isGranted) {
    FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);
    // print("Init messaging");
  }
  // final fcm = FirebaseMessaging.instance;
  // fcm.subscribeToTopic("access_logs");
  // fcm.subscribeToTopic("event_logs");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const lightScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: errorColor,
      background: backgroundColor,
      onPrimary: onPrimaryColor,
      onBackground: onBackgroundColor,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CSIUsers()),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RoomProvider>(
          create: (ctx) => RoomProvider(),
          update: (ctx, auth, room) {
            room?.setAuthProvider(auth);
            // room?.setAuthUser(auth.user);
            // room?.setUser(auth.userData);
            return room ?? RoomProvider(auth: auth);
          },
        ),
        ChangeNotifierProxyProvider<RoomProvider, PibleProvider>(
          create: (ctx) => PibleProvider(),
          update: (ctx, room, pible) {
            pible?.setRoomProvider(room);

            return pible ?? PibleProvider(rooms: room);
          },
        ),
        ChangeNotifierProxyProvider<RoomProvider, RoleProvider>(
          create: (ctx) => RoleProvider(),
          update: (ctx, room, role) {
            role?.setData(
              user: room.authProvider?.userData,
              roomId: room.selectedRoom,
            );

            return role ??
                RoleProvider(
                  user: room.authProvider?.userData,
                  roomId: room.selectedRoom,
                  isRoot: room.authProvider?.userData?.isRootUser ?? false,
                );
          },
        ),
        ChangeNotifierProxyProvider<RoomProvider, RequestsProvider>(
          create: (ctx) => RequestsProvider(),
          update: (ctx, room, requests) {
            requests?.setData(
              user: room.authProvider?.userData,
              roomId: room.selectedRoom,
            );

            return requests ??
                RequestsProvider(
                  user: room.authProvider?.userData,
                  roomId: room.selectedRoom,
                  isRoot: room.authProvider?.userData?.isRootUser ?? false,
                );
          },
        ),
        ChangeNotifierProxyProvider<RoomProvider, LogsProvider>(
          create: (ctx) => LogsProvider(),
          update: (ctx, room, logs) {
            logs?.setRoom(roomId: room.selectedRoom);
            return logs ?? LogsProvider(roomId: room.selectedRoom);
          },
        ),
      ],
      child: Builder(
        builder: (ctx) {
          return MaterialApp(
            title: 'CSI PRO Access',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightScheme,
              fontFamily: "Poppins",
              inputDecorationTheme: InputDecorationTheme(
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 20.0,
                ),
                prefixIconColor: MaterialStateColor.resolveWith((states) {
                  if (states.contains(MaterialState.focused)) {
                    return primaryColor;
                  } else if (states.contains(MaterialState.disabled)) {
                    return Colors.grey;
                  } else {
                    return Colors.black;
                  }
                }),
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: StreamBuilder(
              stream: Provider.of<AuthProvider>(
                ctx,
                listen: false,
              ).authStateChanges,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen(message: "Authenticating...");
                } else if (snapshot.hasError) {
                  return const SplashScreen(
                    message: "An error occurred. Please try again later.",
                    error: true,
                  );
                } else if (snapshot.hasData) {
                  return FutureBuilder(
                    future: Provider.of<AuthProvider>(
                      ctx,
                      listen: false,
                    ).fetchUserData(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SplashScreen(
                          message: "Getting user data...",
                        );
                      } else if (snapshot.hasError) {
                        return const SplashScreen(
                          message: "An error occurred. Please try again later.",
                          error: true,
                        );
                      }

                      if (Provider.of<AuthProvider>(ctx).userData == null) {
                        return const SignupScreen();
                      } else {
                        return FutureBuilder(
                          future: Provider.of<RoomProvider>(
                            ctx,
                            listen: false,
                          ).fetchUserRooms(),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SplashScreen(
                                message: "Getting rooms set up...",
                              );
                            } else if (snapshot.hasError) {
                              return const SplashScreen(
                                message:
                                    "An error occurred. Please try again later.",
                                error: true,
                              );
                            }

                            return const DashboardScreen();
                          },
                        );
                      }
                    },
                  );
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
