import 'package:bloc_test/models/profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../schema/authentication/auth_schema.dart';

class AuthenticateService{

 static Future<void> signUpUserMethod({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      final session = response.session;

      if (user != null) {
        ProfileModel profileModel = ProfileModel(id: user.id,name: name, email: email);
        await AuthSchema.insertUserProfileData(userProfile: profileModel);
        debugPrint('Sign-up successful! User: ${user.email}');
      } else {
        debugPrint('Sign-up completed, but no user returned.');
      }
    } on AuthException catch (error) {
      debugPrint('Supabase auth error: ${error.message}');
    } catch (error) {
      debugPrint('Unexpected error during sign-up: $error');
    }
  }


 static Future<User?> signInUser({
   required String email,
   required String password,
 }) async {
   try {
     final response = await Supabase.instance.client.auth.signInWithPassword(
       email: email,
       password: password,
     );

     final user = response.user;

     if (user != null) {
       print('User signed in: ${user.email}');

       return user;
     } else {
       print('Sign in failed');
       return null;
     }
   } on AuthException catch (e) {
     print('AuthException: ${e.message}');
     return null;
   } catch (e) {
     print('Unexpected error: $e');
     return null;
   }
 }
}