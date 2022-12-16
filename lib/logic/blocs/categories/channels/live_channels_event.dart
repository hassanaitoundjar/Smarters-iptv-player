part of 'live_channels_bloc.dart';

@immutable
abstract class LiveChannelsEvent {}

class GetLiveChannelsEvent extends LiveChannelsEvent {
  final String catyId;
  final String action;

  GetLiveChannelsEvent({required this.action, required this.catyId});
}
