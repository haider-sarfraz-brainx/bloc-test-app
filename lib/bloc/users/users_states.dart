import 'package:equatable/equatable.dart';
import '../../models/profile_model.dart';

class UsersState extends Equatable {
  final List<ProfileModel> users;
  final List<ProfileModel> filteredUsers;
  final bool isLoading;
  final String? error;

  const UsersState({
    required this.users,
    required this.filteredUsers,
    required this.isLoading,
    this.error,
  });

  factory UsersState.initial() {
    return const UsersState(
      users: [],
      filteredUsers: [],
      isLoading: false,
      error: null,
    );
  }

  UsersState copyWith({
    List<ProfileModel>? users,
    List<ProfileModel>? filteredUsers,
    bool? isLoading,
    String? error,
  }) {
    return UsersState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [users, filteredUsers, isLoading, error];
}
