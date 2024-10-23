import 'package:equatable/equatable.dart';
import 'package:web_dex/model/authorize_mode.dart';

class AuthBlocState extends Equatable {
  const AuthBlocState({required this.mode});

  factory AuthBlocState.initial() =>
      const AuthBlocState(mode: AuthorizeMode.noLogin);
  final AuthorizeMode mode;
  @override
  List<Object> get props => [mode];
}
