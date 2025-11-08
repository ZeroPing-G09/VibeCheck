import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;
  AuthRepository(this._apiService);

  Future<UserModel> login(String email, String password) async {
    final data = await _apiService.login(email, password);
    return UserModel(id: data['id'], name: data['name'], email: data['email']);
  }
}
