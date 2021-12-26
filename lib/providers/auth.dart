import 'package:flutter/widgets.dart'; //for ChangeNotifier
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/http_exception.dart';
import 'dart:async';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

//check if we have an auth token and if its not expired.
  bool get isAuth {
    return token != null;
  }

//get the actual token
  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  final API_KEY =
      dotenv.get('firebaseAuthApi', fallback: 'DOTENV DID NOT WORK');

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$API_KEY');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      //because firebase is a bit weird in that its error still are status 200, you need to search for 'error'in the response message to know if you have one.
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      //since the token returns a string with how many seconds are left until the token exprires we need to caculate that amount.
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      //store auth info on device to help with auto-login feature.
      //get a future of the SharedPreference instance which is used as the 'tunnel' to the ondevice storage.
      final prefs = await SharedPreferences.getInstance();
      //out of the box you can store primative datatypes like bool, int, string, if you want to store more complex data like a map/object you can encode it in JSON as a string.
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryData': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (err) {
      throw err;
    }
  }

//since the code for these are so similar we pulled it out and put it into _authenicate to save a lot of code and make error handling easier too.
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      return false; //there is no user data stored on the device for some reason.
    }
    //remember we encoded JSON when we stored the userData so we need to decode it here.
    final extractedUserData = prefs.getString('userData');
    final userData = json.decode(extractedUserData) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryData'] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      return false; //the stored token is expired.
    }
    //since we have a good token stored locally, re-populate your local data;
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout(); //this will auto restart the timer too.
    return true; //need to return a bool so only do true at the end of everything was successful.
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //how to do it if you were storing multiple things in sharedPreferences and only wanted to delete one thing.
    // prefs.remove('userData');
    //this clears everything.
    prefs.clear();
  }

  void _autoLogout() {
    //check if there is an existing timer and cancel it before setting up a new one to avoid bugs.
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
