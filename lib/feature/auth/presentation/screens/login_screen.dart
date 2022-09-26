/*
* Developer: Abubakar Abdullahi
* Date: 21/09/2022
*/

import 'package:authentication/constants.dart';
import 'package:authentication/feature/auth/presentation/provider/internet_provider.dart';
import 'package:authentication/feature/auth/presentation/provider/sign_in_provider.dart';
import 'package:authentication/feature/auth/presentation/screens/home_page.dart';
import 'package:authentication/utils/next_screen.dart';
import 'package:authentication/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../provider/firebase_repository_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldkey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();

  // google sign-in
  Future handleGoogleSignIn() async {
    //final sp = context.read<SignInProvider>();
    final sp = context.read<FirebaseRepositoryProvider>();
    final ip = context.read<InternetProvider>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check your Internet Connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) {
        if (sp.hasError == true) {
          openSnackBar(context, sp.errorCode.toString(), Colors.red);
          googleController.reset();
        } else {
          // check whether the user exist or not.
          sp.checkUserExist().then((value) async {
            if (value == true) {
              // user exist
              await sp.getUserDataFromFireStore(sp.uid).then((value) => sp.saveDataToSharedPreference().then((value) => sp.setSignIn().then((value) {
                googleController.success();
                handleAfterSignIn();
              })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp
                  .saveDataToSharedPreference()
                  .then((value) => sp.setSignIn().then((value) {
                        googleController.success();
                        handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }

  // facebook sign-in
  Future handleFacebookSignIn() async {

    final sp = context.read<FirebaseRepositoryProvider>();
    final ip = context.read<InternetProvider>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check your Internet Connection", Colors.red);
      facebookController.reset();
    } else {
      await sp.signInWithFacebook().then((value) {
        if (sp.hasError == true) {
          openSnackBar(context, sp.errorCode.toString(), Colors.red);
          facebookController.reset();
        } else {
          // check whether the user exist or not.
          sp.checkUserExist().then((value) async {
            if (value == true) {
              // user exist
              await sp.getUserDataFromFireStore(sp.uid).then((value) => sp.saveDataToSharedPreference().then((value) => sp.setSignIn().then((value) {
                facebookController.success();
                handleAfterSignIn();
              })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp
                  .saveDataToSharedPreference()
                  .then((value) => sp.setSignIn().then((value) {
                facebookController.success();
                handleAfterSignIn();
              })));
            }
          });
        }
      });
    }
  }

  // Handle after sign-in
  handleAfterSignIn() async {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
    nextScreen(context, const HomePage());
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Image(
                      image: AssetImage(AssetsConstant.loginIcon),
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Firebase Firestore',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Authentication with provider',
                      style:
                          TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedLoadingButton(
                    width: MediaQuery.of(context).size.width * 0.80,
                    controller: googleController,
                    onPressed: () {
                      handleGoogleSignIn();
                    },
                    color: Colors.redAccent,
                    successColor: Colors.redAccent,
                    elevation: 0.0,
                    borderRadius: 25,
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.google,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Sign in with Google',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  RoundedLoadingButton(
                    width: MediaQuery.of(context).size.width * 0.80,
                    controller: facebookController,
                    onPressed: () {
                      handleFacebookSignIn();
                    },
                    color: Colors.blueAccent,
                    successColor: Colors.blueAccent,
                    elevation: 0.0,
                    borderRadius: 25,
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.facebookF,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Sign in with Facebook',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
