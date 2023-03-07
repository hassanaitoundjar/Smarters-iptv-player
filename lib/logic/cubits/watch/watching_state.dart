part of 'watching_cubit.dart';

/*@immutable
abstract class WatchingState {}*/

class WatchingState {
  final List<WatchingModel> movies;
  final List<WatchingModel> series;
  final List<WatchingModel> live;

  WatchingState({
    required this.movies,
    required this.series,
    required this.live,
  });

  factory WatchingState.defaultData() {
    return WatchingState(
      movies: const [],
      live: const [],
      series: const [],
    );
  }
}
