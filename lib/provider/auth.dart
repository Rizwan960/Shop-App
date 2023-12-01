import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    // return token != null;
    if (_token == null) {
      return false;
    }
    return true;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }
    return '';
  }

  String get userId {
    return _userId!;
  }

  Future<void> userSignUp(String email, String password) async {
    /* final responce =*/ await http.post(
      Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDawXmKNAd-O4EqFGNZWgupIGV-TUWW0Qs'),
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
  }

  Future<void> userSignIn(String email, String password) async {
    try {
      final responce = await http.post(
        Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDawXmKNAd-O4EqFGNZWgupIGV-TUWW0Qs'),
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final Responce = json.decode(responce.body);
      if (Responce['error'] != null) {
        throw HttpException(Responce['error']['message']);
      }
      _token = Responce['idToken'];
      _userId = Responce['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            Responce['expiresIn'],
          ),
        ),
      );
      _autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userDate = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userDate);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userDate')) {
      return false;
    }
    final extractDate =
        json.decode(prefs.getString('userDate')!) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractDate['expiryDate'] as String);
    if (expiryDate.isAfter(DateTime.now())) {
      return false;
    }
    _token = extractDate['token'] as String;
    _userId = extractDate['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logOut);
  }
}
