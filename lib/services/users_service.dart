import 'package:bloc_test/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersService {
  static Future<List<ProfileModel>> getAllUsers() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in first.');
      }
      final allProfilesResponse = await Supabase.instance.client
          .from('profiles')
          .select();

      final response = (allProfilesResponse as List)
          .where((profile) =>
      (profile as Map<String, dynamic>)['id'] != currentUser.id)
          .toList();

      if (response.isNotEmpty) {
        final users = response
            .map((user) {
          try {
            final userMap = user as Map<String, dynamic>;
            return ProfileModel.fromMap(userMap);
          } catch (e) {
            return null;
          }
        })
            .whereType<ProfileModel>()
            .toList();
        print('✅ Successfully parsed ${users.length} users');
        return users;
      } else {
        print('⚠️ Response is not a List, type: ${response.runtimeType}');
      }
    }catch (ex){
      print("Exception: $ex");
    }

    print('⚠️ No users found or invalid response');
    return [];

  }

}
