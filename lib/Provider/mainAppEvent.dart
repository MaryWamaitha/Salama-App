import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class MainAppEvent extends Equatable {
  const MainAppEvent();

  @override
  List<Object> get props => [];
}
class LogOut extends MainAppEvent {}

class LogIn extends MainAppEvent {}

class LoadLastUser extends MainAppEvent {}

class LoginWithPassword extends MainAppEvent {
  final String username;
  final String password;

  LoginWithPassword({ @required this.username, @required this.password});

  @override
  List<Object> get props => [username, password];

  @override
  String toString() => 'LoginWithPassword: '
      'username: $username, password: *****';
}

class Dispose extends MainAppEvent {}
