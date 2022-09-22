/*
* Developer: Abubakar Abdullahi
* Date: 22/09/2022
*/

import 'package:authentication/feature/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseAuthRepositoryImplementation extends AuthRepository {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

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


  @override
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
            idToken: googleSignInAuthentication.idToken
        );

        // signing to firebase user instance
        final User userDetails =  (await firebaseAuth.signInWithCredential(credential)).user!;

        // saving all the values
        _uid = userDetails.uid;
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _provider = 'GOOGLE';

      } on FirebaseAuthException catch(e) {
        switch(e.code){
          case 'account-exists-with-different-credential':
            _errorCode = "You already have account with us, Use correct provider.";
            _hasError = true;
            break;

          case 'null':
            _errorCode = "Some unexpected error encountered wny trying the sign in.";
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


  @override
  Future signInWithFacebook() {
    // TODO: implement signInWithFacebook
    throw UnimplementedError();
  }
}