class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    return {'id': '123', 'name': 'John Doe', 'email': email};
  }
}
