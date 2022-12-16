part of 'channels_bloc.dart';

@immutable
abstract class ChannelsState {}

class ChannelsLoading extends ChannelsState {}

class ChannelsSuccess extends ChannelsState {
  final List<ChannelLive> channels;
  ChannelsSuccess(this.channels);
}
