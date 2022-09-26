/*
* Developer: Abubakar Abdullahi
* Date: 25/09/2022
*/

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../domain/user.dart';

class FirebaseHelper {
  // instance of firebaseAuth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseHelper();

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

// get facebook profile url
  String getFbProfile(token) {
    return 'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=$token';
  }

  Future<String> getCurrentUid() async => firebaseAuth.currentUser!.uid;


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
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            _errorCode =
                "You already have account with us, Use correct provider.";
            _hasError = true;
            break;

          case 'null':
            _errorCode =
                "Some unexpected error encountered wny trying the sign in.";
            _hasError = true;
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
        }
      }
    } else {
      _hasError = true;
    }
  }

  Future signInWithFacebook() async {
    final LoginResult result = await facebookAuth.login();
    // getting the profile
    var fbToken = result.accessToken!.token;
    final graphResponse = await http.get(Uri.parse(getFbProfile(fbToken)));
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
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            _errorCode =
                "You already have account with us, Use correct provider.";
            _hasError = true;
            break;

          case 'null':
            _errorCode =
                "Some unexpected error encountered while trying the sign in.";
            _hasError = true;
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
        }
      }
    } else {
      _hasError = true;
    }
  }

  Future<bool> checkUserExist() async {
    final uid = await getCurrentUid();

    DocumentSnapshot snapshot =
        await firestore.collection(FirebaseConstant.users).doc(uid).get();
    if (snapshot.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  Future userSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  Future getUserDataFromFireStore(uid) async {
    await firestore
        .collection(FirebaseConstant.users)
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
          toFirestore: (userModel, _) => userModel.toJson(),
        )
        .doc(uid)
        .get();
  }

  Future getCurrentUserDataFromFireStore() async {
    final uid = await getCurrentUid();
    await firestore
        .collection(FirebaseConstant.users)
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
          toFirestore: (userModel, _) => userModel.toJson(),
        )
        .doc(uid)
        .get();
  }

  Future saveDataToFirestore() async {
    final uid = await getCurrentUid();
    final DocumentReference reference =
        firestore.collection(FirebaseConstant.users).doc(uid);

    final newCustomer = UserModel(
      uid: _uid,
      name: _name,
      email: _email,
      imageUrl: _imageUrl,
      provider: _provider,
    ).toJson();

    await reference.set(newCustomer);
  }

  Future<void> createNewUser(UserModel user) async {
    final collection = firestore.collection(FirebaseConstant.users);

    final cid = await getCurrentUid();

    collection.doc(cid).get().then((customerDoc) {
      final newCustomer = UserModel(
        uid: user.uid,
        name: user.name,
        email: user.email,
        imageUrl: user.imageUrl,
        provider: user.provider,
      ).toJson();

      if (!customerDoc.exists) {
        collection.doc(cid).set(newCustomer);
      } else {
        collection.doc(cid).update(newCustomer);
      }
    }).catchError((error) {
      _errorCode = 'Some Error Occurred!';
      _hasError = true;
    });
  }
}

