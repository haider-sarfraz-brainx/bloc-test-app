import 'package:bloc_test/bloc/users/users_events.dart';
import 'package:bloc_test/bloc/users/users_states.dart';
import 'package:bloc_test/services/users_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersState.initial()) {
    on<LoadUsers>(_loadUsers);
    on<SearchUsers>(_searchUsers);
    on<RefreshUsers>(_refreshUsers);
  }

  Future<void> _loadUsers(LoadUsers event, Emitter<UsersState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final users = await UsersService.getAllUsers();
      emit(state.copyWith(
        users: users,
        filteredUsers: users,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      print('❌ Error in UsersBloc._loadUsers: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _searchUsers(SearchUsers event, Emitter<UsersState> emit) {
    if (event.query.isEmpty) {
      emit(state.copyWith(filteredUsers: state.users));
      return;
    }

    final query = event.query.toLowerCase();
    final filtered = state.users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();

    emit(state.copyWith(filteredUsers: filtered));
  }

  Future<void> _refreshUsers(
      RefreshUsers event, Emitter<UsersState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final users = await UsersService.getAllUsers();
      emit(state.copyWith(
        users: users,
        filteredUsers: users,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
