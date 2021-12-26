import 'package:flutter/widgets.dart'; //for ChangeNotifier
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

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
      notifyListeners();
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
}
