part of '../api/api.dart';

class LocaleApi {
  static Future<bool> saveUser(UserModel user) async {
    try {
      await locale.write("user", user.toJson());
      
      // Also save to user list
      await addUserToList(user);
      return true;
    } catch (e) {
      debugPrint("Error save User: $e");
      return false;
    }
  }

  static Future<UserModel?> getUser() async {
    try {
      final user = await locale.read("user");

      if (user != null) {
        return UserModel.fromJson(user, user['server_info']['server_url']);
      }
      return null;
    } catch (e) {
      debugPrint("Error save User: $e");
      return null;
    }
  }

  static Future<bool> logOut() async {
    try {
      await locale.remove("user");

      return true;
    } catch (e) {
      debugPrint("Error LogOut User: $e");
      return false;
    }
  }

  // ========== User List Management ==========
  
  /// Get list of all saved users
  static Future<List<UserModel>> getUserList() async {
    try {
      final userList = await locale.read("user_list");
      
      if (userList != null && userList is List) {
        return userList.map((userJson) {
          return UserModel.fromJson(
            userJson as Map<String, dynamic>,
            userJson['server_info']['server_url'],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error getting user list: $e");
      return [];
    }
  }

  /// Add user to the saved user list (or update if exists)
  static Future<bool> addUserToList(UserModel user) async {
    try {
      List<UserModel> userList = await getUserList();
      
      // Remove existing user with same username and domain if exists
      userList.removeWhere((u) => 
        u.userInfo?.username == user.userInfo?.username &&
        u.serverInfo?.serverUrl == user.serverInfo?.serverUrl
      );
      
      // Add the new/updated user
      userList.add(user);
      
      // Save the updated list
      final userListJson = userList.map((u) => u.toJson()).toList();
      await locale.write("user_list", userListJson);
      
      return true;
    } catch (e) {
      debugPrint("Error adding user to list: $e");
      return false;
    }
  }

  /// Switch to a different user account
  static Future<bool> switchUser(UserModel user) async {
    try {
      await locale.write("user", user.toJson());
      return true;
    } catch (e) {
      debugPrint("Error switching user: $e");
      return false;
    }
  }

  /// Remove a user from the saved list
  static Future<bool> removeUserFromList(UserModel user) async {
    try {
      List<UserModel> userList = await getUserList();
      
      userList.removeWhere((u) => 
        u.userInfo?.username == user.userInfo?.username &&
        u.serverInfo?.serverUrl == user.serverInfo?.serverUrl
      );
      
      final userListJson = userList.map((u) => u.toJson()).toList();
      await locale.write("user_list", userListJson);
      
      return true;
    } catch (e) {
      debugPrint("Error removing user from list: $e");
      return false;
    }
  }

  // ========== Content Counts Cache ==========
  
  /// Save total movies count
  static Future<bool> saveTotalMoviesCount(int count) async {
    try {
      await locale.write("total_movies_count", count);
      return true;
    } catch (e) {
      debugPrint("Error saving total movies count: $e");
      return false;
    }
  }

  /// Get total movies count
  static Future<int?> getTotalMoviesCount() async {
    try {
      final count = await locale.read("total_movies_count");
      return count as int?;
    } catch (e) {
      debugPrint("Error getting total movies count: $e");
      return null;
    }
  }

  /// Save total series count
  static Future<bool> saveTotalSeriesCount(int count) async {
    try {
      await locale.write("total_series_count", count);
      return true;
    } catch (e) {
      debugPrint("Error saving total series count: $e");
      return false;
    }
  }

  /// Get total series count
  static Future<int?> getTotalSeriesCount() async {
    try {
      final count = await locale.read("total_series_count");
      return count as int?;
    } catch (e) {
      debugPrint("Error getting total series count: $e");
      return null;
    }
  }
}
