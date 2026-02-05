import 'package:bloc_test/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSchema{
  static Future<void> insertUserProfileData({required ProfileModel userProfile}) async {
    await Supabase.instance.client.from('profiles').insert(userProfile.toCreateProfileMap());
  }

  static Future<ProfileModel?> getUserProfile(String userId) async {

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    if (response.isNotEmpty ) {
      return ProfileModel.fromMap(response);
    } else {
      print('Profile fetch error: $response');
      return null;
    }
  }
}