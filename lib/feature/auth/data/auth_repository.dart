/*
* Developer: Abubakar Abdullahi
* Date: 22/09/2022
*/


abstract class AuthRepository {
  Future signInWithGoogle();
  Future signInWithFacebook();
  Future signInWithPhone(mobile,context, controller, onPressed);
  Future<bool> checkUserExist();


  Future saveDataToFirestore();
  Future getCurrentUserDataFromFireStore();
  Future getUserDataFromFireStore(uid);

  Future userSignOut();

}