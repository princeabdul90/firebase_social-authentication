/*
* Developer: Abubakar Abdullahi
* Date: 25/09/2022
*/

import 'package:authentication/feature/auth/data/auth_repository.dart';
import 'package:authentication/feature/auth/data/firebase/firebase_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseRepositoryProvider extends AuthRepository with ChangeNotifier {

  final firebaseHelper = FirebaseHelper();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider, uid, email, name, imageUrl
  bool get hasError => firebaseHelper.hasError;
  String? get errorCode => firebaseHelper.errorCode;

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

  FirebaseRepositoryProvider() {
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


  @override
  Future<bool> checkUserExist() {
    final result = firebaseHelper.checkUserExist();
    notifyListeners();
    return result;
  }

  @override
  Future getUserDataFromFireStore(uid) {
    final result = firebaseHelper.getUserDataFromFireStore(uid);
    notifyListeners();
    return result;
  }

  @override
  Future getCurrentUserDataFromFireStore() {
    final result = firebaseHelper.getCurrentUserDataFromFireStore();
    notifyListeners();
    return result;
  }

  @override
  Future saveDataToFirestore() {
    final result = firebaseHelper.saveDataToFirestore();
    notifyListeners();
    return result;
  }

  @override
  Future signInWithFacebook() {
    final result = firebaseHelper.signInWithFacebook();
    notifyListeners();
    return result;
  }

  @override
  Future signInWithGoogle() {
    final result = firebaseHelper.signInWithGoogle();
    notifyListeners();
    return result;
  }

  @override
  Future userSignOut() {
    final result = firebaseHelper.userSignOut();
    _isSignedIn = false;
    notifyListeners();
    clearStorageData();
    return result;
  }

  @override
  Future createNewUser() {
    // TODO: implement createNewUser
    throw UnimplementedError();
  }


  //SAVE TO SHARED PREFERENCES
  Future saveDataToSharedPreference() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("uid", firebaseHelper.uid!);
    await sp.setString("name", firebaseHelper.name!);
    await sp.setString("email", firebaseHelper.email!);
    await sp.setString("image_url", firebaseHelper.imageUrl!);
    await sp.setString("provider", firebaseHelper.provider!);
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

  Future clearStorageData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }





}
