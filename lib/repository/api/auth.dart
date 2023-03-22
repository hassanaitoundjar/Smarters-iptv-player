part of 'api.dart';

class AuthApi {
  Future<UserModel?> registerUser(
    String username,
    String password,
    String link,
    String name,
  ) async {
    try {
      Response<String> response = await _dio
          .get("$link/player_api.php?username=$username&password=$password");

      if (response.statusCode == 200) {
        var json = jsonDecode(response.data ?? "");
        final user = UserModel.fromJson(json, link);
        //save to locale
        await LocaleApi.saveUser(user);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }
}
