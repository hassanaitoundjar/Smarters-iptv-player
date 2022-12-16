part of 'live_channels_bloc.dart';

@immutable
abstract class LiveChannelsState {}

class LiveChannelsLoading extends LiveChannelsState {}

class LiveChannelsSuccess extends LiveChannelsState {
  final List<ChannelLive> channels;
  LiveChannelsSuccess(this.channels);
}
