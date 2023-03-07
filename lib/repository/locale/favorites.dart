part of '../api/api.dart';

class FavoriteLocale {
  Future<bool> saveFavoriteMovie(List<ChannelMovie> movies) async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return false;
      }

      var name = "${user.userInfo!.username}-fav-movies";
      await favoritesLocale.write(
        name,
        movies.map((mov) => jsonEncode(mov.toJson())).toList().toString(),
      );

      return true;
    } catch (e) {
      debugPrint("Error: Fav Movie: $e");
      return true;
    }
  }

  Future<bool> saveFavoriteSerie(List<ChannelSerie> series) async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return false;
      }

      var name = "${user.userInfo!.username}-fav-series";
      await favoritesLocale.write(
        name,
        series.map((mov) => jsonEncode(mov.toJson())).toList().toString(),
      );

      return true;
    } catch (e) {
      debugPrint("Error: Fav Series: $e");
      return true;
    }
  }

  Future<List<ChannelMovie>> getFavMovies() async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return [];
      }

      var name = "${user.userInfo!.username}-fav-movies";
      final data = await favoritesLocale.read(name);

      if (data != null) {
        final List<dynamic> json = jsonDecode(data);

        return json.map((e) => ChannelMovie.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("Error: GetFav Movie: $e");
      return [];
    }
  }

  Future<List<ChannelSerie>> getFavSeries() async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return [];
      }

      var name = "${user.userInfo!.username}-fav-series";
      final data = await favoritesLocale.read(name);

      if (data != null) {
        final List<dynamic> json = jsonDecode(data);

        return json.map((e) => ChannelSerie.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("Error: GetFav Series: $e");
      return [];
    }
  }

  Future<List<ChannelLive>> getFavLives() async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return [];
      }

      var name = "${user.userInfo!.username}-fav-lives";
      final data = await favoritesLocale.read(name);

      if (data != null) {
        final List<dynamic> json = jsonDecode(data);

        return json.map((e) => ChannelLive.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("Error: GetFav Lives: $e");
      return [];
    }
  }

  Future<bool> saveFavoriteLives(List<ChannelLive> series) async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return false;
      }

      var name = "${user.userInfo!.username}-fav-lives";
      await favoritesLocale.write(
        name,
        series.map((mov) => jsonEncode(mov.toJson())).toList().toString(),
      );

      return true;
    } catch (e) {
      debugPrint("Error: Fav Lives: $e");
      return true;
    }
  }
}

class WatchingLocale {
  Future<bool> saveWatchingMovie(List<WatchingModel> movies) async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return false;
      }

      var name = "${user.userInfo!.username}-watch-movies";
      await favoritesLocale.write(
        name,
        movies.map((mov) => jsonEncode(mov.toJson())).toList().toString(),
      );

      return true;
    } catch (e) {
      debugPrint("Error: watch Movie: $e");
      return true;
    }
  }

  Future<bool> saveWatchSerie(List<WatchingModel> series) async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return false;
      }

      var name = "${user.userInfo!.username}-watch-series";
      await favoritesLocale.write(
        name,
        series.map((mov) => jsonEncode(mov.toJson())).toList().toString(),
      );

      return true;
    } catch (e) {
      debugPrint("Error: watch Series: $e");
      return true;
    }
  }

  Future<bool> saveWatchLive(List<WatchingModel> series) async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return false;
      }

      var name = "${user.userInfo!.username}-watch-live";
      await favoritesLocale.write(
        name,
        series.map((mov) => jsonEncode(mov.toJson())).toList().toString(),
      );

      return true;
    } catch (e) {
      debugPrint("Error: watch Live: $e");
      return true;
    }
  }

  Future<List<WatchingModel>> getWatchingMovies() async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return [];
      }

      var name = "${user.userInfo!.username}-watch-movies";
      final data = await favoritesLocale.read(name);

      if (data != null) {
        final List<dynamic> json = jsonDecode(data);

        return json.map((e) => WatchingModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("Error: Getwatch Movie: $e");
      return [];
    }
  }

  Future<List<WatchingModel>> getWatchingSeries() async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return [];
      }

      var name = "${user.userInfo!.username}-watch-series";
      final data = await favoritesLocale.read(name);

      if (data != null) {
        final List<dynamic> json = jsonDecode(data);

        return json.map((e) => WatchingModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("Error: Getwatch Series: $e");
      return [];
    }
  }

  Future<List<WatchingModel>> getWatchingLives() async {
    try {
      final user = await LocaleApi.getUser();
      if (user == null) {
        return [];
      }

      var name = "${user.userInfo!.username}-watch-live";
      final data = await favoritesLocale.read(name);

      if (data != null) {
        final List<dynamic> json = jsonDecode(data);

        return json.map((e) => WatchingModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("Error: Getwatch Live: $e");
      return [];
    }
  }

  Future<void> deleteWatching() async {
    final user = await LocaleApi.getUser();
    if (user == null) {
      return;
    }
    var live = "${user.userInfo!.username}-watch-live";
    var series = "${user.userInfo!.username}-watch-series";
    var movies = "${user.userInfo!.username}-watch-movies";
    await favoritesLocale.remove(live);
    await favoritesLocale.remove(series);
    await favoritesLocale.remove(movies);
  }
}
