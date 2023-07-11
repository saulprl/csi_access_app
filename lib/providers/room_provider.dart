import 'dart:async';

import 'package:csi_door_logs/models/user_model.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:csi_door_logs/models/room.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Room> _rooms = [];
  List<Room> _userRooms = [];
  String _selectedRoom = "";
  UserModel? _user;
  StreamSubscription? _roomsSubscription;
  StreamSubscription? _userRoomSubscription;

  UserModel? get user => _user;
  List<Room> get rooms => _rooms;
  List<Room> get userRooms => _userRooms;
  String get selectedRoom => _selectedRoom;

  RoomProvider({UserModel? user}) {
    setUser(user);
  }

  void setUser(UserModel? user) {
    if (user != null) {
      _user = user;
      _initializeSubscriptions();
    } else {
      _roomsSubscription?.cancel();
      _userRoomSubscription?.cancel();
    }
  }

  void _initializeSubscriptions() {
    if (_user == null) return;

    _roomsSubscription =
        _firestore.collection("rooms").snapshots().listen((rooms) {
      _rooms =
          rooms.docs.map((room) => Room.fromQueryDocSnapshot(room)).toList();

      if (user != null && _user!.isRootUser) {
        _userRooms = _rooms;
      }
      notifyListeners();
    });

    _userRoomSubscription = _firestore
        .collection("user_roles")
        .doc(_user!.key)
        .collection("room_roles")
        .snapshots()
        .listen((userRooms) {
      final userRoomIds = userRooms.docs.map((room) => room.id).toList();

      if (user != null && _user!.isRootUser) {
        _userRooms = _rooms;
      } else {
        _userRooms =
            _rooms.where((room) => userRoomIds.contains(room.key)).toList();
      }

      if ((_selectedRoom == "" && _userRooms.isNotEmpty) ||
          !_userRooms.any((room) => room.key == _selectedRoom)) {
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

  Future<void> fetchUserRooms(String userId) async {
    try {
      final userRooms = await _firestore
          .collection("user_roles")
          .doc(userId)
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

      if (user != null && _user!.isRootUser) {
        _userRooms = _rooms;
      } else {
        _userRooms =
            roomsData.map((room) => Room.fromQueryDocSnapshot(room)).toList();
      }

      if ((_selectedRoom == "" && _userRooms.isNotEmpty) ||
          !_userRooms.any((room) => room.key == _selectedRoom)) {
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
    _roomsSubscription?.cancel();
    _userRoomSubscription?.cancel();

    super.dispose();
  }
}
