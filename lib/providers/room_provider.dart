import 'dart:async';

import 'package:csi_door_logs/providers/auth_provider.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:csi_door_logs/models/room.dart';
import 'package:csi_door_logs/models/user_model.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Room> _rooms = [];
  List<Room> _userRooms = [];
  String _selectedRoom = "";
  bool _isRoomless = false;
  // User? _authUser;
  // UserModel? _user;
  StreamSubscription? _roomsSub;
  StreamSubscription? _userRoomsSub;
  AuthProvider? _authProvider;

  // UserModel? get user => _user;
  AuthProvider? get authProvider => _authProvider;
  List<Room> get rooms => _rooms;
  List<Room> get userRooms => _userRooms;
  String get selectedRoom => _selectedRoom;
  bool get isRoomless => _isRoomless;

  RoomProvider({AuthProvider? auth, User? authUser, UserModel? user}) {
    setAuthProvider(auth);
  }

  void setAuthProvider(AuthProvider? auth) {
    if (auth != null) {
      _authProvider = auth;
      _initializeSubs();
    }

    if (auth?.user == null) {
      _roomsSub?.cancel();
      _userRoomsSub?.cancel();
      _selectedRoom = "";
    }
  }

  void _initializeSubs() {
    _initializeRoomsSub();
    _initializeUserRoomsSub();
  }

  void _initializeRoomsSub() {
    _roomsSub = _firestore.collection("rooms").snapshots().listen((rooms) {
      _rooms =
          rooms.docs.map((room) => Room.fromQueryDocSnapshot(room)).toList();

      if (_authProvider!.userData?.isRootUser ?? false) {
        _userRooms = _rooms;
      }
      notifyListeners();
    });
  }

  void _initializeUserRoomsSub() {
    if (_authProvider == null || _authProvider?.userData == null) return;

    _userRoomsSub = _firestore
        .collection("user_roles")
        .doc(_authProvider!.userData!.key)
        .collection("room_roles")
        .snapshots()
        .listen((userRooms) {
      final userRoomIds = userRooms.docs.map((room) => room.id).toList();

      if (_authProvider?.userData?.isRootUser ?? false) {
        _userRooms = _rooms;
      } else {
        _userRooms =
            _rooms.where((room) => userRoomIds.contains(room.key)).toList();
      }

      if (_userRooms.isEmpty) {
        _isRoomless = true;
        _selectedRoom = "";
      } else if (_selectedRoom == "" ||
          !_userRooms.any((room) => room.key == _selectedRoom)) {
        _isRoomless = false;

        final prefs = SharedPreferences.getInstance();
        prefs.then((prefs) {
          final selectedRoom = prefs.getString("selectedRoom");

          if (selectedRoom != null &&
              _userRooms.any((room) => room.key == selectedRoom)) {
            _selectedRoom = selectedRoom;
          } else {
            _selectedRoom = _userRooms[0].key;

            prefs.setString("selectedRoom", _selectedRoom);
          }
        });
      }
      notifyListeners();
    });
  }

  Future<void> fetchRooms() async {
    try {
      final rooms = await _firestore.collection("rooms").get();
      _rooms =
          rooms.docs.map((room) => Room.fromQueryDocSnapshot(room)).toList();
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> fetchUserRooms() async {
    if (_authProvider == null || _authProvider?.userData == null) return;

    try {
      final userRooms = await _firestore
          .collection("user_roles")
          .doc(_authProvider!.userData!.key)
          .collection("room_roles")
          .get();
      final userRoomIds = userRooms.docs.map((room) => room.id).toList();

      final roomsSnapshot = await _firestore.collection("rooms").get();
      final roomsData = roomsSnapshot.docs
          .where((room) => userRoomIds.contains(room.id))
          .toList();

      _rooms = roomsSnapshot.docs
          .map((room) => Room.fromQueryDocSnapshot(room))
          .toList();

      if (_authProvider?.userData?.isRootUser ?? false) {
        _userRooms = _rooms;
      } else {
        _userRooms =
            roomsData.map((room) => Room.fromQueryDocSnapshot(room)).toList();
      }

      if (_userRooms.isEmpty) {
        _isRoomless = true;
      } else if ((_selectedRoom == "" && _userRooms.isNotEmpty) ||
          !_userRooms.any((room) => room.key == _selectedRoom)) {
        _isRoomless = false;

        final prefs = await SharedPreferences.getInstance();
        final selectedRoom = prefs.getString("selectedRoom");

        if (selectedRoom != null &&
            _userRooms.any((room) => room.key == selectedRoom)) {
          _selectedRoom = selectedRoom;
        } else {
          _selectedRoom = _userRooms[0].key;

          await prefs.setString("selectedRoom", _selectedRoom);
        }
      }
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  void selectRoom(String room) async {
    if (room == _selectedRoom) {
      return;
    }

    if (!_userRooms.map((room) => room.key).contains(room)) {
      throw "You don't seem to have access to this room.";
    }

    _selectedRoom = room;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedRoom", room);
  }

  @override
  dispose() {
    _roomsSub?.cancel();
    _userRoomsSub?.cancel();

    super.dispose();
  }
}
