import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/login_screen.dart';
import 'package:firebase_app/widgets/unicorn_button.dart';
import 'package:firebase_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool passwordVisibility = true;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
            body: Form(
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Center(
              child: GradientText(
                style: bigTextStyle(),
                text: 'Welcome to Instagram',
                gradient: LinearGradient(colors: [
                  Colors.orange,
                  Colors.pink,
                ]),
              ),
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
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: TextFormField(
              onSaved: (val) => nameController.text = val!,
              validator: (val) {
                if (val!.isEmpty) return 'Please Enter Your Name';
                if (val.length > 20) return 'Name at most 20 character';
              },
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                prefixIcon: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

              ),
            ),
          ),
          SizedBox(height: height * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: TextFormField(
              keyboardType: TextInputType.visiblePassword,
              onSaved: (val) => passwordController.text = val!,
              validator: (val) {
                if (val!.isEmpty) return 'Please Enter Your Password';
                if (val.length < 6) return 'Password at least 6 characters';
              },
              controller: passwordController,
              obscureText: passwordVisibility == true ? true : false,
              decoration: InputDecoration(
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
                hintText: 'Enter your password',
                prefixIcon:
                    Icon(Icons.lock,color: Colors.black,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim())
                          .then((value) async {
                        CommonWidget.makeSnackBar(
                          context: context,
                          title: 'Sign Up Successful',
                          message: 'Welcome To Instagram',
                        );

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set({
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'joinTime': Timestamp.now(),
                          'userUid': FirebaseAuth.instance.currentUser!.uid,
                          'image':
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTC29mdR0ZLibl0JNBx29bEqJ3oWLZHTLRhzA&usqp=CAU',
                          'bio': 'New to instagram',
                        }).then((value) async {
                          CommonWidget.makeSnackBar(
                              title: 'Sign up done',
                               context: context,
                              message: 'Welcome to Instagram',
                              color: Colors.green);
                        });
                        print(value);
                        navigateToPageWithoutBack(context, HomeNavigationBar());
                      }).catchError((error) {
                        CommonWidget.makeSnackBar( context: context,
                            title: 'Error',
                            message: error.message,
                            color: Colors.red
                        );
                      });
                    }
                  },
                  child: Text('Sign Up'),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Center(
                child: InkWell(
              onTap: () {
                navigateToPageWithoutBack(context, LoginScreen());
              },
              child: Text(
                'Already have account ? Log in',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  letterSpacing: 1.5,
                ),
              ),
            )),
          ),
        ],
      ),
      key: formKey,
    )));
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    nameController.dispose();
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
