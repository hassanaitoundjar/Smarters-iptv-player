part of '../screens.dart';

class MediaKitPlayer extends StatefulWidget {
  final String link;
  final String title;
  final bool isLive;
  final Duration? resumePosition;
  final String? streamId;
  final String? imageUrl;
  final bool isSeries;

  const MediaKitPlayer({
    super.key,
    required this.link,
    required this.title,
    this.isLive = false,
    this.resumePosition,
    this.streamId,
    this.imageUrl,
    this.isSeries = false,
  });

  @override
  State<MediaKitPlayer> createState() => _MediaKitPlayerState();
}

class _MediaKitPlayerState extends State<MediaKitPlayer> {
  late final Player player;
  late final video.VideoController controller;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  // Track information
  List<VideoTrack> videoTracks = [];
  List<AudioTrack> audioTracks = [];
  List<SubtitleTrack> subtitleTracks = [];

  VideoTrack selectedVideoTrack = VideoTrack.auto();
  AudioTrack selectedAudioTrack = AudioTrack.auto();
  SubtitleTrack selectedSubtitleTrack = SubtitleTrack.no();

  // Auto-retry configuration
  int _retryCount = 0;
  final int _maxRetries = 2;
  final Duration _retryDelay = const Duration(seconds: 2);
  Timer? _retryTimer;

