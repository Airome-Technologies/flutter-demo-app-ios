import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pcsdk/pcsdk.dart';
import 'package:pcsdk/models/pcloggingoptions.dart';
import 'package:pcsdk/models/pcuser.dart';
import 'package:pcsdk/pcusersmanager.dart';
import 'package:pcsdk_demo/api_helper.dart';
import 'package:pcsdk_demo/create_transaction.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PCUser? _activeUser;

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  // Initializing SDK
  Future<void> initSDK() async {
    try {
      await PCSDK.setLogLevel(PCLoggingOptions.debug + PCLoggingOptions.sensitive);
      await PCSDK.initialize();
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }

    if (!mounted) return;

    await refreshUsers();
  }

  Future refreshUsers() async {
    try {
      List<PCUser> users = await PCUsersManager.listUsers();
      debugPrint('Users: ${users.toString()}');
      if (users.isNotEmpty) {
        setState(() {
          _activeUser = users.first;
        });
      }
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }

  Future prepareUser() async {
    try {
      /**
       * 1. Getting json with user information
       * 
       * =========================================
       * [WARNING] DO NOT USE IN PRODUCTION BUILDS
       * =========================================
       * 
       * Usually a client gets this data via QR code. For demo purpose
       * we create the new User using an internal PC Server API.
       * Using this method in production builds is unsafe and not recommended.
       * 
       * */
      String userJSON = await APIHelper.createUser();

      // 2. Importing user
      PCUser user = await PCUsersManager.importUser(userJSON);

      // 3. Activating
      //
      // We use the activation code provided in APIHelper.createUser()
      // method.
      if (await user.isActivated() == false) {
        PCUsersManager.activate(user, '123456');
      }

      // 4. Registering
      //
      // We keeps push token empty in this Demo app
      await PCUsersManager.register(user, '');

      // 5. Storing
      //
      // We provide "hard-coded" password 111111.
      // In a real app a client should create a password using an app UI
      await PCUsersManager.store(user, 'testName', '111111');

      // 6. Refreshing users
      await refreshUsers();
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }

  Widget renderOnboarding() => SafeArea(
      minimum: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Welcome to PCSDK Demo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                )),
            const Text(
              'Register a user in order to make transfers',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                    onPressed: () {
                      prepareUser();
                    },
                    child: const Text('Register'),
                    style:
                        ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)))),
            const Spacer(flex: 2)
          ],
        ),
      ));

  Widget renderHome(PCUser? user) {
    if (user != null) {
      return CreateTransaction(
        user: user,
      );
    } else {
      return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0x00000000),
          ),
          body: renderOnboarding());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: renderHome(_activeUser),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
