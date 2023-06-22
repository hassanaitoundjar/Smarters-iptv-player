class ChannelMovie {
  final String? num;
  final String? name;
  final String? streamType;
  final String? streamId;
  final String? streamIcon;
  final String? rating;
  final String? rating5based;
  final String? added;
  final String? isAdult;
  final String? categoryId;
  final String? containerExtension;
  final String? customSid;
  final String? directSource;

  ChannelMovie({
    this.num,
    this.name,
    this.streamType,
    this.streamId,
    this.streamIcon,
    this.rating,
    this.rating5based,
    this.added,
    this.isAdult,
    this.categoryId,
    this.containerExtension,
    this.customSid,
    this.directSource,
  });

  ChannelMovie.fromJson(Map<String, dynamic> json)
      : num = json['num'] as String?,
        name = json['name'].toString(),
        streamType = json['stream_type'].toString(),
        streamId = json['stream_id'] as String?,
        streamIcon = json['stream_icon'].toString(),
        rating = json['rating'].toString(),
        rating5based = json['rating_5based'] as String?,
        added = json['added'].toString(),
        isAdult = json['is_adult'].toString(),
        categoryId = json['category_id'].toString(),
        containerExtension = json['container_extension'].toString(),
        customSid = json['custom_sid'].toString(),
        directSource = json['direct_source'].toString();

  Map<String, dynamic> toJson() => {
        'num': num,
        'name': name,
        'stream_type': streamType,
        'stream_id': streamId,
        'stream_icon': streamIcon,
        'rating': rating,
        'rating_5based': rating5based,
        'added': added,
        'is_adult': isAdult,
        'category_id': categoryId,
        'container_extension': containerExtension,
        'custom_sid': customSid,
        'direct_source': directSource
      };
}
