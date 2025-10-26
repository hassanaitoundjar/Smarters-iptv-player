part of '../screens.dart';

class FullVideoScreen extends StatelessWidget {
  const FullVideoScreen({
    super.key,
    required this.link,
    required this.title,
    this.isLive = false,
    this.resumePosition,
    this.streamId,
    this.imageUrl,
    this.isSeries = false,
    this.subtitles,
  });

  final String link;
  final String title;
  final bool isLive;
  final double? resumePosition;
  final String? streamId;
  final String? imageUrl;
  final bool isSeries;
  final List<Map<String, String>>? subtitles;

  @override
  Widget build(BuildContext context) {
    // Redirect to MediaKitPlayer
    // Note: MediaKit handles subtitles automatically from the stream
    // External subtitles can be added via Media() constructor if needed
    
    final resumeDuration = resumePosition != null ? Duration(seconds: resumePosition!.toInt()) : null;
    
    if (resumeDuration != null) {
      debugPrint('🎥 FullVideoScreen - Resume position: ${resumeDuration.inSeconds}s');
    } else {
      debugPrint('🎥 FullVideoScreen - No resume position (starting from beginning)');
    }
    
    return MediaKitPlayer(
      link: link,
      title: title,
      isLive: isLive,
      resumePosition: resumeDuration,
      streamId: streamId,
      imageUrl: imageUrl,
      isSeries: isSeries,
    );
  }
}
