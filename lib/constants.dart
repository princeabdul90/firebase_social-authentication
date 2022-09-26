/*
* Developer: Abubakar Abdullahi
* Date: 22/09/2022
*/

class FirebaseConstant {
  static const String users = "users";
}

class AssetsConstant {
  static const appIcon = "assets/loving.png";
  static const loginIcon = "assets/cherry-ontop.png";
}

// get facebook profile url
String getFbProfile(token) {
  return 'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=$token';
}
