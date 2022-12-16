class ChannelLive {
  final int? num;
  final String? name;
  final String? streamType;
  final int? streamId;
  final String? streamIcon;
  final dynamic epgChannelId;
  final String? added;
  final String? isAdult;
  final String? categoryId;
  final String? customSid;
  final int? tvArchive;
  final String? directSource;
  final int? tvArchiveDuration;

  ChannelLive({
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
      : num = json['num'] as int?,
        name = json['name'] as String?,
        streamType = json['stream_type'] as String?,
        streamId = json['stream_id'] as int?,
        streamIcon = json['stream_icon'] as String?,
        epgChannelId = json['epg_channel_id'],
        added = json['added'] as String?,
        isAdult = json['is_adult'] as String?,
        categoryId = json['category_id'] as String?,
        customSid = json['custom_sid'] as String?,
        tvArchive = json['tv_archive'] as int?,
        directSource = json['direct_source'] as String?,
        tvArchiveDuration = json['tv_archive_duration'] as int?;

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
