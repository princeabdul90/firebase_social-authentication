/*
* Developer: Abubakar Abdullahi
* Date: 26/09/2022
*/
import 'package:authentication/feature/auth/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:authentication/feature/auth/presentation/provider/internet_provider.dart';
import 'package:authentication/feature/auth/presentation/screens/login_screen.dart';
import 'package:authentication/utils/next_screen.dart';
import 'package:authentication/utils/snackbar.dart';

import '../../../../constants.dart';
import '../provider/firebase_repository_provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //controller -> name, email, phone, otp code
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpCodeController = TextEditingController();

  String name = '';
  String email = '';
  String mobile = '';
  String otp = '';

  void getLatestValue() {
    name = nameController.text;
    email = emailController.text;
    mobile = mobileController.text.trim();
    otp = otpCodeController.text.trim();
  }

  @override
  void initState() {
    nameController.addListener(getLatestValue);
    emailController.addListener(getLatestValue);
    mobileController.addListener(getLatestValue);
    otpCodeController.addListener(getLatestValue);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    otpCodeController.dispose();
    super.dispose();
  }

  void clear() {
    mobileController.clear();
    nameController.clear();
    emailController.clear();
    otpCodeController.clear();
  }

  Future handleLogin(BuildContext context) async {
    final sp = context.read<FirebaseRepositoryProvider>();
    final ip = context.read<InternetProvider>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check your internet connection", Colors.red);
      clear();
    } else {
      if (formKey.currentState!.validate()) {

         await sp.signInWithPhone(mobile, context, otpCodeController, () async {

          // save the values
           await sp.saveMobileUser(otp, name, email);

          // check whether the user exist or not.
          sp.checkUserExist().then((value) async {
            if (value == true) {
              // user exist
              await sp.getUserDataFromFireStore(sp.uid).then((value) => sp
                  .saveDataToSharedPreference()
                  .then((value) => sp.setSignIn().then((value) {
                       handleAfterSignIn();
                      })));
              clear();
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp
                  .saveDataToSharedPreference()
                  .then((value) => sp.setSignIn().then((value) {
                        handleAfterSignIn();
                      })));

              clear();
            }
          });
        });
      }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            nextScreenReplace(context, const LoginScreen());
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Image(
                  image: AssetImage(AssetsConstant.loginIcon),
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Phone Login",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name can not be empty';
                    } else {
                      return null;
                    }
                  },
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.account_circle),
                    hintText: 'Enoph Nigol',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email can not be empty';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    hintText: 'enophnigol@gmail.com',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: mobileController,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Phone Number can not be empty';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android_rounded),
                    hintText: '+1-987-654-321',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    handleLogin(context);
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  child: const Text('Register'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
