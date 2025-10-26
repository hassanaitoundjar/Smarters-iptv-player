import 'package:flutter/foundation.dart';

class ChannelLive {
  final String? num;
  final String? name;
  final String? streamType;
  final String? streamId;
  final String? streamIcon;
  final dynamic epgChannelId;
  final String? added;
  final String? isAdult;
  final String? categoryId;
  final String? customSid;
  final String? tvArchive;
  final String? directSource;
  final String? tvArchiveDuration;

  const ChannelLive({
    this.num,
    this.name,
    this.streamType,
    this.streamId,
    this.streamIcon,
    this.epgChannelId,
    this.added,
    this.isAdult,
    this.categoryId,
    this.customSid,
    this.tvArchive,
    this.directSource,
    this.tvArchiveDuration,
  });

  ChannelLive.fromJson(Map<String, dynamic> json)
      : num = json['num']?.toString(),
        name = json['name']?.toString(),
        streamType = json['stream_type']?.toString(),
        streamId = json['stream_id']?.toString(),
        streamIcon = json['stream_icon'] != null && json['stream_icon'].toString().isNotEmpty
            ? json['stream_icon'].toString()
            : null,
        epgChannelId = json['epg_channel_id'],
        added = json['added']?.toString(),
        isAdult = json['is_adult']?.toString(),
        categoryId = json['category_id']?.toString(),
        customSid = json['custom_sid']?.toString(),
        tvArchive = json['tv_archive']?.toString(),
        directSource = json['direct_source']?.toString(),
        tvArchiveDuration = json['tv_archive_duration']?.toString() {
    // Debug logging
    if (streamIcon != null && streamIcon!.isNotEmpty) {
      debugPrint('Channel: $name - Icon: $streamIcon');
    }
  }

  Map<String, dynamic> toJson() => {
        'num': num,
        'name': name,
        'stream_type': streamType,
        'stream_id': streamId,
        'stream_icon': streamIcon,
        'epg_channel_id': epgChannelId,
        'added': added,
        'is_adult': isAdult,
        'category_id': categoryId,
        'custom_sid': customSid,
        'tv_archive': tvArchive,
        'direct_source': directSource,
        'tv_archive_duration': tvArchiveDuration
      };
}
