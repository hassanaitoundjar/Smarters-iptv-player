part of 'channels_bloc.dart';

@immutable
abstract class ChannelsEvent {}

class GetLiveChannelsEvent extends ChannelsEvent {
  final String catyId;
  final String action;

  GetLiveChannelsEvent({required this.action, required this.catyId});
}
