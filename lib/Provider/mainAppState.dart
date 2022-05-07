import 'package:equatable/equatable.dart';

abstract class MainAppState extends Equatable {
  const MainAppState();

  @override
  List<Object> get props => [];
}
class LoginInitial extends MainAppState {}

class LoggedOut extends MainAppState {}

// class LoginLastUserLoaded extends MainAppState {
//   final String lastUser;
//   const LoginLastUserLoaded({required this.lastUser});

//   @override
//   List<Object> get props => [lastUser];

//   @override
//   String toString() => 'LoginLastUserLoaded: user: $lastUser';
// }

class LoginInProgress extends MainAppState {}

class LoginSuccess extends MainAppState {}

class SignUpProgress extends MainAppState {}

class SignUpSuccess extends MainAppState {}

// class LoginFailure extends MainAppState {
//   final String errorCode;
//   final String errorDescription;

//   const LoginFailure({required this.errorCode, required this.errorDescription});

//   @override
//   List<Object> get props => [errorCode, errorDescription];

//   @override
//   String toString() =>
//       'MainAppStateFailure: errorCode: $errorCode, errorDescription: $errorDescription';
// }

