import 'package:firebase_app/providers/FollowingProvider.dart';
import 'package:firebase_app/shared/variables.dart';
import 'package:firebase_app/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
 import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  int _blackPrimaryValue = 0xFF000000;
  pref = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FollowingProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
        title: 'Instagram',
        theme: ThemeData(
          primarySwatch: MaterialColor(
            _blackPrimaryValue,
            <int, Color>{
              50: Color(0xFF000000),
              100: Color(0xFF000000),
              200: Color(0xFF000000),
              300: Color(0xFF000000),
              400: Color(0xFF000000),
              500: Color(_blackPrimaryValue),
              600: Color(0xFF000000),
              700: Color(0xFF000000),
              800: Color(0xFF000000),
              900: Color(0xFF000000),
            },
          ),
          appBarTheme:
              AppBarTheme(iconTheme: IconThemeData(color: Colors.black)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black)),
          ),
          fontFamily: 'Lato',
          backgroundColor: Colors.black,
        ),
      ),
    ),
  );
}
