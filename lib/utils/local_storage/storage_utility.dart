import 'package:get_storage/get_storage.dart';

class TLocalStorage {
  static final TLocalStorage _instance = TLocalStorage._internal();

  factory TLocalStorage() {
    return _instance;
  }

  TLocalStorage._internal();

  static final _storage = GetStorage();

  // Generic method to save data
  static Future<void> saveData<T>({
    required String key,
    required T value,
  }) async {
    await _storage.write(key, value);
  }

  // Generic method to read data
  static T? readData<T>(String key) {
    return _storage.read<T>(key);
  }

  // Generic method to remove data
  static Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  // Clear all data in storage
  static Future<void> clearAll() async {
    await _storage.erase();
  }
}


/// *** *** *** *** *** Example *** *** *** *** *** ///

// LocalStorage localStorage = LocalStorage();
//
// // Save data
// localStorage.saveData('username', 'JohnDoe');
//
// // Read data
// String? username = localStorage.readData<String>('username');
// print('Username: $username'); // Output: Username: JohnDoe
//
// // Remove data
// localStorage.removeData('username');
//
// // Clear all data
// localStorage.clearAll();

