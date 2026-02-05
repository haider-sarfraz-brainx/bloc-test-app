import 'package:equatable/equatable.dart';
import '../../models/profile_model.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UsersEvent {
  const LoadUsers();
}

class SearchUsers extends UsersEvent {
  final String query;
  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class RefreshUsers extends UsersEvent {
  const RefreshUsers();
}
