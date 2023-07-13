import 'dart:async';
import 'dart:convert';

import 'package:csi_door_logs/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_bcrypt/flutter_bcrypt.dart';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'package:csi_door_logs/models/user_model.dart';

const clientId = "cc8283f8877f892c04b3";
const redirectUri = "com.csipro.access";

class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();

  User? _authUser;
  UserModel? _user;
  StreamSubscription? _userSub;
  StreamSubscription? _isRootSub;
  StreamSubscription? _authStateSub;

  User? get user => _authUser;
  UserModel? get userData => _user;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    _authStateSub = _auth.authStateChanges().listen((user) {
      _authUser = user;
      _initializeSubs();
      notifyListeners();
    });
  }

  Future<void> _initializeSubs() async {
    if (_authUser == null) return;

    await _storage.write(key: firebaseUidStorageKey, value: _authUser!.uid);

    final userRef = _firestore.collection('users').doc(_authUser!.uid);
    if (!(await userRef.get()).exists) return;

    _userSub = _firestore
        .collection('users')
        .doc(_authUser!.uid)
        .snapshots()
        .listen((userData) async {
      if (_authUser == null) return;

      _user = UserModel.fromDocSnapshot(userData);

      await _storage.write(key: unisonIdStorageKey, value: _user!.unisonId);
      await _storage.write(
        key: csiIdStorageKey,
        value: _user!.csiId.toString(),
      );
      notifyListeners();
    });

    _isRootSub = _firestore
        .collection('user_roles')
        .doc(_authUser!.uid)
        .snapshots()
        .listen((userRoles) {
      if (_user == null || _authUser == null) return;

      _user!.setIsRoot = userRoles.data()?['isRoot'];
      notifyListeners();
    });
  }

  Future<void> fetchUserData() async {
    if (_authUser == null) return;

    try {
      final userRef = _firestore.collection('users').doc(_authUser!.uid);
      if (!(await userRef.get()).exists) return;

      _user = UserModel.fromDocSnapshot(await userRef.get());

      final userRolesSnapshot =
          await _firestore.collection('user_roles').doc(_authUser!.uid).get();
      _user!.setIsRoot = userRolesSnapshot.data()?['isRoot'];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGitHub() async {
    try {
      final result = await FlutterWebAuth2.authenticate(
        url:
            'https://github.com/login/oauth/authorize?client_id=$clientId&scope=user:email',
        callbackUrlScheme: redirectUri,
      );

      final ghCode = Uri.parse(result).queryParameters['code'];
      if (ghCode == null) return;

      final accessToken = await _exchangeCodeForToken(ghCode);
      final credential = GithubAuthProvider.credential(accessToken);
      await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _exchangeCodeForToken(String code) async {
    final clientSecret = dotenv.env['GITHUB_CLIENT_SECRET'];
    if (clientSecret == null) {
      throw Exception('GITHUB_CLIENT_SECRET is not defined');
    }

    final response = await http.post(
      Uri.parse("https://github.com/login/oauth/access_token"),
      headers: {
        "Accept": "application/json",
      },
      body: {
        "client_id": clientId,
        "client_secret": clientSecret,
        "code": code,
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);
    final String token = data["access_token"];

    return token;
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw Exception("Google sign in failed");
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> populateUserData({
    required String unisonId,
    required String name,
    required String passcode,
    required DateTime dob,
    required String roomId,
    required String roleName,
  }) async {
    try {
      if (await unisonIdExists(unisonId)) {
        throw Exception("Unison ID already in use");
      }

      final room = await _firestore.collection("rooms").doc(roomId).get();
      if (!room.exists) {
        throw Exception("Room does not exist");
      }

      final role = await _firestore
          .collection("roles")
          .where("name", isEqualTo: roleName)
          .limit(1)
          .get();
      if (role.docs.isEmpty) {
        throw Exception("Role does not exist");
      }

      if (_authUser == null) {
        throw Exception("User is not authenticated");
      }

      final passcodeHash = await FlutterBcrypt.hashPw(
        password: passcode,
        salt: await FlutterBcrypt.saltWithRounds(rounds: 10),
      );

      final lastUserSnapshot = await _firestore
          .collection("users")
          .orderBy("csiId", descending: true)
          .limit(1)
          .get();
      if (lastUserSnapshot.docs.isEmpty) {
        throw Exception("Something went wrong while creating user");
      }

      final lastCsiId =
          UserModel.fromQueryDocSnapshot(lastUserSnapshot.docs.first).csiId;

      await _firestore.collection("users").doc(_authUser!.uid).set({
        "csiId": lastCsiId + 1,
        "unisonId": unisonId,
        "name": name,
        "passcode": passcodeHash,
        "dateOfBirth": Timestamp.fromDate(dob),
        "createdAt": Timestamp.now(),
      });

      await _firestore.collection("user_roles").doc(_authUser!.uid).set({
        "key": _authUser!.uid,
      });

      await _firestore
          .collection("user_roles")
          .doc(_authUser!.uid)
          .collection("room_roles")
          .doc(room.id)
          .set({
        "key": room.id,
        "roleId": role.docs.first.reference,
        "accessGranted": false,
      });

      _initializeSubs();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> unisonIdExists(String unisonId) async {
    final existingUser = await _firestore
        .collection("users")
        .where("unisonId", isEqualTo: unisonId)
        .get();

    return existingUser.docs.isNotEmpty;
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _storage.deleteAll();
      await _auth.signOut();
      _user = null;
      _authUser = null;
      _userSub?.cancel();
      _isRootSub?.cancel();

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _isRootSub?.cancel();
    _authStateSub?.cancel();

    super.dispose();
  }
}
