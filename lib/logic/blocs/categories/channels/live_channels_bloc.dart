import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../repository/api/api.dart';
import '../../../../repository/models/channelLive.dart';

part 'live_channels_event.dart';
part 'live_channels_state.dart';

class LiveChannelsBloc extends Bloc<LiveChannelsEvent, LiveChannelsState> {
  final IpTvApi api;
  LiveChannelsBloc(this.api) : super(LiveChannelsLoading()) {
    on<GetLiveChannelsEvent>((event, emit) async {
      emit(LiveChannelsLoading());

      final result = await api.getLiveChannels(event.catyId, event.action);
      emit(LiveChannelsSuccess(result));
    });
  }
}
