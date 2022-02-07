import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exeption.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  bool get isAuthenticated {
    return _token != null;
  }

  get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    } else {
      return null;
    }
  }

  Future<void> authenticate(
    String email,
    String password,
    String requestUrl,
  ) async {
    final url = Uri.parse(requestUrl);

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
        throw HttpExeption(message: responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return authenticate(
      email,
      password,
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyB2qr7yagVSdfBUDNCFzgYxOzzZT6PEPgA',
    );
  }

  Future<void> login(String email, String password) async {
    return authenticate(
      email,
      password,
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyB2qr7yagVSdfBUDNCFzgYxOzzZT6PEPgA',
    );
  }

  void logout () {
    _token = null;
    _expiryDate = null;
    _userId = null;

    notifyListeners();
  }
}
