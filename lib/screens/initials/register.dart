import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/initials/home.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  bool secureText = true;
  AuthServcies _authServcies = AuthServcies();
  ProgressDialog pr;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      textDirection: TextDirection.ltr,
      isDismissible: false,
      customBody: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        width: 100,
        height: 100,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 10,
            ),
            child: Column(
              children: <Widget>[
                SpinKitPouringHourglass(color: Pallete.mainAppColor),
                Text("Creating your account...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(129, 165, 168, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
      ),
      showLogs: false,
    );
  }

  done() async {
    if (username.text.trim() != "") {
      if (email.text.trim() != "") {
        if (password.text.trim() != "") {
          if (RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(email.text.trim())) {
            if (password.text.length > 6) {
              try {
                pr.show();
                String usernameS = username.text.trim();

                QuerySnapshot snapUser =
                    await _authServcies.usernameCheckSe(usernameS);
                QuerySnapshot snapEmail =
                    await _authServcies.emailCheckSe(email.text.trim());

                if (snapEmail.documents.isEmpty) {
                  if (snapUser.documents.isEmpty) {
                    AuthResult result =
                        await _authServcies.createUserWithEmailAndPasswordSe(
                            email.text.trim(), password.text.trim());
                    await _authServcies.createUserInDatabaseSe(result.user.uid,
                        username.text.trim(), email.text.trim());

                    _firebaseMessaging.getToken().then((token) {
                      print("Firebase Messaging Token: $token\n");
                      _authServcies.createMessagingToken(
                          token, result.user.uid);
                    });

                    pr.hide().whenComplete(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    });
                  } else {
                    pr.hide();
                    GradientSnackBar.showMessage(
                        context, "Username already used!");
                  }
                } else {
                  pr.hide();
                  GradientSnackBar.showMessage(
                      context, "Email address already used!");
                }
              } catch (e) {
                if (e.code == "ERROR_WEAK_PASSWORD") {
                  pr.hide();
                  GradientSnackBar.showMessage(context,
                      "Weak password, password should be at least 6 characters!");
                }
              }
            } else {
              GradientSnackBar.showMessage(context,
                  "Weak password, password should be at least 6 characters long!");
            }
          } else {
            GradientSnackBar.showMessage(
                context, "Please provide valid email!");
          }
        } else {
          GradientSnackBar.showMessage(context, "Password is required!");
        }
      } else {
        GradientSnackBar.showMessage(context, "Email is required!");
      }
    } else {
      GradientSnackBar.showMessage(context, "Username is required!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                  child: Text(
                    'Signup',
                    style:
                        TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(260.0, 125.0, 0.0, 0.0),
                  child: Text(
                    '.',
                    style: TextStyle(
                        fontSize: 80.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                )
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      labelStyle:
                          TextStyle(fontSize: 15, color: Colors.grey.shade500),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Pallete.mainAppColor,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    obscureText: secureText,
                    controller: password,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle:
                          TextStyle(fontSize: 15, color: Colors.grey.shade500),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            if (secureText) {
                              setState(() {
                                secureText = false;
                              });
                            } else {
                              setState(() {
                                secureText = true;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              secureText
                                  ? 'assets/icons/eye_open.png'
                                  : 'assets/icons/eye_close.png',
                              width: 20,
                              height: 20,
                              color: Colors.grey.shade500,
                            ),
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Pallete.mainAppColor,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: username,
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle:
                          TextStyle(fontSize: 15, color: Colors.grey.shade500),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Pallete.mainAppColor,
                          )),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () async {
                      done();
                    },
                    child: Container(
                        height: 50.0,
                        child: Material(
                          borderRadius: BorderRadius.circular(3.0),
                          shadowColor: Colors.greenAccent,
                          color: Colors.green,
                          elevation: 1.0,
                          child: GestureDetector(
                            onTap: () async {
                              done();
                            },
                            child: Center(
                              child: Text(
                                'SIGNUP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        )),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    height: 50.0,
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black,
                              style: BorderStyle.solid,
                              width: 1.0),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(3.0)),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text('Go Back',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat')),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          // SizedBox(height: 15.0),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     Text(
          //       'New to Spotify?',
          //       style: TextStyle(
          //         fontFamily: 'Montserrat',
          //       ),
          //     ),
          //     SizedBox(width: 5.0),
          //     InkWell(
          //       child: Text('Register',
          //           style: TextStyle(
          //               color: Colors.green,
          //               fontFamily: 'Montserrat',
          //               fontWeight: FontWeight.bold,
          //               decoration: TextDecoration.underline)),
          //     )
          //   ],
          // )
        ]));
  }
}
