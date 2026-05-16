import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _status == AuthStatus.unknown;

  Future<void> init() async {
    await _api.loadToken();
    try {
      _user = await _api.getMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? educationLevel,
  }) async {
    _error = null;
    try {
      final data = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        educationLevel: educationLevel,
      );
      await _api.saveToken(data['access_token']);
      _user = User.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _error = null;
    try {
      final data = await _api.login(email: email, password: password);
      await _api.saveToken(data['access_token']);
      _user = User.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> setupProfile({
    required String targetJob,
    required String contractType,
    required String region,
  }) async {
    _error = null;
    try {
      _user = await _api.setupProfile(
        targetJob: targetJob,
        contractType: contractType,
        region: region,
      );
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Impossible de contacter le serveur.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
