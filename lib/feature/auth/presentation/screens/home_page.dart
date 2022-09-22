/*
* Developer: Abubakar Abdullahi
* Date: 20/09/2022
*/

import 'package:authentication/feature/auth/presentation/provider/sign_in_provider.dart';
import 'package:authentication/feature/auth/presentation/screens/login_screen.dart';
import 'package:authentication/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataToSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();

    return Scaffold(
      body: Center(
        child: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage("${sp.imageUrl}"),
              radius: 50,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome ${sp.name}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              '${sp.email}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              '${sp.uid}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("PROVIDER"),
                const SizedBox(width: 5),
                Text(
                  '${sp.provider}'.toUpperCase(),
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: (){
                  sp.userSignOut();
                  nextScreenReplace(context, const LoginScreen());
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
            )
          ],
        )),
      ),
    );
  }
}
