import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
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

      debugPrint("register user");
      final user = await authApi.registerUser(
        "PPMHVZ1UXR",
        "5WLFXT3KXT",
        "http://line.ottcst.com:80/player_api.php",
        "test",
      );

      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailed("could not login!!"));
      }
    });

    on<AuthGetUser>((event, emit) async {
      emit(AuthLoading());

      final localeUser = await LocaleApi.getUser();

      if (localeUser != null) {
        emit(AuthSuccess(localeUser));
      } else {
        emit(AuthFailed("could not login!!"));
      }
    });
  }
}
