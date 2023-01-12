import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mbark_iptv/repository/api/api.dart';
import 'package:mbark_iptv/repository/models/user.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApi authApi;

  AuthBloc(this.authApi) : super(AuthInitial()) {
    on<AuthRegister>((event, emit) async {
      emit(AuthLoading());

      /*   final user = await authApi.registerUser(
        event.username,
        event.password,
        event.domain,
        "test",
      );*/

      final user = await authApi.registerUser(
        "137d8e0a0c",
        "eaf35bc652",
        "http://line.ottcdn.net:80",
        "test",
      );

      if (user != null) {
        changeDeviceOrient();
        await Future.delayed(const Duration(seconds: 1));
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailed("could not login!!"));
      }
    });

    on<AuthGetUser>((event, emit) async {
      emit(AuthLoading());

      final localeUser = await LocaleApi.getUser();

      if (localeUser != null) {
        changeDeviceOrient();
        emit(AuthSuccess(localeUser));
      } else {
        emit(AuthFailed("could not login!!"));
      }
    });

    on<AuthLogOut>((event, emit) async {
      await LocaleApi.logOut();
      changeDeviceOrientBack();
      emit(AuthFailed("LogOut"));
    });
  }

  void changeDeviceOrient() {
    //change portrait mobile
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void changeDeviceOrientBack() {
    //change portrait mobile
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }
}
