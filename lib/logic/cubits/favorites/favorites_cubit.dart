import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repository/api/api.dart';
import '../../../repository/models/channel_live.dart';
import '../../../repository/models/channel_movie.dart';
import '../../../repository/models/channel_serie.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoriteLocale favoriteLocale;
  FavoritesCubit(this.favoriteLocale) : super(FavoritesState.defaultData());

  void initialData() async {
    emit(FavoritesState(
      series: await favoriteLocale.getFavSeries(),
      movies: await favoriteLocale.getFavMovies(),
      lives: await favoriteLocale.getFavLives(),
    ));
  }

  void addMovie(ChannelMovie? value, {required bool isAdd}) async {
    final oldList = state.movies;
    List<ChannelMovie> newList = List.of(oldList);

    if (isAdd) {
      newList.insert(0, value!);
    } else {
      newList =
          oldList.where((movie) => movie.streamId != value!.streamId).toList();
    }

    await favoriteLocale.saveFavoriteMovie(newList);

    emit(FavoritesState(
      movies: newList,
      lives: state.lives,
      series: state.series,
    ));
  }

  void addSerie(ChannelSerie? value, {required bool isAdd}) async {
    final oldList = state.series;
    List<ChannelSerie> newList = List.of(oldList);

    if (isAdd) {
      newList.insert(0, value!);
    } else {
      newList =
          oldList.where((serie) => serie.seriesId != value!.seriesId).toList();
    }

    await favoriteLocale.saveFavoriteSerie(newList);
    emit(FavoritesState(
      series: newList,
      movies: state.movies,
      lives: state.lives,
    ));
  }

  void addLive(ChannelLive? value, {required bool isAdd}) async {
    final oldList = state.lives;
    List<ChannelLive> newList = List.of(oldList);

    if (isAdd) {
      newList.insert(0, value!);
    } else {
      newList =
          oldList.where((live) => live.streamId != value!.streamId).toList();
    }

    await favoriteLocale.saveFavoriteLives(newList);
    emit(FavoritesState(
      lives: newList,
      series: state.series,
      movies: state.movies,
    ));
  }
}
