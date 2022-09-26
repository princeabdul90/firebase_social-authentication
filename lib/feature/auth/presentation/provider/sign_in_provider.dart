/*
* Developer: Abubakar Abdullahi
* Date: 21/09/2022
*/

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInProvider extends ChangeNotifier {
  // instance of firebaseAuth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider, uid, email, name, imageUrl
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _name;
  String? get name => _name;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("signed_in", true);
    notifyListeners();
  }

  // sign in with google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // executing authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        // signing to firebase user instance
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        // saving all the values
        _uid = userDetails.uid;
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _provider = 'GOOGLE';
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            _errorCode =
                "You already have account with us, Use correct provider.";
            _hasError = true;
            notifyListeners();
            break;

          case 'null':
            _errorCode =
                "Some unexpected error encountered while trying the sign in.";
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // sign in with facebook
  Future signInWithFacebook() async {
    final LoginResult result = await facebookAuth.login();
    // getting the profile
    var fbToken = result.accessToken!.token;
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=$fbToken'));
    final profile = jsonDecode(graphResponse.body);

    if (result.status == LoginStatus.success) {
      try {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(fbToken);
        await firebaseAuth.signInWithCredential(credential);

        //saving the value
        _name = profile['name'];
        _email = profile['email'];
        _imageUrl = profile['picture']['data']['url'];
        _provider = 'FACEBOOK';
        _uid = profile['id'];
        _hasError = false;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            _errorCode =
                "You already have account with us, Use correct provider.";
            _hasError = true;
            notifyListeners();
            break;

          case 'null':
            _errorCode =
                "Some unexpected error encountered while trying the sign in.";
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  //GET DATA FROM CLOUDFIRESTORE
  Future getUserDataFromFireStore(uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              _uid = snapshot['uid'],
              _name = snapshot['name'],
              _email = snapshot['email'],
              _imageUrl = snapshot['image_url'],
              _provider = snapshot['provider'],
            });
  }

  //SAVE TO CLOUDFIRESTORE
  Future saveDataToFirestore() async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('users').doc(uid);
    await reference.set({
      "name": _name,
      "email": _email,
      "image_url": _imageUrl,
      "provider": _provider,
      "uid": _uid,
    });
    notifyListeners();
  }

  //SAVE TO SHARED PREFERENCES
  Future saveDataToSharedPreference() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("uid", _uid!);
    await sp.setString("name", _name!);
    await sp.setString("email", _email!);
    await sp.setString("image_url", _imageUrl!);
    await sp.setString("provider", _provider!);
    notifyListeners();
  }

  //GET DATA FROM SHARED PREFERENCES
  Future getDataToSharedPreference() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _uid = sp.getString("uid");
    _name = sp.getString("name");
    _email = sp.getString("email");
    _imageUrl = sp.getString("image_url");
    _provider = sp.getString("provider");
    notifyListeners();
  }

  // check if user exist or not in firestore
  Future<bool> checkUserExist() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snapshot.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // Sign Out
  Future userSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    _isSignedIn = false;
    notifyListeners();
    // clear all storage information
    clearStorageData();
  }

  Future clearStorageData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }
}
