import 'package:bloc/bloc.dart';
import 'package:bloc_test/models/profile_model.dart';
import 'package:bloc_test/schema/authentication/auth_schema.dart';
import 'package:bloc_test/services/authentication_service.dart';
import 'package:bloc_test/services/shared_preferences_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(const AuthenticationInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationLoading());
    try {
      final user = await AuthenticateService.signInUser(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        final profileModel = await AuthSchema.getUserProfile(user.id);
        if (profileModel != null) {
          // Save profile to shared preferences
          await SharedPreferencesService.saveProfile(profileModel);
          emit(AuthenticationAuthenticated(profile: profileModel));
        } else {
          emit(const AuthenticationError(
              message: 'Failed to fetch user profile'));
        }
      } else {
        emit(const AuthenticationError(
            message: 'Invalid email or password'));
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationLoading());
    try {
      await AuthenticateService.signUpUserMethod(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      // After sign up, automatically sign in
      final user = await AuthenticateService.signInUser(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        final profileModel = await AuthSchema.getUserProfile(user.id);
        if (profileModel != null) {
          // Save profile to shared preferences
          await SharedPreferencesService.saveProfile(profileModel);
          emit(AuthenticationAuthenticated(profile: profileModel));
        } else {
          emit(const AuthenticationError(
              message: 'Sign up successful but failed to fetch profile'));
        }
      } else {
        emit(const AuthenticationError(
            message: 'Sign up successful but sign in failed'));
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationLoading());
    try {
      final isLoggedIn = await SharedPreferencesService.isLoggedIn();
      if (isLoggedIn) {
        final profile = await SharedPreferencesService.getProfile();
        if (profile != null) {
          // Verify session is still valid with Supabase
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            emit(AuthenticationAuthenticated(profile: profile));
          } else {
            // Session expired, clear local data
            await SharedPreferencesService.clearProfile();
            emit(const AuthenticationUnauthenticated());
          }
        } else {
          emit(const AuthenticationUnauthenticated());
        }
      } else {
        emit(const AuthenticationUnauthenticated());
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationLoading());
    try {
      // Sign out from Supabase
      await Supabase.instance.client.auth.signOut();
      // Clear local storage
      await SharedPreferencesService.clearProfile();
      emit(const AuthenticationUnauthenticated());
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }
}
