import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router_plus/go_router_plus.dart';
import 'package:laroona_flutter_lib/providers/request_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole {
  none(0),
  superAdmin(1),
  admin(2),
  subAdmin(3),
  user(4);

  const UserRole(this.value);
  final int value;
}

class AuthProvider extends ChangeNotifier implements LoggedInState {
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  dynamic _authUser;
  dynamic get user => _authUser;
  List<dynamic> get clubs =>
      _authUser != null && _authUser?.containsKey('clubs')
      ? _authUser['clubs']
      : [];

  late StreamController<dynamic> onChangeClubStreamController;
  late Stream<dynamic> onChangeClubStream;

  AuthProvider() {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      final encodedUser = (await SharedPreferences.getInstance()).getString(
        'user',
      );
      if (encodedUser != null && encodedUser.isNotEmpty) {
        _authUser = json.decode(encodedUser);
      }

      _isInitializing = false;
      onChangeClubStreamController = StreamController<dynamic>();
      onChangeClubStream = onChangeClubStreamController.stream
          .asBroadcastStream();
      notifyListeners();
    });
  }

  @override
  bool get loggedIn {
    return _authUser != null;
  }

  String get token => _authUser != null ? _authUser['token'] : '';

  Future<bool> login(BuildContext context, dynamic user) async {
    if (user == null || user['role_id'] != UserRole.subAdmin.value) {
      return false;
    }
    _authUser = user;
    String encodedUser = json.encode(user);
    (await SharedPreferences.getInstance()).setString('user', encodedUser);
    notifyListeners();
    if (context.mounted) {
      Provider.of<RequestProvider>(context, listen: false).clearRequests();
    }
    return true;
  }

  Future<bool> logout(BuildContext context) async {
    _authUser = null;
    final prefs = await SharedPreferences.getInstance();

    // Preserve theme mode before clearing
    final themeMode = prefs.getBool('theme_mode');

    await prefs.clear();

    // Restore theme mode
    if (themeMode != null) {
      await prefs.setBool('theme_mode', themeMode);
    }

    notifyListeners();
    if (context.mounted) {
      Provider.of<RequestProvider>(context, listen: false).clearRequests();
    }
    return true;
  }
}
