/*
* Developer: Abubakar Abdullahi
* Date: 22/09/2022
*/


abstract class AuthRepository {
  Future signInWithGoogle();
  Future signInWithFacebook();
  Future<bool> checkUserExist();

  Future createNewUser();
  Future saveDataToFirestore();
  Future getCurrentUserDataFromFireStore();
  Future getUserDataFromFireStore(uid);

  Future userSignOut();

}