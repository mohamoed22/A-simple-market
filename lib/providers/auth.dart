import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_extenshan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userid;
  Timer? _authTimer;

  String? get userData {
    return 'userData';
  }

  String? get isAuth {
    return token;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userid {
    return _userid;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyDLrPIXH-S0xHoSW8iJrbx3h0lAaUu29Pk');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userid = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autologout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userid': _userid,
        'expiryDate': _expiryDate!.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  Future<bool?> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    var m1 = prefs.getString('userData');
    // ignore: unused_local_variable
    final extrctedUserDate = await json.decode(m1!);
    final extrctDate = DateTime.parse(extrctedUserDate['expiryDate']);
    if (extrctDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extrctedUserDate['token'];
    _userid = extrctedUserDate['userid'];
    _expiryDate = extrctDate;
    notifyListeners();
    _autologout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userid = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer == null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autologout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpir = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpir), logout);
  }
}
