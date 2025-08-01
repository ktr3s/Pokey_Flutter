import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokey_music/repository/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../utils/token_storage.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository repository;

  LoginBloc(this.repository) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final user = await repository.login(event.email, event.password);
        await TokenStorage.saveToken(user.accessToken);
        emit(LoginSuccess(user.accessToken));
      } catch (e) {
        emit(LoginFailure('Credenciales incorrectas'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await TokenStorage.clearToken();
      emit(LoginInitial());
    });
  }
}
