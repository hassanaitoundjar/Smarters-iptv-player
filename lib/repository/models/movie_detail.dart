class MovieDetail {
  final Info? info;
  final MovieData? movieData;

  MovieDetail({
    this.info,
    this.movieData,
  });

  MovieDetail.fromJson(Map<String, dynamic> json)
      : info = (json['info'] as Map<String, dynamic>?) != null
            ? Info.fromJson(json['info'] as Map<String, dynamic>)
            : null,
        movieData = (json['movie_data'] as Map<String, dynamic>?) != null
            ? MovieData.fromJson(json['movie_data'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() =>
      {'info': info?.toJson(), 'movie_data': movieData?.toJson()};
}

class Info {
  final String? movieImage;
  final String? tmdbId;
  final String? backdrop;
  final String? youtubeTrailer;
  final String? genre;
  final String? plot;
  final String? cast;
  final String? rating;
  final String? director;
  final String? releasedate;
  final List<String>? backdropPath;
  final int? durationSecs;
  final String? duration;
  final Video? video;
  final Audio? audio;
  final int? bitrate;

  Info({
    this.movieImage,
    this.tmdbId,
    this.backdrop,
    this.youtubeTrailer,
    this.genre,
    this.plot,
    this.cast,
    this.rating,
    this.director,
    this.releasedate,
    this.backdropPath,
    this.durationSecs,
    this.duration,
    this.video,
    this.audio,
    this.bitrate,
  });

  Info.fromJson(Map<String, dynamic> json)
      : movieImage = json['movie_image'] as String?,
        tmdbId = json['tmdb_id'] as String?,
        backdrop = json['backdrop'] as String?,
        youtubeTrailer = json['youtube_trailer'] as String?,
        genre = json['genre'] as String?,
        plot = json['plot'] as String?,
        cast = json['cast'] as String?,
        rating = json['rating'] as String?,
        director = json['director'] as String?,
        releasedate = json['releasedate'] as String?,
        backdropPath = json['backdrop_path'] == null
            ? []
            : (json['backdrop_path'] as List?)
                ?.map((dynamic e) => e as String)
                .toList(),
        durationSecs = json['duration_secs'] as int?,
        duration = json['duration'] as String?,
        video = (json['video'] as Map<String, dynamic>?) != null
            ? Video.fromJson(json['video'] as Map<String, dynamic>)
            : null,
        audio = (json['audio'] as Map<String, dynamic>?) != null
            ? Audio.fromJson(json['audio'] as Map<String, dynamic>)
            : null,
        bitrate = json['bitrate'] as int?;

  Map<String, dynamic> toJson() => {
        'movie_image': movieImage,
        'tmdb_id': tmdbId,
        'backdrop': backdrop,
        'youtube_trailer': youtubeTrailer,
        'genre': genre,
        'plot': plot,
        'cast': cast,
        'rating': rating,
        'director': director,
        'releasedate': releasedate,
        'backdrop_path': backdropPath,
        'duration_secs': durationSecs,
        'duration': duration,
        'video': video?.toJson(),
        'audio': audio?.toJson(),
        'bitrate': bitrate
      };
}

class Video {
  final int? index;
  final String? codecName;
  final String? codecLongName;
  final String? profile;
  final String? codecType;
  final String? codecTimeBase;
  final String? codecTagString;
  final String? codecTag;
  final int? width;
  final int? height;
  final int? codedWidth;
  final int? codedHeight;
  final int? hasBFrames;
  final String? sampleAspectRatio;
  final String? displayAspectRatio;
  final String? pixFmt;
  final int? level;
  final String? colorRange;
  final String? colorSpace;
  final String? colorTransfer;
  final String? colorPrimaries;
  final String? chromaLocation;
  final int? refs;
  final String? isAvc;
  final String? nalLengthSize;
  final String? rFrameRate;
  final String? avgFrameRate;
  final String? timeBase;
  final int? startPts;
  final String? startTime;
  final int? durationTs;
  final String? duration;
  final String? bitRate;
  final String? bitsPerRawSample;
  final String? nbFrames;

  final Tags? tags;

  Video({
    this.index,
    this.codecName,
    this.codecLongName,
    this.profile,
    this.codecType,
    this.codecTimeBase,
    this.codecTagString,
    this.codecTag,
    this.width,
    this.height,
    this.codedWidth,
    this.codedHeight,
    this.hasBFrames,
    this.sampleAspectRatio,
    this.displayAspectRatio,
    this.pixFmt,
    this.level,
    this.colorRange,
    this.colorSpace,
    this.colorTransfer,
    this.colorPrimaries,
    this.chromaLocation,
    this.refs,
    this.isAvc,
    this.nalLengthSize,
    this.rFrameRate,
    this.avgFrameRate,
    this.timeBase,
    this.startPts,
    this.startTime,
    this.durationTs,
    this.duration,
    this.bitRate,
    this.bitsPerRawSample,
    this.nbFrames,
    this.tags,
  });

  Video.fromJson(Map<String, dynamic> json)
      : index = json['index'] as int?,
        codecName = json['codec_name'] as String?,
        codecLongName = json['codec_long_name'] as String?,
        profile = json['profile'] as String?,
        codecType = json['codec_type'] as String?,
        codecTimeBase = json['codec_time_base'] as String?,
        codecTagString = json['codec_tag_string'] as String?,
        codecTag = json['codec_tag'] as String?,
        width = json['width'] as int?,
        height = json['height'] as int?,
        codedWidth = json['coded_width'] as int?,
        codedHeight = json['coded_height'] as int?,
        hasBFrames = json['has_b_frames'] as int?,
        sampleAspectRatio = json['sample_aspect_ratio'] as String?,
        displayAspectRatio = json['display_aspect_ratio'] as String?,
        pixFmt = json['pix_fmt'] as String?,
        level = json['level'] as int?,
        colorRange = json['color_range'] as String?,
        colorSpace = json['color_space'] as String?,
        colorTransfer = json['color_transfer'] as String?,
        colorPrimaries = json['color_primaries'] as String?,
        chromaLocation = json['chroma_location'] as String?,
        refs = json['refs'] as int?,
        isAvc = json['is_avc'] as String?,
        nalLengthSize = json['nal_length_size'] as String?,
        rFrameRate = json['r_frame_rate'] as String?,
        avgFrameRate = json['avg_frame_rate'] as String?,
        timeBase = json['time_base'] as String?,
        startPts = json['start_pts'] as int?,
        startTime = json['start_time'] as String?,
        durationTs = json['duration_ts'] as int?,
        duration = json['duration'] as String?,
        bitRate = json['bit_rate'] as String?,
        bitsPerRawSample = json['bits_per_raw_sample'] as String?,
        nbFrames = json['nb_frames'] as String?,
        tags = (json['tags'] as Map<String, dynamic>?) != null
            ? Tags.fromJson(json['tags'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        'index': index,
        'codec_name': codecName,
        'codec_long_name': codecLongName,
        'profile': profile,
        'codec_type': codecType,
        'codec_time_base': codecTimeBase,
        'codec_tag_string': codecTagString,
        'codec_tag': codecTag,
        'width': width,
        'height': height,
        'coded_width': codedWidth,
        'coded_height': codedHeight,
        'has_b_frames': hasBFrames,
        'sample_aspect_ratio': sampleAspectRatio,
        'display_aspect_ratio': displayAspectRatio,
        'pix_fmt': pixFmt,
        'level': level,
        'color_range': colorRange,
        'color_space': colorSpace,
        'color_transfer': colorTransfer,
        'color_primaries': colorPrimaries,
        'chroma_location': chromaLocation,
        'refs': refs,
        'is_avc': isAvc,
        'nal_length_size': nalLengthSize,
        'r_frame_rate': rFrameRate,
        'avg_frame_rate': avgFrameRate,
        'time_base': timeBase,
        'start_pts': startPts,
        'start_time': startTime,
        'duration_ts': durationTs,
        'duration': duration,
        'bit_rate': bitRate,
        'bits_per_raw_sample': bitsPerRawSample,
        'nb_frames': nbFrames,
        'tags': tags?.toJson()
      };
}

class Tags {
  final String? language;
  final String? handlerName;

  Tags({
    this.language,
    this.handlerName,
  });

  Tags.fromJson(Map<String, dynamic> json)
      : language = json['language'] as String?,
        handlerName = json['handler_name'] as String?;

  Map<String, dynamic> toJson() =>
      {'language': language, 'handler_name': handlerName};
}

class Audio {
  final int? index;
  final String? codecName;
  final String? codecLongName;
  final String? profile;
  final String? codecType;
  final String? codecTimeBase;
  final String? codecTagString;
  final String? codecTag;
  final String? sampleFmt;
  final String? sampleRate;
  final int? channels;
  final String? channelLayout;
  final int? bitsPerSample;
  final String? rFrameRate;
  final String? avgFrameRate;
  final String? timeBase;
  final int? startPts;
  final String? startTime;
  final int? durationTs;
  final String? duration;
  final String? bitRate;
  final String? maxBitRate;
  final String? nbFrames;
  final Tags? tags;

  Audio({
    this.index,
    this.codecName,
    this.codecLongName,
    this.profile,
    this.codecType,
    this.codecTimeBase,
    this.codecTagString,
    this.codecTag,
    this.sampleFmt,
    this.sampleRate,
    this.channels,
    this.channelLayout,
    this.bitsPerSample,
    this.rFrameRate,
    this.avgFrameRate,
    this.timeBase,
    this.startPts,
    this.startTime,
    this.durationTs,
    this.duration,
    this.bitRate,
    this.maxBitRate,
    this.nbFrames,
    this.tags,
  });

  Audio.fromJson(Map<String, dynamic> json)
      : index = json['index'] as int?,
        codecName = json['codec_name'] as String?,
        codecLongName = json['codec_long_name'] as String?,
        profile = json['profile'] as String?,
        codecType = json['codec_type'] as String?,
        codecTimeBase = json['codec_time_base'] as String?,
        codecTagString = json['codec_tag_string'] as String?,
        codecTag = json['codec_tag'] as String?,
        sampleFmt = json['sample_fmt'] as String?,
        sampleRate = json['sample_rate'] as String?,
        channels = json['channels'] as int?,
        channelLayout = json['channel_layout'] as String?,
        bitsPerSample = json['bits_per_sample'] as int?,
        rFrameRate = json['r_frame_rate'] as String?,
        avgFrameRate = json['avg_frame_rate'] as String?,
        timeBase = json['time_base'] as String?,
        startPts = json['start_pts'] as int?,
        startTime = json['start_time'] as String?,
        durationTs = json['duration_ts'] as int?,
        duration = json['duration'] as String?,
        bitRate = json['bit_rate'] as String?,
        maxBitRate = json['max_bit_rate'] as String?,
        nbFrames = json['nb_frames'] as String?,
        tags = (json['tags'] as Map<String, dynamic>?) != null
            ? Tags.fromJson(json['tags'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        'index': index,
        'codec_name': codecName,
        'codec_long_name': codecLongName,
        'profile': profile,
        'codec_type': codecType,
        'codec_time_base': codecTimeBase,
        'codec_tag_string': codecTagString,
        'codec_tag': codecTag,
        'sample_fmt': sampleFmt,
        'sample_rate': sampleRate,
        'channels': channels,
        'channel_layout': channelLayout,
        'bits_per_sample': bitsPerSample,
        'r_frame_rate': rFrameRate,
        'avg_frame_rate': avgFrameRate,
        'time_base': timeBase,
        'start_pts': startPts,
        'start_time': startTime,
        'duration_ts': durationTs,
        'duration': duration,
        'bit_rate': bitRate,
        'max_bit_rate': maxBitRate,
        'nb_frames': nbFrames,
        'tags': tags?.toJson()
      };
}

class MovieData {
  final int? streamId;
  final String? name;
  final String? added;
  final String? categoryId;
  final String? containerExtension;
  final String? customSid;
  final String? directSource;

  MovieData({
    this.streamId,
    this.name,
    this.added,
    this.categoryId,
    this.containerExtension,
    this.customSid,
    this.directSource,
  });

  MovieData.fromJson(Map<String, dynamic> json)
      : streamId = json['stream_id'] as int?,
        name = json['name'] as String?,
        added = json['added'] as String?,
        categoryId = json['category_id'] as String?,
        containerExtension = json['container_extension'] as String?,
        customSid = json['custom_sid'] as String?,
        directSource = json['direct_source'] as String?;

  Map<String, dynamic> toJson() => {
        'stream_id': streamId,
        'name': name,
        'added': added,
        'category_id': categoryId,
        'container_extension': containerExtension,
        'custom_sid': customSid,
        'direct_source': directSource
      };
}
