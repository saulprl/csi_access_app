import "package:csi_door_logs/utils/routes.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";

import "package:csi_door_logs/screens/screens.dart";
import "package:csi_door_logs/firebase_options.dart";

@pragma("vm:entry-point")
Future<void> _bgMessageHandler(RemoteMessage message) async {
  print("Incoming message: ${message.notification!.body}");
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // FirebaseMessaging.onMessage.listen((message) {
  //   print(message.data);
  //   return;
  // });
  FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
      tertiary: Color(0xFF09814A),
      error: Color(0xFFFCD80C),
      background: Colors.white,
      onPrimary: Colors.white,
      onBackground: Colors.black87,
    );

    return FutureBuilder(
      future: firebaseApp,
      builder: (ctx, snapshot) => MaterialApp(
        title: 'CSI PRO Access',
        theme: ThemeData(
          colorScheme: lightScheme,
          fontFamily: "Poppins",
        ),
        debugShowCheckedModeBanner: false,
        home: snapshot.connectionState == ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : const DashboardScreen(),
        routes: Routes.getAppRoutes(),
      ),
    );
  }
}
