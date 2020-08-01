import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/initials/home.dart';
import 'package:nearby/screens/initials/register.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool secureText = true;
  AuthServcies _authServcies = AuthServcies();
  ProgressDialog pr;

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
                SpinKitCircle(color: Pallete.mainAppColor),
                Text("checking provided credintials...",
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
    if (email.text.trim() != "") {
      if (password.text.trim() != "") {
        if (RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email.text.trim())) {
          pr.show();
          try {
            AuthResult _authenticatedUser =
                await _authServcies.signInWithEmailAndPasswordSe(
                    email.text.trim(), password.text.trim());
            if (_authenticatedUser.user.uid != null) {
              pr.hide().whenComplete(() {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Home()));
              });
            } else {
              pr.hide();
              GradientSnackBar.showMessage(context, "Sorry! no account found!");
            }
          } catch (e) {
            switch (e.code) {
              case "ERROR_INVALID_EMAIL":
                pr.hide();
                GradientSnackBar.showMessage(context,
                    "Sorry! Your email address appears to be malformed!");
                break;
              case "ERROR_WRONG_PASSWORD":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! Your password is wrong!");
                break;
              case "ERROR_USER_NOT_FOUND":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! User with this email doesn't exist!");
                break;
              case "ERROR_USER_DISABLED":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! User with this email has been disabled!");
                break;
              case "ERROR_TOO_MANY_REQUESTS":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! no account found!");
                break;
              case "ERROR_OPERATION_NOT_ALLOWED":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! no account found!");
                break;
              default:
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! no account found!");
            }
          }
        } else {
          GradientSnackBar.showMessage(context, "Please provide valid email!");
        }
      } else {
        GradientSnackBar.showMessage(context, "Password is required!");
      }
    } else {
      GradientSnackBar.showMessage(context, "Email is required!");
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        exit(0);
        return false;
      },
      child: Scaffold(
          body: SingleChildScrollView(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                                child: Text('Hello',
                                    style: TextStyle(
                                        fontSize: 80.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding:
                                    EdgeInsets.fromLTRB(16.0, 175.0, 0.0, 0.0),
                                child: Text('There',
                                    style: TextStyle(
                                        fontSize: 80.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding:
                                    EdgeInsets.fromLTRB(220.0, 175.0, 0.0, 0.0),
                                child: Text('.',
                                    style: TextStyle(
                                        fontSize: 80.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                              )
                            ],
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(
                                top: 35.0, left: 20.0, right: 20.0),
                            child: Column(children: <Widget>[
                              Column(
                                children: <Widget>[
                                  TextField(
                                    controller: email,
                                    decoration: InputDecoration(
                                      labelText: "Email Address",
                                      labelStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade500),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
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
                                      labelStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade500),
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
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          borderSide: BorderSide(
                                            color: Pallete.mainAppColor,
                                          )),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    alignment: Alignment(1.0, 0.0),
                                    padding:
                                        EdgeInsets.only(top: 15.0, left: 20.0),
                                    child: InkWell(
                                      child: Text(
                                        'Forgot Password',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 40.0),
                                  GestureDetector(
                                    onTap: () async {
                                      done();
                                    },
                                    child: Container(
                                      height: 50.0,
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                        shadowColor: Colors.greenAccent,
                                        color: Colors.green,
                                        elevation: 1.0,
                                        child: GestureDetector(
                                          onTap: () async {
                                            done();
                                          },
                                          child: Center(
                                            child: Text(
                                              'LOGIN',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Montserrat'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'New to here ?',
                                        style:
                                            TextStyle(fontFamily: 'Montserrat'),
                                      ),
                                      SizedBox(width: 5.0),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Register()));
                                        },
                                        child: Text(
                                          'Register',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ]))
                      ])))),
    );
  }
}
