part of '../screens.dart';

class MovieContentModern extends StatefulWidget {
  const MovieContentModern({
    super.key,
    required this.videoId,
    required this.channelMovie,
  });

  final String videoId;
  final ChannelMovie channelMovie;

  @override
  State<MovieContentModern> createState() => _MovieContentModernState();
}

class _MovieContentModernState extends State<MovieContentModern> {
  late Future<MovieDetail?> future;
  final FocusNode _remoteFocus = FocusNode();
  int _selectedButton = 1; // 0=Trailer, 1=Watch Now, 2=Favorite

  @override
  void initState() {
    super.initState();
    future = IpTvApi.getMovieDetails(widget.videoId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _remoteFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _remoteFocus.dispose();
    super.dispose();
  }

  void _handleRemoteKey(KeyEvent event) {
    final action = RemoteControlHandler.handleKeyEvent(event);

    if (action == null) return;

    switch (action) {
      case RemoteAction.navigateLeft:
        setState(() {
          if (_selectedButton > 0) _selectedButton--;
        });
        break;

      case RemoteAction.navigateRight:
        setState(() {
          if (_selectedButton < 2) _selectedButton++;
        });
        break;

      case RemoteAction.select:
        _executeSelectedAction();
        break;

      case RemoteAction.back:
        Get.back();
        break;

      case RemoteAction.colorRed:
        _toggleFavorite();
        break;

      default:
        break;
    }
  }

  void _executeSelectedAction() {
    // Implemented in button tap handlers
  }

  void _toggleFavorite() {
    final favState = context.read<FavoritesCubit>().state;
    final isLiked = favState.movies
        .where((movie) => movie.streamId == widget.channelMovie.streamId)
        .isNotEmpty;
    context
        .read<FavoritesCubit>()
        .addMovie(widget.channelMovie, isAdd: !isLiked);
  }

  @override
  Widget build(BuildContext context) {
    final width = getSize(context).width;
    final bool isPhone = width < 600;
    final bool isTablet = width >= 600 && width < 950;
    final bool isDesktop = width >= 950;

    return KeyboardListener(
      focusNode: _remoteFocus,
      onKeyEvent: _handleRemoteKey,
      child: Scaffold(
        body: Container(
          decoration: kDecorBackground,
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                final userAuth = state.user;
                return FutureBuilder<MovieDetail?>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: kColorPrimary,
                        ),
                      );
                    } else if (!snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.triangleExclamation,
                              color: Colors.white70,
                              size: isPhone ? 40 : 60,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "Could not load movie details",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isPhone ? 14.sp : 12.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final movie = snapshot.data!;

                    return Stack(
                      children: [
                        // Modern content layout
                        _buildModernContent(
                            movie, userAuth, isPhone, isTablet, isDesktop),

                        // Top app bar with back and favorite
                        _buildTopAppBar(isPhone, isTablet),
                      ],
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModernContent(
    MovieDetail movie,
    UserModel userAuth,
    bool isPhone,
    bool isTablet,
    bool isDesktop,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section with backdrop and gradient
          _buildHeroSection(movie, isPhone, isTablet, isDesktop),

          // Movie info section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isPhone ? 4.w : (isTablet ? 3.w : 2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Title and rating
                _buildTitleSection(movie, isPhone, isTablet),

                SizedBox(height: 2.h),

                // Action buttons
                _buildActionButtons(movie, userAuth, isPhone, isTablet),

                SizedBox(height: 3.h),

                // Movie details
                _buildMovieDetails(movie, isPhone, isTablet),

                SizedBox(height: 3.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    MovieDetail movie,
    bool isPhone,
    bool isTablet,
    bool isDesktop,
  ) {
    final backdropUrl =
        movie.info!.backdropPath != null && movie.info!.backdropPath!.isNotEmpty
            ? movie.info!.backdropPath!.first
            : movie.info!.movieImage ?? "";

    return Stack(
      children: [
        // Backdrop image
        Container(
          height: isPhone ? 30.h : (isTablet ? 40.h : 50.h),
          width: double.infinity,
          decoration: BoxDecoration(
            image: backdropUrl.isNotEmpty
                ? DecorationImage(
                    image: CachedNetworkImageProvider(backdropUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: Colors.grey[900],
          ),
        ),

        // Gradient overlay
        Container(
          height: isPhone ? 30.h : (isTablet ? 40.h : 50.h),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),

        // Poster and quick info overlay (for tablet/desktop)
        if (!isPhone)
          Positioned(
            bottom: -50,
            left: isTablet ? 3.w : 2.w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Movie poster
                _buildPosterCard(movie, isPhone, isTablet),
                SizedBox(width: 2.w),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPosterCard(MovieDetail movie, bool isPhone, bool isTablet) {
    return Container(
      width: isTablet ? 25.w : 15.w,
      height: isTablet ? 35.h : 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: movie.info!.movieImage ?? "",
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(color: kColorPrimary),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(FontAwesomeIcons.film, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(MovieDetail movie, bool isPhone, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          movie.movieData!.name ?? "",
          style: TextStyle(
            color: Colors.white,
            fontSize: isPhone ? 20.sp : (isTablet ? 18.sp : 16.sp),
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 1.h),

        // Rating, year, duration row
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            // Rating
            if (movie.info!.rating != null && movie.info!.rating!.isNotEmpty)
              _buildInfoChip(
                icon: FontAwesomeIcons.star,
                text: movie.info!.rating!,
                color: Colors.amber,
                isPhone: isPhone,
              ),

            // Year
            if (movie.info!.releasedate != null)
              _buildInfoChip(
                icon: FontAwesomeIcons.calendar,
                text: expirationDate(movie.info!.releasedate),
                color: Colors.blue,
                isPhone: isPhone,
              ),

            // Duration
            if (movie.info!.duration != null &&
                movie.info!.duration!.isNotEmpty)
              _buildInfoChip(
                icon: FontAwesomeIcons.clock,
                text: movie.info!.duration!,
                color: Colors.green,
                isPhone: isPhone,
              ),
          ],
        ),

        // Genre tags
        if (movie.info!.genre != null && movie.info!.genre!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Wrap(
              spacing: 1.w,
              runSpacing: 0.5.h,
              children: movie.info!.genre!.split(',').take(5).map((genre) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 2.w : 1.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    genre.trim(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isPhone ? 10.sp : 8.sp,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    required bool isPhone,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 2.w : 1.w,
        vertical: 0.5.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: isPhone ? 12.sp : 10.sp,
          ),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isPhone ? 11.sp : 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    MovieDetail movie,
    UserModel userAuth,
    bool isPhone,
    bool isTablet,
  ) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        final isLiked = favState.movies
            .where((m) => m.streamId == widget.channelMovie.streamId)
            .isNotEmpty;

        return Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            // Watch Now button (primary)
            _buildModernButton(
              icon: FontAwesomeIcons.play,
              label: "Watch Now",
              isPrimary: true,
              isSelected: _selectedButton == 1,
              isPhone: isPhone,
              isTablet: isTablet,
              onTap: () => _watchMovie(movie, userAuth),
            ),

            // Trailer button
            if (movie.info!.youtubeTrailer != null &&
                movie.info!.youtubeTrailer!.isNotEmpty)
              _buildModernButton(
                icon: FontAwesomeIcons.youtube,
                label: "Trailer",
                isPrimary: false,
                isSelected: _selectedButton == 0,
                isPhone: isPhone,
                isTablet: isTablet,
                onTap: () => _watchTrailer(movie),
              ),

            // Favorite button
            _buildModernButton(
              icon: isLiked
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
              label: isLiked ? "Remove" : "Favorite",
              isPrimary: false,
              isSelected: _selectedButton == 2,
              isPhone: isPhone,
              isTablet: isTablet,
              color: isLiked ? Colors.red : null,
              onTap: _toggleFavorite,
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool isSelected,
    required bool isPhone,
    required bool isTablet,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor =
        color ?? (isPrimary ? kColorPrimary : Colors.white.withOpacity(0.2));
    final textColor = isPrimary ? Colors.black : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isPhone ? 4.w : (isTablet ? 3.w : 2.w),
          vertical: isPhone ? 1.5.h : 1.2.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? buttonColor.withOpacity(0.9) : buttonColor,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: isPhone ? 14.sp : 12.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: isPhone ? 12.sp : 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieDetails(MovieDetail movie, bool isPhone, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plot/Description
        if (movie.info!.plot != null && movie.info!.plot!.isNotEmpty)
          _buildDetailSection(
            title: "Overview",
            icon: FontAwesomeIcons.alignLeft,
            isPhone: isPhone,
            isTablet: isTablet,
            child: Text(
              movie.info!.plot!,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isPhone ? 12.sp : 10.sp,
                height: 1.5,
              ),
            ),
          ),

        SizedBox(height: 2.h),

        // Director
        if (movie.info!.director != null && movie.info!.director!.isNotEmpty)
          _buildDetailSection(
            title: "Director",
            icon: FontAwesomeIcons.clapperboard,
            isPhone: isPhone,
            isTablet: isTablet,
            child: Text(
              movie.info!.director!,
              style: TextStyle(
                color: Colors.white,
                fontSize: isPhone ? 12.sp : 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        SizedBox(height: 2.h),

        // Cast
        if (movie.info!.cast != null && movie.info!.cast!.isNotEmpty)
          _buildDetailSection(
            title: "Cast",
            icon: FontAwesomeIcons.users,
            isPhone: isPhone,
            isTablet: isTablet,
            child: Text(
              movie.info!.cast!,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isPhone ? 11.sp : 9.sp,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required bool isPhone,
    required bool isTablet,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: kColorPrimary,
              size: isPhone ? 14.sp : 12.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isPhone ? 14.sp : 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        child,
      ],
    );
  }

  Widget _buildTopAppBar(bool isPhone, bool isTablet) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isPhone ? 4.w : (isTablet ? 3.w : 2.w),
          vertical: 1.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            InkWell(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(isPhone ? 2.w : 1.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                  size: isPhone ? 16.sp : 14.sp,
                ),
              ),
            ),

            // Favorite button
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                final isLiked = state.movies
                    .where((movie) =>
                        movie.streamId == widget.channelMovie.streamId)
                    .isNotEmpty;

                return InkWell(
                  onTap: _toggleFavorite,
                  child: Container(
                    padding: EdgeInsets.all(isPhone ? 2.w : 1.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isLiked
                            ? Colors.red
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      isLiked
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      color: isLiked ? Colors.red : Colors.white,
                      size: isPhone ? 16.sp : 14.sp,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _watchMovie(MovieDetail movie, UserModel userAuth) {
    final link =
        "${userAuth.serverInfo!.serverUrl}/movie/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${movie.movieData!.streamId}.${movie.movieData!.containerExtension}";

    // Parse subtitles
    List<Map<String, String>>? subtitles;
    try {
      final movieDataJson = movie.toJson();
      if (movieDataJson.containsKey('info') &&
          movieDataJson['info'] != null &&
          movieDataJson['info']['subtitles'] != null) {
        final subs = movieDataJson['info']['subtitles'];
        subtitles = [];

        if (subs is List) {
          for (var sub in subs) {
            if (sub is Map) {
              final lang = sub['language']?.toString() ??
                  sub['name']?.toString() ??
                  'Unknown';
              final url =
                  sub['url']?.toString() ?? sub['path']?.toString() ?? '';

              if (url.isNotEmpty) {
                final subtitleUrl = url.startsWith('http')
                    ? url
                    : "${userAuth.serverInfo!.serverUrl}$url";

                subtitles.add({
                  'lang': lang,
                  'url': subtitleUrl,
                });
              }
            }
          }
        } else if (subs is Map) {
          subs.forEach((key, value) {
            final url = value.toString();
            if (url.isNotEmpty) {
              final subtitleUrl = url.startsWith('http')
                  ? url
                  : "${userAuth.serverInfo!.serverUrl}$url";

              subtitles!.add({
                'lang': key.toString().toUpperCase(),
                'url': subtitleUrl,
              });
            }
          });
        }

        if (subtitles.isEmpty) {
          subtitles = null;
        }
      }
    } catch (e) {
      debugPrint("Error parsing subtitles: $e");
      subtitles = null;
    }

    Get.to(() => FullVideoScreen(
              link: link,
              title: movie.movieData!.name ?? "",
              subtitles: subtitles,
              streamId: widget.channelMovie.streamId.toString(),
              imageUrl: widget.channelMovie.streamIcon ?? "",
              isSeries: false,
            ))!
        .then((slider) {
      if (slider != null) {
        var model = WatchingModel(
          sliderValue: slider[0],
          durationStrm: slider[1],
          stream: link,
          title: widget.channelMovie.name ?? "",
          image: widget.channelMovie.streamIcon ?? "",
          streamId: widget.channelMovie.streamId.toString(),
        );
        context.read<WatchingCubit>().addMovie(model);
      }
    });
  }

  void _watchTrailer(MovieDetail movie) {
    showDialog(
      context: context,
      builder: (builder) => DialogTrailerYoutube(
        thumb: movie.info!.backdropPath != null &&
                movie.info!.backdropPath!.isNotEmpty
            ? movie.info!.backdropPath!.first
            : null,
        trailer: movie.info!.youtubeTrailer ?? "",
      ),
    );
  }
}
