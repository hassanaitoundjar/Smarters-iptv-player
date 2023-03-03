class EpgModel {
  final String? id;
  final String? epgId;
  final String? title;
  final String? lang;
  final String? start;
  final String? end;
  final String? description;
  final String? channelId;
  final String? startTimestamp;
  final String? stopTimestamp;

  EpgModel({
    this.id,
    this.epgId,
    this.title,
    this.lang,
    this.start,
    this.end,
    this.description,
    this.channelId,
    this.startTimestamp,
    this.stopTimestamp,
  });

  EpgModel.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        epgId = json['epg_id'].toString(),
        title = json['title'].toString(),
        lang = json['lang'].toString(),
        start = json['start'].toString(),
        end = json['end'].toString(),
        description = json['description'].toString(),
        channelId = json['channel_id'].toString(),
        startTimestamp = json['start_timestamp'].toString(),
        stopTimestamp = json['stop_timestamp'].toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'epg_id': epgId,
        'title': title,
        'lang': lang,
        'start': start,
        'end': end,
        'description': description,
        'channel_id': channelId,
        'start_timestamp': startTimestamp,
        'stop_timestamp': stopTimestamp
      };
}
