part of 'live_channels_bloc.dart';

@immutable
abstract class LiveChannelsEvent {}

class GetLiveChannelsEvent extends LiveChannelsEvent {
  final String catyId;

  GetLiveChannelsEvent({required this.catyId});
}
