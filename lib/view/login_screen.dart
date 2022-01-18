import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/signup_screen.dart';
import 'package:firebase_app/widgets/unicorn_button.dart';
import 'package:firebase_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool passwordVisibility = false;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Container(
              width: width,
              height: height * 0.3,
              child: CustomPaint(
                size: Size(width, (width * 0.5833333333333334).toDouble()),
                //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                painter: RPSCustomPainter(),
              ),
            ),
            Center(
              child: GradientText(
                style: bigTextStyle(),
                text: 'Welcome to Instagram',
                gradient: LinearGradient(colors: [
                  Colors.orange,
                  Colors.pink,
                ]),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => emailController.text = val!,
                validator: (val) {
                  if (val!.isEmpty) return 'Please Enter Your Email';
                },
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon:
                      Icon(Icons.email, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: TextFormField(
                keyboardType: TextInputType.visiblePassword,
                onSaved: (val) => passwordController.text = val!,
                validator: (val) {
                  if (val!.isEmpty) return 'Please Enter Your Password';
                  if (val.length < 6) return 'Password at least 6 characters';
                },
                obscureText: passwordVisibility == true ? true : false,
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: passwordVisibility == true
                      ? IconButton(
                          icon: Icon(
                            Icons.visibility_off,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisibility = !passwordVisibility;
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisibility = !passwordVisibility;
                            });
                          },
                        ),
                  prefixIcon:
                      Icon(Icons.lock, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim())
                        .then((value) {
                      navigateToPageWithoutBack(
                        context,
                        HomeNavigationBar(),
                      );
                    }).catchError((error) {
                      CommonWidget.makeSnackBar(
                          title: 'Error',
                          message: error.message,
                          color: Colors.red, context: context);
                    });
                  }
                },
                child: Text(
                  'Log In',
                  style: mediumTextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Center(
                child: InkWell(
                    onTap: () {
                      navigateToPageWithoutBack(context, SignupScreen());
                    },
                    child: Text(
                      'Don\'t have account ? sign up',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          letterSpacing: 1.5),
                    )),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "-OR-",
                style: mediumTextStyle(),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: InkWell(
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.google,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  await signInWithGoogle().then((value) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .set({
                          'userUid': value.user!.uid,
                          'image': value.user!.photoURL,
                          'email': value.user!.email,
                          'name': value.user!.displayName,
                          'bio': "New to instagram",
                          "joinTime": DateTime.now(),
                        })
                        .then((value) => print('User created successfully'))
                        .catchError((error) {
                          CommonWidget.makeSnackBar(
                              title: 'Error',
                              message: error.message,
                              color: Colors.red, context: context);
                        });

                    print(value);
                    print('sign in with google done');
                    navigateToPageWithoutBack(context, HomeNavigationBar());
                  });
                },
              ),
            )
          ],
        ),
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(0, size.height);
    path0.quadraticBezierTo(size.width * 0.1552083, size.height * 0.8969857,
        size.width * 0.2066667, size.height * 0.6842857);
    path0.cubicTo(
        size.width * 0.2913167,
        size.height * 0.4020286,
        size.width * 0.4905833,
        size.height * 0.5733429,
        size.width * 0.5675000,
        size.height * 0.3214286);
    path0.quadraticBezierTo(size.width * 0.6779000, size.height * 0.1204714,
        size.width, size.height * 0.0029286);

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
