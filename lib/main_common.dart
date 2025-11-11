import 'package:bloc_test/flavour/flavour_config.dart';
import 'package:bloc_test/run_app.dart';
import 'package:flutter/cupertino.dart';

void mainCommon({required Flavour flavour, required String baseUrl, required String name}){
  FlavourConfig(flavour: flavour, baseUrl: baseUrl, name: name);
  runApp(const MyApp());
}
