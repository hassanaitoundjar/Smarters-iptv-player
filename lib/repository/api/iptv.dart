part of 'api.dart';

class IpTvApi {
  /// Categories
  Future<List<CategoryModel>> getCategories(String type) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        debugPrint("User is Null");
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": type,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.data ?? "[]");

        final list = json.map((e) => CategoryModel.fromJson(e)).toList();
        //TODO: save list to locale

        return list;
      }

      return [];
    } catch (e) {
      debugPrint("Error $type: $e");
      return [];
    }
  }

  /// Channels Live
  Future<List<ChannelLive>> getLiveChannels(String catyId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        debugPrint("User is Null");
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_live_streams",
          "category_id": catyId
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.data ?? "[]");

        final list = json.map((e) => ChannelLive.fromJson(e)).toList();
        //TODO: save list to locale

        return list;
      }

      return [];
    } catch (e) {
      debugPrint("Error Channel $catyId: $e");
      return [];
    }
  }

  /// Channels Live
  Future<List<ChannelMovie>> getMovieChannels(String catyId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        debugPrint("User is Null");
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_vod_streams",
          "category_id": catyId
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.data ?? "[]");

        final list = json.map((e) => ChannelMovie.fromJson(e)).toList();
        //TODO: save list to locale

        return list;
      }

      return [];
    } catch (e) {
      debugPrint("Error Channel $catyId: $e");
      return [];
    }
  }
}
