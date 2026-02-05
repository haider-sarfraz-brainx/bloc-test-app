import 'dart:convert';
import 'package:bloc_test/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _profileKey = 'user_profile';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save profile model
  static Future<bool> saveProfile(ProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toMap());
      await prefs.setString(_profileKey, profileJson);
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    } catch (e) {
      print('Error saving profile: $e');
      return false;
    }
  }

  // Get profile model
  static Future<ProfileModel?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      if (profileJson != null) {
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        return ProfileModel.fromMap(profileMap);
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Clear profile and logout
  static Future<bool> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      await prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      print('Error clearing profile: $e');
      return false;
    }
  }
}
