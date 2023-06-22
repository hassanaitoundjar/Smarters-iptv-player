class WatchingModel {
  final String streamId;
  final String image;
  final String title;

  double sliderValue;
  final double durationStrm;
  final String stream;

  WatchingModel({
    required this.streamId,
    required this.image,
    required this.title,
    required this.stream,
    required this.sliderValue,
    required this.durationStrm,
  });

  factory WatchingModel.fromJson(Map<String, dynamic> json) {
    return WatchingModel(
      streamId: json["streamId"],
      image: json["image"],
      title: json["title"],
      sliderValue: double.parse(json["sliderValue"].toString()),
      stream: json["stream"],
      durationStrm: double.parse(json['durationStrm'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "streamId": streamId,
      "image": image,
      "title": title,
      "sliderValue": sliderValue,
      "stream": stream,
      'durationStrm': durationStrm,
    };
  }

//
}
