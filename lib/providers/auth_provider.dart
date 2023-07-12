import 'dart:async';
import 'dart:convert';

import 'package:csi_door_logs/screens/screens.dart';
import 'package:csi_door_logs/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'package:csi_door_logs/models/user_model.dart';

const clientId = "cc8283f8877f892c04b3";
const redirectUri = "com.csipro.access";

class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

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
      _initializeSubscriptions();
      notifyListeners();
    });
  }

  Future<void> _initializeSubscriptions() async {
    if (_authUser == null) return;

    final userRef = _firestore.collection('users').doc(_authUser!.uid);
    if (!(await userRef.get()).exists) {
      print("User does not exist in database");
      return;
    }

    _userSub = _firestore
        .collection('users')
        .doc(_authUser!.uid)
        .snapshots()
        .listen((userData) {
      if (_authUser == null) return;

      _user = UserModel.fromDocSnapshot(userData);
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
      if (!(await userRef.get()).exists) {
        print("User does not exist in database");
        return;
      }

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
      if (ghCode == null) {
        throw Exception('GitHub code is null');
      }

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

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
      });
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
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
