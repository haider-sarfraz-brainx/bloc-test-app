import 'package:bloc_test/helper/supabase.dart';
import 'package:bloc_test/run_app.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await SupabaseHelper.initializeSupabaseConnection();
  runApp(const MyApp());
}


