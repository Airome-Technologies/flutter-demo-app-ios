import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ====================================================
// [WARNING] DO NOT USE IN PRODUCTION BUILDS
//
// This is helper to work with PC Server on behalf of
// Appliction back-end
//
// Operations like create-user, create-transaction and
// similar HAVE to be executed by Appliction back-end,
// not by mobile app.
//
// To simplify this sample app, we call this functions
// directly form mobile app.
//
// !!! THIS IS FOR DEMO PURPOSES ONLY !!!
// ====================================================

class APIHelper {
  // Common info
  static String systemID = 'e55d3d79-327e-4c23-b152-967a57258d57';  // see https://repo.payconfirm.org/server/doc/v5.3/rest-api/#systems-endpoint
  static String apiURI = 'https://dev.payconfirm.org/api4/pc/pc-api';

  // Endpoints
  static String createUserURI = '$apiURI/$systemID/users'; // see https://repo.payconfirm.org/server/doc/v5.3/rest-api/#create-user

  // ==================================================
  // This function is for demo purposes only !!!
  //
  // User has to be created as described in PC docs
  // https://repo.payconfirm.org/server/doc/v5.3/arch_and_principles/#mobile-app-personalization-and-keys-generation
  //
  // Do not interact with PC Server directly 
  // from mobile app
  // ==================================================
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

  // ==================================================
  // This function is for demo purposes only !!!
  //
  // Transactions has to be created as described in PC docs
  // https://repo.payconfirm.org/server/doc/v5.3/arch_and_principles/#document-signing-flow
  //
  // Do not interact with PC Server directly 
  // from mobile app
  // ==================================================
  static Future<String> createTransaction(String text, String userID) async {
    debugPrint('===== Creating transaction =====');

    Object? body = jsonEncode(<String, dynamic>{
      'transaction_data': {'text': text},
      'confirm_code_length': 8,
      'ttl': 0
    });

    String createTransactionURI = '$apiURI/$systemID/users/$userID/transactions'; // see https://repo.payconfirm.org/server/doc/v5.3/rest-api/#create-transaction

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
