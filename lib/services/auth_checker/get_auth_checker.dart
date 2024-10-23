import 'package:flutter/foundation.dart';
import 'package:web_dex/bloc/auth_bloc/auth_repository.dart';
import 'package:web_dex/services/auth_checker/auth_checker.dart';
import 'package:web_dex/services/auth_checker/mock_auth_checker.dart';
import 'package:web_dex/services/auth_checker/web_auth_checker.dart';

final AuthChecker _authChecker =
    kIsWeb ? WebAuthChecker(authRepo: authRepo) : MockAuthChecker();

AuthChecker getAuthChecker() => _authChecker;
