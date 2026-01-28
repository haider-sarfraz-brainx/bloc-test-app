import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticateService{

  Future<void> signUpUserMethod({
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
}