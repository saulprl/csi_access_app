import "package:csi_door_logs/providers/csi_users.dart";
import "package:csi_door_logs/utils/routes.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

import "package:csi_door_logs/screens/screens.dart";
import "package:csi_door_logs/firebase_options.dart";
import "package:provider/provider.dart";

@pragma("vm:entry-point")
Future<void> _bgMessageHandler(RemoteMessage message) async {
  debugPrint("Incoming message: ${message.notification!.body}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> firebaseApp = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebaseApp.then((_) {
      final fcm = FirebaseMessaging.instance;
      fcm.subscribeToTopic("access_logs");
      fcm.subscribeToTopic("event_logs");
    });

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
      ],
      child: FutureBuilder(
        future: firebaseApp,
        builder: (ctx, snapshot) => MaterialApp(
          title: 'CSI PRO Access',
          theme: ThemeData(
            colorScheme: lightScheme,
            fontFamily: "Poppins",
          ),
          debugShowCheckedModeBanner: false,
          home: snapshot.connectionState != ConnectionState.done
              ? const SplashScreen()
              : StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (ctx, AsyncSnapshot<User?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreen();
                    }

                    if (snapshot.hasData) {
                      return const DashboardScreen();
                    }

                    return const LoginScreen();
                  },
                ),
          routes: Routes.getAppRoutes(),
        ),
      ),
    );
  }
}
