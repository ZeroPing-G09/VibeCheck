import 'package:frontend/data/models/user.dart';
import 'package:hive/hive.dart';

/// A helper class for storing and retrieving the current user 
/// locally using Hive
class LocalUserStorage {
  /// Name of the Hive box used for storing user data
  static const _boxName = 'userBox';

  /// Saves the given [user] to local storage
  Future<void> saveUser(User user) async {
    final box = await Hive.openBox<dynamic>(_boxName);
    await box.put('currentUser', user.toJson());
  }

  /// Retrieves the currently saved user from local storage
  /// Returns null if no user is stored
  Future<User?> getUser() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    final json = box.get('currentUser');
    if (json != null) {
      return User.fromJson(Map<String, dynamic>
      .from(json as Map<dynamic, dynamic>));
    }
    return null;
  }

  /// Clears the currently saved user from local storage
  Future<void> clearUser() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    await box.delete('currentUser');
  }
}
