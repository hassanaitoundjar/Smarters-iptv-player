part of 'widgets.dart';

class DialogTrailerYoutube extends StatefulWidget {
  const DialogTrailerYoutube({super.key, required this.trailer, this.thumb});
  final String trailer;
  final String? thumb;

  @override
  State<DialogTrailerYoutube> createState() => _DialogTrailerYoutubeState();
}

class _DialogTrailerYoutubeState extends State<DialogTrailerYoutube> {
  late final Player player;
  late final video.VideoController controller;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = video.VideoController(player);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // MediaKit supports YouTube URLs directly
      final youtubeUrl = 'https://youtu.be/${widget.trailer}';
      await player.open(Media(youtubeUrl), play: false);
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading YouTube trailer: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: Ink(
        decoration: kDecorBackground,
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video Player
            SizedBox(
              height: 300,
              child: isLoading
                  ? Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : hasError
                      ? Container(
                          color: Colors.black,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load trailer',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                      : video.Video(
                          controller: controller,
                          controls: video.AdaptiveVideoControls,
                        ),
            ),
            const SizedBox(height: 10),
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CardButtonWatchMovie(
                  isFocused: true,
                  title: "Close",
                  onTap: () => Get.back(),
                ),
                if (!hasError) ...[
                  const SizedBox(width: 15),
                  StreamBuilder<bool>(
                    stream: player.stream.playing,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      return CardButtonWatchMovie(
                        title: isPlaying ? "Pause" : "Play",
                        onTap: () {
                          if (isPlaying) {
                            player.pause();
                          } else {
                            player.play();
                          }
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
