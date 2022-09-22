
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:authentication/feature/auth/presentation/provider/internet_provider.dart';
import 'package:authentication/feature/auth/presentation/provider/sign_in_provider.dart';
import 'package:authentication/feature/auth/presentation/screens/splash_screen.dart';

void main() async {
  // initialize the application
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => SignInProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => InternetProvider(),
        ),
      ],
      child: const MaterialApp(
        title: 'Social Authentication.',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}

