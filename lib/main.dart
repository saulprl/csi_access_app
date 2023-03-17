import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";

import "package:csi_door_logs/screens/screens.dart";
import "package:csi_door_logs/firebase_options.dart";

void main() {
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

    const lightScheme = ColorScheme.light(
      primary: Color(0xFF7145D6),
      secondary: Color(0xFFE91E63),
      background: Colors.white,
      onPrimary: Colors.white,
    );

    return FutureBuilder(
      future: firebaseApp,
      builder: (ctx, snapshot) => MaterialApp(
        title: 'CSI PRO Access Logs',
        theme: ThemeData(
          colorScheme: lightScheme,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}
