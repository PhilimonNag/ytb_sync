// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/user.dart';

class UserState extends Equatable {
  final User user;
  final bool active;

  const UserState({required this.user, required this.active});

  UserState copyWith({
    User? user,
    bool? active,
  }) {
    return UserState(
      user: user ?? this.user,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [user, active];
}

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserState(user: User(id: ""), active: false));
  void setUser(User user) {
    emit(state.copyWith(user: user, active: true));
  }
}
