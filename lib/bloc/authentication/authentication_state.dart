import 'package:bloc_test/models/profile_model.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();
}

class AuthenticationAuthenticated extends AuthenticationState {
  final ProfileModel profile;

  const AuthenticationAuthenticated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class AuthenticationUnauthenticated extends AuthenticationState {
  const AuthenticationUnauthenticated();
}

class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError({required this.message});

  @override
  List<Object?> get props => [message];
}
