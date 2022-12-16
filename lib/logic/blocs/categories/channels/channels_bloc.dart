import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../repository/api/api.dart';
import '../../../../repository/models/channelLive.dart';

part 'channels_event.dart';
part 'channels_state.dart';

class ChannelsBloc extends Bloc<ChannelsEvent, ChannelsState> {
  final IpTvApi api;
  ChannelsBloc(this.api) : super(ChannelsLoading()) {
    on<GetLiveChannelsEvent>((event, emit) async {
      emit(ChannelsLoading());

      final result = await api.getLiveChannels(event.catyId, event.action);
      emit(ChannelsSuccess(result));
    });
  }
}
