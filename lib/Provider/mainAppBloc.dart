import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'appBloc.dart';
import "package:salama/Services/firebase_service.dart";

class MainAppBloc extends Bloc<MainAppEvent, MainAppState> {
  final _firebaseAuth = FirebaseAuth.instance;
  final service = Services();
  MainAppBloc() : super(LoginInitial()) {
    // add(LoadLastUser());
    on<LoadLastUser>((event, emit) async {
      emit(LoginInProgress());
      if (_firebaseAuth.currentUser != null) {
        emit(LoginSuccess());
      } else {
        emit(LoggedOut());
      }
    });
    on<LoginWithPassword>((event, emit) async {
      emit(LoginInProgress());

      try {
        String msg = await service.signIn(
            email: event.username, password: event.password);
        if (msg == 'Signed In') {
          emit(LoginSuccess());
        } else {
          emit(LoginFailure(
              errorCode: "123456", errorDescription: "errorDescription"));
        }
      } catch (e) {
        emit(LoginFailure(errorCode: e.code, errorDescription: e.message));
      }
    });
  }

  // Stream<MainAppState> mapEventToState(MainAppEvent event) async* {
  //   if (event is LoadLastUser) {
  //     yield LoginInProgress();
  //     if (_firebaseAuth.currentUser != null) {
  //       yield LoginSuccess();
  //     } else {
  //       yield LoggedOut();
  //     }
  //   }
  //   if (event is LoginWithPassword) {
  //     yield LoginInProgress();

  //     try {
  //       String msg = await service.signIn(
  //           email: event.username, password: event.password);
  //       if (msg == 'Signed In') {
  //         yield LoginSuccess();
  //       } else {
  //         yield LoginFailure(
  //             errorCode: "123456", errorDescription: "errorDescription");
  //       }
  //     } catch (e) {
  //       yield LoginFailure(errorCode: e.code, errorDescription: e.message);
  //     }
  //   }
  // }

}
