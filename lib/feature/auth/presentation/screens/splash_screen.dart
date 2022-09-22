/*
* Developer: Abubakar Abdullahi
* Date: 21/09/2022
*/

import 'dart:async';

import 'package:authentication/feature/auth/presentation/provider/sign_in_provider.dart';
import 'package:authentication/feature/auth/presentation/screens/home_page.dart';
import 'package:authentication/feature/auth/presentation/screens/login_screen.dart';
import 'package:authentication/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/next_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //init state
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();
    Timer(const Duration(seconds: 2), () {
      sp.isSignedIn == false
          ? nextScreenReplace(context, const LoginScreen())
          : nextScreenReplace(context, const HomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Image(
            image: AssetImage(Config.appIcon),
            height: 100,
            width: 100,
          ),
        ),
      ),
    );
  }
}
