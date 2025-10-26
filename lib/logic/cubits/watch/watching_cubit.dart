import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repository/api/api.dart';

import '../../../repository/models/watching.dart';

part 'watching_state.dart';

class WatchingCubit extends Cubit<WatchingState> {
  final WatchingLocale favoriteLocale;
  WatchingCubit(this.favoriteLocale) : super(WatchingState.defaultData());

  void initialData() async {
    emit(WatchingState(
      movies: await favoriteLocale.getWatchingMovies(),
      series: await favoriteLocale.getWatchingSeries(),
      live: await favoriteLocale.getWatchingLives(),
    ));
  }

  void addMovie(WatchingModel movie) async {
    final List<WatchingModel> editList = state.movies
        .where((element) => element.streamId != movie.streamId)
        .toList();
    editList.insert(0, movie);

    await favoriteLocale.saveWatchingMovie(editList);
    emit(WatchingState(
      movies: editList,
      series: state.series,
      live: state.live,
    ));
  }

  void addSerie(WatchingModel serie) async {
    final List<WatchingModel> editList = state.series
        .where((element) => element.streamId != serie.streamId)
        .toList();
    editList.insert(0, serie);

    await favoriteLocale.saveWatchSerie(editList);
    emit(WatchingState(
      movies: state.movies,
      series: editList,
      live: state.live,
    ));
  }

  void addLive(WatchingModel live) async {
    final List<WatchingModel> editList = state.live
        .where((element) => element.streamId != live.streamId)
        .toList();
    editList.insert(0, live);
    await favoriteLocale.saveWatchLive(editList);
    emit(WatchingState(
      movies: state.movies,
      series: state.series,
      live: editList,
    ));
  }

  void clearData() async {
    await favoriteLocale.deleteWatching();
    emit(WatchingState.defaultData());
  }

  void clearAllMovies() async {
    await favoriteLocale.saveWatchingMovie([]);
    emit(WatchingState(
      movies: [],
      series: state.series,
      live: state.live,
    ));
  }

  void clearAllSeries() async {
    await favoriteLocale.saveWatchSerie([]);
    emit(WatchingState(
      movies: state.movies,
      series: [],
      live: state.live,
    ));
  }
}
