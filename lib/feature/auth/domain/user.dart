/*
* Developer: Abubakar Abdullahi
* Date: 25/09/2022
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String? uid;
  final String? name;
  final String? email;
  final String? imageUrl;
  final String? provider;

  const UserModel({
    this.uid,
    this.email,
    this.name,
    this.imageUrl,
    this.provider,
  });

  @override
  List<Object?> get props => [uid, email, name, imageUrl, provider];


  // convert json data from firestore to usermodel
  factory UserModel.fromJson(Map<String, Object?> json) => UserModel(
    uid: json['uid']! as String,
    name: json['name']! as String,
    email: json['email']! as String,
    imageUrl: json['imageUrl']! as String,
    provider: json['provider']! as String,
  );


  Map<String, Object?> toJson() => {
    "uid": uid,
    "name": name,
    "email": email,
    "imageUrl": imageUrl,
    "provider": provider,
  };


}
