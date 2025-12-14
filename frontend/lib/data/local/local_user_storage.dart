import 'package:hive/hive.dart';
import 'package:frontend/data/models/user.dart';

class LocalUserStorage {
  static const _boxName = 'userBox';

  Future<void> saveUser(User user) async {
    final box = await Hive.openBox(_boxName);
    await box.put('currentUser', user.toJson());
  }

  Future<User?> getUser() async {
    final box = await Hive.openBox(_boxName);
    final json = box.get('currentUser');
    if (json != null) {
      return User.fromJson(Map<String, dynamic>.from(json as Map<dynamic, dynamic>));
    }
    return null;
  }

  Future<void> clearUser() async {
    final box = await Hive.openBox(_boxName);
    await box.delete('currentUser');
  }
}
