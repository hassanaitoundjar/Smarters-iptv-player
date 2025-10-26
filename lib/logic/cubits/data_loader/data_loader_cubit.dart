import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:evoflix/repository/models/progress_step.dart';
import 'package:evoflix/repository/api/api.dart';

part 'data_loader_state.dart';

class DataLoaderCubit extends Cubit<DataLoaderState> {
  final IpTvApi iptvApi;

  DataLoaderCubit(this.iptvApi) : super(DataLoaderInitial());

  Future<bool> loadAllData() async {
    try {
      // Step 1: User Info (already authenticated)
      emit(DataLoaderLoading(ProgressStep.userInfo));
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Categories - Validate connection
      emit(DataLoaderLoading(ProgressStep.categories));
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Load Live Categories
      emit(DataLoaderLoading(ProgressStep.liveChannels));
      try {
        final liveCategories =
            await iptvApi.getCategories('get_live_categories');
        if (liveCategories.isEmpty) {
          emit(const DataLoaderError(
            'Failed to load live categories. Please check your server URL and credentials.',
            'preparing_live_streams_exception_1',
            ProgressStep.liveChannels,
          ));
          return false;
        }
      } catch (e) {
        emit(DataLoaderError(
          'Error loading live categories: ${e.toString()}',
          'preparing_live_streams_exception_2',
          ProgressStep.liveChannels,
        ));
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Load Movie Categories
      emit(DataLoaderLoading(ProgressStep.movies));
      try {
        final movieCategories =
            await iptvApi.getCategories('get_vod_categories');
        if (movieCategories.isEmpty) {
          emit(const DataLoaderError(
            'Failed to load movie categories. Please check your server URL and credentials.',
            'preparing_movies_exception_1',
            ProgressStep.movies,
          ));
          return false;
        }
      } catch (e) {
        emit(DataLoaderError(
          'Error loading movie categories: ${e.toString()}',
          'preparing_movies_exception_2',
          ProgressStep.movies,
        ));
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: Load Series Categories
      emit(DataLoaderLoading(ProgressStep.series));
      try {
        final seriesCategories =
            await iptvApi.getCategories('get_series_categories');
        if (seriesCategories.isEmpty) {
          emit(const DataLoaderError(
            'Failed to load series categories. Please check your server URL and credentials.',
            'preparing_series_exception_1',
            ProgressStep.series,
          ));
          return false;
        }
      } catch (e) {
        emit(DataLoaderError(
          'Error loading series categories: ${e.toString()}',
          'preparing_series_exception_2',
          ProgressStep.series,
        ));
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 500));

      // ============================================================
      // OPTIONAL: Download ALL channels/movies/series for offline use
      // Uncomment the code below if you want to pre-download everything
      // WARNING: This will take much longer (several minutes)
      // ============================================================

      // // Download ALL Live Channels
      // emit(DataLoaderLoading(ProgressStep.liveChannels));
      // try {
      //   final liveCategories = await iptvApi.getCategories('get_live_categories');
      //   for (var category in liveCategories) {
      //     await iptvApi.getLiveChannels(category.categoryId ?? '');
      //   }
      // } catch (e) {
      //   emit(DataLoaderError(
      //     'Error downloading live channels: ${e.toString()}',
      //     'preparing_live_streams_exception_2',
      //     ProgressStep.liveChannels,
      //   ));
      //   return false;
      // }

      // // Download ALL Movies
      // emit(DataLoaderLoading(ProgressStep.movies));
      // try {
      //   final movieCategories = await iptvApi.getCategories('get_vod_categories');
      //   for (var category in movieCategories) {
      //     await iptvApi.getMovieChannels(category.categoryId ?? '');
      //   }
      // } catch (e) {
      //   emit(DataLoaderError(
      //     'Error downloading movies: ${e.toString()}',
      //     'preparing_movies_exception_2',
      //     ProgressStep.movies,
      //   ));
      //   return false;
      // }

      // // Download ALL Series
      // emit(DataLoaderLoading(ProgressStep.series));
      // try {
      //   final seriesCategories = await iptvApi.getCategories('get_series_categories');
      //   for (var category in seriesCategories) {
      //     await iptvApi.getSeriesChannels(category.categoryId ?? '');
      //   }
      // } catch (e) {
      //   emit(DataLoaderError(
      //     'Error downloading series: ${e.toString()}',
      //     'preparing_series_exception_2',
      //     ProgressStep.series,
      //   ));
      //   return false;
      // }

      emit(DataLoaderSuccess());
      return true;
    } catch (e) {
      emit(DataLoaderError(
        'Connection error: ${e.toString()}',
        null,
        ProgressStep.userInfo,
      ));
      return false;
    }
  }
}
