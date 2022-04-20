import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// =========================================
// [WARNING] DO NOT USE IN PRODUCTION BUILDS
// =========================================
class APIHelper {
  // Common info
  static String systemID = 'e55d3d79-327e-4c23-b152-967a57258d57';
  static String apiURI = 'https://dev.payconfirm.org/api4/pc/pc-api';

  // Endpoints
  static String createUserURI = '$apiURI/$systemID/users';

  static Future<String> createUser() async {
    debugPrint('===== Creating User =====');

    Object? body = jsonEncode(<String, dynamic>{
      'id_prefix': 'flutter-demo-',
      'user_name': 'User Name',
      'key_params': {
        'pass_policy': 0,
      },
      'key_encryption_password': '123456',
      'return_key_method': 'KEY_JSON'
    });
    debugPrint('URI: ${createUserURI.toString()}');
    debugPrint('Request\'s Body: ${body.toString()}');
    http.Response response = await http.post(Uri.parse(createUserURI),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    debugPrint('Headers: ${response.headers.toString()}');
    debugPrint('Response\'s body: ${response.body}');
    Map<String, dynamic> jsonMap = json.decode(response.body);
    String keyJSON = jsonMap['answer']['user_created']['key_json'];
    debugPrint('Key JSON: $keyJSON');

    return keyJSON;
  }

  static Future<String> createTransaction(String text, String userID) async {
    debugPrint('===== Creating transaction =====');

    Object? body = jsonEncode(<String, dynamic>{
      'transaction_data': {'text': text},
      'confirm_code_length': 8,
      'ttl': 0
    });

    String createTransactionURI = '$apiURI/$systemID/users/$userID/transactions';

    debugPrint('URI: ${createTransactionURI.toString()}');
    debugPrint('Request\'s Body: ${body.toString()}');
    http.Response response = await http.post(Uri.parse(createTransactionURI),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    debugPrint('Headers: ${response.headers.toString()}');
    debugPrint('Response\'s body: ${response.body}');
    Map<String, dynamic> jsonMap = json.decode(response.body);
    String transactionID = jsonMap['answer']['transaction_created']['transaction_id'];
    debugPrint('Transaction ID: $transactionID');

    return transactionID;
  }
}
