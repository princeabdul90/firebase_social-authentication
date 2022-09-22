/*
* Developer: Abubakar Abdullahi
* Date: 22/09/2022
*/

import 'package:flutter/material.dart';

void nextScreen(context, page){
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page){
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
}