  // Continue watching
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    // Use default configuration (software decoding fallback is automatic)
    player = Player();
    controller = video.VideoController(player);
    _setupTrackListeners();
    _setupErrorListener();
    _setupPositionTracking();
    _initializePlayer();
  }

  void _setupTrackListeners() {
    // Listen to available tracks
    player.stream.tracks.listen((tracks) {
      if (mounted) {
        setState(() {
          videoTracks = tracks.video;
          audioTracks = tracks.audio;
          subtitleTracks = tracks.subtitle;
        });
      }
    });

    // Listen to selected tracks
    player.stream.track.listen((track) {
      if (mounted) {
        setState(() {
          selectedVideoTrack = track.video;
          selectedAudioTrack = track.audio;
          selectedSubtitleTrack = track.subtitle;
        });
      }
    });
  }

  void _setupPositionTracking() {
    // Only track position for VOD and Series (not live TV)
    if (widget.isLive) return;

    // Listen to position changes
    player.stream.position.listen((position) {
      _currentPosition = position;
    });

    // Listen to duration
    player.stream.duration.listen((duration) {
      _totalDuration = duration;
    });

    // Periodically save position (every 1 minute)
    _saveTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _saveWatchingPosition();
    });
  }

  void _saveWatchingPosition() {
    // Don't save if no streamId or if live TV
    if (widget.streamId == null || widget.isLive) return;

    // Don't save if duration is too short or position is near the end
    if (_totalDuration.inSeconds < 60) return;
    if (_currentPosition.inSeconds < 10) return;
    if (_currentPosition.inSeconds > _totalDuration.inSeconds - 30) return;

    // Store actual position in seconds (as sliderValue) and total duration (as durationStrm)
    // This way we can calculate progress and resume position accurately
    final positionSeconds = _currentPosition.inSeconds.toDouble();
    final durationSeconds = _totalDuration.inSeconds.toDouble();

    debugPrint(
        '💾 Saving watching position: ${_currentPosition.inSeconds}s / ${_totalDuration.inSeconds}s (${(positionSeconds / durationSeconds * 100).toStringAsFixed(1)}%)');

    final watchingModel = WatchingModel(
      streamId: widget.streamId!,
      image: widget.imageUrl ?? '',
      title: widget.title,
      stream: widget.link,
      sliderValue: positionSeconds, // Store actual position in seconds
      durationStrm: durationSeconds, // Store total duration in seconds
    );

    // Save to cubit
    if (widget.isSeries) {
      context.read<WatchingCubit>().addSerie(watchingModel);
    } else {
      context.read<WatchingCubit>().addMovie(watchingModel);
    }
  }

  void _setupErrorListener() {
    // Listen to player errors and auto-retry
    player.stream.error.listen((error) {
      debugPrint('Player Error: $error');

      if (!mounted) return;

      // Check if error is related to stream loading
      if (error.contains('Failed to open') ||
          error.contains('Connection') ||
          error.contains('Network') ||
          error.contains('timeout')) {
        if (_retryCount < _maxRetries) {
          _retryCount++;
          debugPrint('Auto-retry attempt $_retryCount/$_maxRetries');

          setState(() {
            errorMessage =
                'Connection failed. Retrying... ($_retryCount/$_maxRetries)';
            hasError = true;
          });

          // Schedule retry
          _retryTimer?.cancel();
          _retryTimer = Timer(_retryDelay, () {
            if (mounted) {
              _retryPlayback();
            }
          });
        } else {
          // Max retries reached
          setState(() {
            hasError = true;
            errorMessage =
                'Failed to load stream after $_maxRetries attempts.\nPlease check your connection.';
            isLoading = false;
          });
        }
      }
    });

    // Listen to playing state - reset retry count on success
    player.stream.playing.listen((isPlaying) {
      if (isPlaying && _retryCount > 0) {
        debugPrint('Stream playing successfully after $_retryCount retries');
        _retryCount = 0;
        if (mounted && hasError) {
          setState(() {
            hasError = false;
            errorMessage = '';
          });
        }
      }
    });
  }

  Future<void> _retryPlayback() async {
    try {
      debugPrint('Retrying playback: ${widget.link}');

      setState(() {
        isLoading = true;
        hasError = false;
      });

      await player.open(
        Media(widget.link),
        play: false,
      );

      // If we have a resume position, seek to it before playing
      if (widget.resumePosition != null && !widget.isLive) {
        await player.stream.duration.first;
        debugPrint('⏩ Retry: Seeking to ${widget.resumePosition!.inSeconds}s');
        await player.seek(widget.resumePosition!);
      }

      // Now start playing
      await player.play();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Retry failed: $e');
      // Error listener will handle the retry logic
    }
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint("Playing: ${widget.link}");

      // If we have a resume position, log it
      if (widget.resumePosition != null && !widget.isLive) {
        debugPrint(
            "🔄 Resume position requested: ${widget.resumePosition!.inSeconds}s");
      }

      await player.open(
        Media(widget.link),
        play: false, // Don't auto-play, we need to seek first
      );

      // Wait for player to be ready, then resume from position
      if (widget.resumePosition != null && !widget.isLive) {
        // Wait for duration to be available
        await player.stream.duration.first;

        debugPrint("⏩ Seeking to ${widget.resumePosition!.inSeconds}s");
        await player.seek(widget.resumePosition!);

        // Now start playing
        await player.play();
        debugPrint("▶️ Playing from ${widget.resumePosition!.inSeconds}s");
      } else {
        // No resume position, just play normally
        await player.play();
      }

      // Listen for errors
      player.stream.error.listen((error) {
        debugPrint('Player Error: $error');
        if (mounted) {
          setState(() {
            hasError = true;
            errorMessage = 'Failed to load stream. Please try again.';
          });
        }
      });

      // Listen for buffering
      player.stream.buffering.listen((buffering) {
        if (mounted) {
          setState(() {
            isLoading = buffering;
          });
        }
      });

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing player: $e');
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = 'Error: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🛑 Disposing player - Stopping playback');

    // Save position one last time before disposing
    _saveWatchingPosition();

    // Cancel timers
    _retryTimer?.cancel();
    _saveTimer?.cancel();

    // Stop playback explicitly before disposing
    try {
      player.pause();
      player.stop();
    } catch (e) {
      debugPrint('Error stopping player: $e');
    }

    // Dispose player
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          debugPrint('🔙 Back button pressed - Stopping player');
          // Stop playback when back is pressed
          try {
            player.pause();
            player.stop();
          } catch (e) {
            debugPrint('Error stopping player on back: $e');
          }
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildErrorWidget(),
      );
    }

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildLoadingWidget(),
      );
    }

    // Use platform-specific controls
    return _buildPlatformSpecificPlayer(context);
  }

  Widget _buildPlatformSpecificPlayer(BuildContext context) {
    final platform = Theme.of(context).platform;

    // Desktop platforms (Windows, macOS, Linux)
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux) {
      return video.MaterialDesktopVideoControlsTheme(
        normal: video.MaterialDesktopVideoControlsThemeData(
          toggleFullscreenOnDoublePress: true,
          topButtonBar: [
            _buildBackButton(),
            const Spacer(),
            _buildTitleWidget(),
            const Spacer(),
            _buildSettingsButton(),
          ],
        ),
        fullscreen: video.MaterialDesktopVideoControlsThemeData(
          toggleFullscreenOnDoublePress: true,
          topButtonBar: [
            _buildBackButton(),
            const Spacer(),
            _buildTitleWidget(),
            const Spacer(),
            _buildSettingsButton(),
          ],
        ),
        child: Scaffold(
          body: video.Video(
            controller: controller,
          ),
        ),
      );
    }

    // Mobile platforms (Android, iOS)
    return video.MaterialVideoControlsTheme(
      normal: video.MaterialVideoControlsThemeData(
        speedUpOnLongPress: true,
        seekOnDoubleTap: true,
        topButtonBar: [
          _buildBackButton(),
          const Spacer(),
          _buildTitleWidget(),
          const Spacer(),
          _buildSettingsButton(),
        ],
      ),
      fullscreen: video.MaterialVideoControlsThemeData(
        speedUpOnLongPress: true,
        seekOnDoubleTap: true,
        topButtonBar: [
          _buildBackButton(),
          const Spacer(),
          _buildTitleWidget(),
          const Spacer(),
          _buildSettingsButton(),
        ],
      ),
      child: Scaffold(
        body: video.Video(
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () {
        debugPrint('🔙 Back button tapped - Stopping player');
        try {
          player.pause();
          player.stop();
        } catch (e) {
          debugPrint('Error stopping player: $e');
        }
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      tooltip: 'Back',
    );
  }

  Widget _buildTitleWidget() {
    return Text(
      widget.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSettingsButton() {
    return IconButton(
      onPressed: () => _showSettingsBottomSheet(context),
      icon: const Icon(Icons.settings, color: Colors.white),
      tooltip: 'Settings',
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Player Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Playback Speed
            _buildSettingsTile(
              icon: Icons.speed,
              title: 'Playback Speed',
              subtitle: '${player.state.rate}x',
              onTap: () => _showSpeedSelection(context),
            ),

            // Video Quality
            if (videoTracks.isNotEmpty)
              _buildSettingsTile(
                icon: Icons.high_quality,
                title: 'Video Quality',
                subtitle: selectedVideoTrack.id,
                onTap: () => _showVideoTrackSelection(context),
              ),

            // Audio Track
            if (audioTracks.isNotEmpty)
              _buildSettingsTile(
                icon: Icons.audiotrack,
                title: 'Audio Track',
                subtitle: selectedAudioTrack.language ?? 'Auto',
                onTap: () => _showAudioTrackSelection(context),
              ),

            // Subtitles
            if (subtitleTracks.isNotEmpty)
              _buildSettingsTile(
                icon: Icons.subtitles,
                title: 'Subtitles',
                subtitle: selectedSubtitleTrack.language ?? 'None',
                onTap: () => _showSubtitleTrackSelection(context),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kColorPrimary),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }

  void _showSpeedSelection(BuildContext context) {
    Navigator.pop(context);
    final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Playback Speed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...speeds.map((speed) => ListTile(
                  title: Text(
                    '${speed}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: player.state.rate == speed
                      ? const Icon(Icons.check, color: kColorPrimary)
                      : null,
                  onTap: () {
                    player.setRate(speed);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showVideoTrackSelection(BuildContext context) {
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Video Quality',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...videoTracks.map((track) => ListTile(
                  title: Text(
                    track.id,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: selectedVideoTrack.id == track.id
                      ? const Icon(Icons.check, color: kColorPrimary)
                      : null,
                  onTap: () {
                    player.setVideoTrack(track);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showAudioTrackSelection(BuildContext context) {
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Audio Track',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...audioTracks.map((track) => ListTile(
                  title: Text(
                    track.language ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: selectedAudioTrack.language == track.language
                      ? const Icon(Icons.check, color: kColorPrimary)
                      : null,
                  onTap: () {
                    player.setAudioTrack(track);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showSubtitleTrackSelection(BuildContext context) {
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Subtitles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(
                'None',
                style: TextStyle(color: Colors.white),
              ),
              trailing: selectedSubtitleTrack.id == 'no'
                  ? const Icon(Icons.check, color: kColorPrimary)
                  : null,
              onTap: () {
                player.setSubtitleTrack(SubtitleTrack.no());
                Navigator.pop(context);
              },
            ),
            ...subtitleTracks.map((track) => ListTile(
                  title: Text(
                    track.language ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: selectedSubtitleTrack.language == track.language
                      ? const Icon(Icons.check, color: kColorPrimary)
                      : null,
                  onTap: () {
                    player.setSubtitleTrack(track);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _retryCount > 0
                  ? 'Retrying... ($_retryCount/$_maxRetries)'
                  : 'Loading stream...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final bool canRetry = _retryCount < _maxRetries;

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canRetry ? Icons.refresh : Icons.error_outline,
              color: canRetry ? Colors.orange : Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            if (canRetry)
              const CircularProgressIndicator(color: Colors.white)
            else
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _retryCount = 0;
                    hasError = false;
                    isLoading = true;
                  });
                  _initializePlayer();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
