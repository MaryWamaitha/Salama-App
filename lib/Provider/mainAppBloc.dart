import 'package:flutter_bloc/flutter_bloc.dart';
import 'appBloc.dart';

class MainAppBloc extends Bloc<MainAppEvent, MainAppState> {
  MainAppBloc(MainAppState initialState) : super(initialState) {}
  Stream<MainAppState> mapEventToState(MainAppEvent event) async* {
    if (event is LoadLastUser){
      
    }
  }
}
