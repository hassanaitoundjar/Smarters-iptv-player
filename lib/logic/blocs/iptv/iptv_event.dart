part of 'iptv_bloc.dart';

@immutable
abstract class IptvEvent {}

class IptvDecodeContent extends IptvEvent {}

class IptvGetContentEvent extends IptvEvent {}
