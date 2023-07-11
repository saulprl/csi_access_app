import "package:csi_door_logs/providers/logs_provider.dart";
import "package:csi_door_logs/providers/role_provider.dart";
import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:firebase_messaging/firebase_messaging.dart";
import "package:firebase_core/firebase_core.dart";

import "package:flutter_dotenv/flutter_dotenv.dart";

import "package:csi_door_logs/screens/screens.dart";

import "package:csi_door_logs/providers/auth_provider.dart";
import "package:csi_door_logs/providers/csi_users.dart";
import "package:csi_door_logs/providers/room_provider.dart";

import "package:csi_door_logs/firebase_options.dart";

@pragma("vm:entry-point")
Future<void> _bgMessageHandler(RemoteMessage message) async {
  debugPrint("Incoming message: ${message.notification!.body}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);
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
      primary: Color(0xFF7145D6),
      secondary: Color(0xFFE91E63),
      tertiary: Color(0xFF0080FF),
      error: Color(0xFFFF6F00),
      background: Colors.white,
      onPrimary: Colors.white,
      onBackground: Colors.black87,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CSIUsers()),
        ChangeNotifierProvider<AuthProvider>(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, RoomProvider>(
          create: (ctx) => RoomProvider(null),
          update: (ctx, auth, _) => RoomProvider(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<RoomProvider, RoleProvider>(
          create: (ctx) => RoleProvider(null, null),
          update: (ctx, room, _) => RoleProvider(
            room.userId,
            room.selectedRoom,
          ),
        ),
        ChangeNotifierProxyProvider<RoomProvider, LogsProvider>(
          create: (ctx) => LogsProvider(null),
          update: (ctx, room, _) => LogsProvider(room.selectedRoom),
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
            ),
            debugShowCheckedModeBanner: false,
            home: StreamBuilder(
              stream: Provider.of<AuthProvider>(ctx).authStateChanges,
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
                    future: Provider.of<RoomProvider>(
                      ctx,
                      listen: false,
                    ).fetchUserRooms(
                      Provider.of<AuthProvider>(ctx).user!.uid,
                    ),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SplashScreen(
                          message: "Getting rooms set up...",
                        );
                      } else if (snapshot.hasError) {
                        return const SplashScreen(
                          message: "An error occurred. Please try again later.",
                          error: true,
                        );
                      }

                      return const DashboardScreen();
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
