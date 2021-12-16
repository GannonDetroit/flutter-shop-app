import 'package:flutter/widgets.dart'; //for ChangeNotifier
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  final API_KEY =
      dotenv.get('firebaseAuthApi', fallback: 'DOTENV DID NOT WORK');

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
    } catch (err) {
      throw err;
    }
  }

  // Future<void> signup(String email, String password) async {
  //   final url = Uri.parse(
  //       'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY');
  //   final res = await http.post(url,
  //       body: json.encode(
  //           {'email': email, 'password': password, 'returnSecureToken': true}));
  //   print(json.decode(res.body));
  // }

  // Future<void> login(String email, String password) async {
  //   final url = Uri.parse(
  //       'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBpD4sxZ7wGS26CycuazTinvqyb-zegr0o');
  //   final res = await http.post(url,
  //       body: json.encode(
  //           {'email': email, 'password': password, 'returnSecureToken': true}));
  //   print(json.decode(res.body));
  // }
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
