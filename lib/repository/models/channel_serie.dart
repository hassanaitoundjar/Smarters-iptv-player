class ChannelSerie {
  final String? num;
  final String? name;
  final String? seriesId;
  final String? cover;
  final String? plot;

  final String? rating;
  final String? rating5based;

  final String? categoryId;

  ChannelSerie({
    this.num,
    this.name,
    this.seriesId,
    this.cover,
    this.plot,
    this.rating,
    this.rating5based,
    this.categoryId,
  });

  ChannelSerie.fromJson(Map<String, dynamic> json)
      : num = json['num'].toString(),
        name = json['name'].toString(),
        seriesId = json['series_id'].toString(),
        cover = json['cover'].toString(),
        plot = json['plot'].toString(),
        rating = json['rating'].toString(),
        rating5based = json['rating_5based'].toString(),
        categoryId = json['category_id'].toString();

  Map<String, dynamic> toJson() => {
        'num': num,
        'name': name,
        'series_id': seriesId,
        'cover': cover,
        'plot': plot,
        'rating': rating,
        'rating_5based': rating5based,
        'category_id': categoryId
      };
}
