part of 'iptv_bloc.dart';

@immutable
abstract class IptvState {}

class IptvLoading extends IptvState {}

class IptvSuccess extends IptvState {
  final List listM3u;

  IptvSuccess(this.listM3u);
}

class IptvFailed extends IptvState {}
