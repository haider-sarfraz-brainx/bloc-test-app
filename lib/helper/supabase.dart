import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper{

 static Future<void> initializeSupabaseConnection() async {
    await Supabase.initialize(
      url: 'https://hwxngnfsoxkbyezzdxrm.supabase.co',
      anonKey: 'sb_publishable_I2B4A5nin2gNFpvI4nclgw_N1-VbHNg',
    );
  }

}