import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthGateStatus {
  initializing,
  unauthenticated,
  authenticatedNoFamily,
  authenticatedInFamily,
  authenticating,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _bind();
  }

  final AuthService _authService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _userDocSub;

  User? _firebaseUser;
  AppUser? _appUser;

  AuthGateStatus _status = AuthGateStatus.initializing;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  AuthGateStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _status == AuthGateStatus.authenticatedNoFamily || _status == AuthGateStatus.authenticatedInFamily;
  bool get hasFamily => _status == AuthGateStatus.authenticatedInFamily;

  void _bind() {
    _authSub = _authService.authStateChanges.listen((user) {
      _firebaseUser = user;
      _appUser = null;
      _errorMessage = null;

      _userDocSub?.cancel();
      _userDocSub = null;

      if (user == null) {
        _status = AuthGateStatus.unauthenticated;
        notifyListeners();
        return;
      }

      // Logado: agora ouvimos o doc do usuário no Firestore
      _status = AuthGateStatus.initializing;
      notifyListeners();

      _userDocSub = _authService.userDocStream(user.uid).listen(
        (appUser) {
          _appUser = appUser;

          final fam = appUser?.currentFamilyId;
          if (fam != null && fam.trim().isNotEmpty) {
            _status = AuthGateStatus.authenticatedInFamily;
          } else {
            _status = AuthGateStatus.authenticatedNoFamily;
          }
          notifyListeners();
        },
        onError: (e) {
          _status = AuthGateStatus.error;
          _errorMessage = 'Erro ao carregar seu perfil. Verifique sua internet e permissões.';
          notifyListeners();
        },
      );
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = AuthGateStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      await _authService.signIn(email.trim(), password);

      // O listener do authStateChanges assumirá daqui
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthGateStatus.unauthenticated;
      _errorMessage = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _status = AuthGateStatus.unauthenticated;
      _errorMessage = 'Erro ao autenticar. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _status = AuthGateStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUp(email.trim(), password, name.trim());

      // O listener assume
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthGateStatus.unauthenticated;
      _errorMessage = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _status = AuthGateStatus.unauthenticated;
      _errorMessage = 'Erro ao criar conta. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthGateStatus.unauthenticated;
    _appUser = null;
    _firebaseUser = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'E-mail não cadastrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'A senha precisa ter 6+ caracteres.';
      default:
        return 'Erro ao autenticar. Tente novamente.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
