part of '../screens.dart';

class SerieContentModern extends StatefulWidget {
  const SerieContentModern({
    super.key,
    required this.videoId,
    required this.channelSerie,
  });

  final String videoId;
  final ChannelSerie channelSerie;

  @override
  State<SerieContentModern> createState() => _SerieContentModernState();
}

class _SerieContentModernState extends State<SerieContentModern> {
  late Future<SerieDetails?> future;
  final FocusNode _remoteFocus = FocusNode();
  int _selectedButton = 1; // 0=Trailer, 1=Watch Now (Seasons), 2=Favorite

  @override
  void initState() {
    super.initState();
    future = IpTvApi.getSerieDetails(widget.videoId);
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
    final isLiked = favState.series
        .where((serie) => serie.seriesId == widget.channelSerie.seriesId)
        .isNotEmpty;
    context
        .read<FavoritesCubit>()
        .addSerie(widget.channelSerie, isAdd: !isLiked);
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
                return FutureBuilder<SerieDetails?>(
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
                              "Could not load series details",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isPhone ? 14.sp : 12.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final serie = snapshot.data!;

                    return Stack(
                      children: [
                        // Modern content layout
                        _buildModernContent(
                            serie, isPhone, isTablet, isDesktop),

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
    SerieDetails serie,
    bool isPhone,
    bool isTablet,
    bool isDesktop,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section with backdrop and gradient
          _buildHeroSection(serie, isPhone, isTablet, isDesktop),

          // Series info section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isPhone ? 4.w : (isTablet ? 3.w : 2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Title and rating
                _buildTitleSection(serie, isPhone, isTablet),

                SizedBox(height: 2.h),

                // Action buttons
                _buildActionButtons(serie, isPhone, isTablet),

                SizedBox(height: 3.h),

                // Series details
                _buildSeriesDetails(serie, isPhone, isTablet),

                SizedBox(height: 3.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    SerieDetails serie,
    bool isPhone,
    bool isTablet,
    bool isDesktop,
  ) {
    final backdropUrl =
        serie.info!.backdropPath != null && serie.info!.backdropPath!.isNotEmpty
            ? serie.info!.backdropPath!.first
            : serie.info!.cover ?? "";

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
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),

        // Poster overlay (for tablet/desktop)
        if (!isPhone)
          Positioned(
            bottom: -50,
            left: isTablet ? 3.w : 2.w,
            child: _buildPosterCard(serie, isPhone, isTablet),
          ),
      ],
    );
  }

  Widget _buildPosterCard(SerieDetails serie, bool isPhone, bool isTablet) {
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
          imageUrl: serie.info!.cover ?? "",
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(color: kColorPrimary),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(FontAwesomeIcons.tv, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(SerieDetails serie, bool isPhone, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          serie.info!.name ?? "",
          style: TextStyle(
            color: Colors.white,
            fontSize: isPhone ? 20.sp : (isTablet ? 18.sp : 16.sp),
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 1.h),

        // Rating, year, seasons row
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            // Rating
            if (serie.info!.rating != null && serie.info!.rating!.isNotEmpty)
              _buildInfoChip(
                icon: FontAwesomeIcons.star,
                text: serie.info!.rating!,
                color: Colors.amber,
                isPhone: isPhone,
              ),

            // Release date
            if (serie.info!.releaseDate != null &&
                serie.info!.releaseDate!.isNotEmpty)
              _buildInfoChip(
                icon: FontAwesomeIcons.calendar,
                text: serie.info!.releaseDate!,
                color: Colors.blue,
                isPhone: isPhone,
              ),

            // Number of seasons
            if (serie.seasons != null && serie.seasons!.isNotEmpty)
              _buildInfoChip(
                icon: FontAwesomeIcons.layerGroup,
                text:
                    "${serie.seasons!.length} Season${serie.seasons!.length > 1 ? 's' : ''}",
                color: Colors.purple,
                isPhone: isPhone,
              ),

            // Total episodes
            if (serie.episodes != null && serie.episodes!.isNotEmpty)
              _buildInfoChip(
                icon: FontAwesomeIcons.film,
                text:
                    "${serie.episodes!.length} Episode${serie.episodes!.length > 1 ? 's' : ''}",
                color: Colors.green,
                isPhone: isPhone,
              ),
          ],
        ),

        // Genre tags
        if (serie.info!.genre != null && serie.info!.genre!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Wrap(
              spacing: 1.w,
              runSpacing: 0.5.h,
              children: serie.info!.genre!.split(',').take(5).map((genre) {
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
    SerieDetails serie,
    bool isPhone,
    bool isTablet,
  ) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        final isLiked = favState.series
            .where((s) => s.seriesId == widget.channelSerie.seriesId)
            .isNotEmpty;

        return Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            // Watch Now button (primary) - Opens seasons
            _buildModernButton(
              icon: FontAwesomeIcons.play,
              label: "View Seasons",
              isPrimary: true,
              isSelected: _selectedButton == 1,
              isPhone: isPhone,
              isTablet: isTablet,
              onTap: () => _viewSeasons(serie),
            ),

            // Trailer button
            if (serie.info!.youtubeTrailer != null &&
                serie.info!.youtubeTrailer!.isNotEmpty)
              _buildModernButton(
                icon: FontAwesomeIcons.youtube,
                label: "Trailer",
                isPrimary: false,
                isSelected: _selectedButton == 0,
                isPhone: isPhone,
                isTablet: isTablet,
                onTap: () => _watchTrailer(serie),
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

  Widget _buildSeriesDetails(SerieDetails serie, bool isPhone, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plot/Description
        if (serie.info!.plot != null && serie.info!.plot!.isNotEmpty)
          _buildDetailSection(
            title: "Overview",
            icon: FontAwesomeIcons.alignLeft,
            isPhone: isPhone,
            isTablet: isTablet,
            child: Text(
              serie.info!.plot!,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isPhone ? 12.sp : 10.sp,
                height: 1.5,
              ),
            ),
          ),

        SizedBox(height: 2.h),

        // Director
        if (serie.info!.director != null && serie.info!.director!.isNotEmpty)
          _buildDetailSection(
            title: "Director",
            icon: FontAwesomeIcons.clapperboard,
            isPhone: isPhone,
            isTablet: isTablet,
            child: Text(
              serie.info!.director!,
              style: TextStyle(
                color: Colors.white,
                fontSize: isPhone ? 12.sp : 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        SizedBox(height: 2.h),

        // Cast
        if (serie.info!.cast != null && serie.info!.cast!.isNotEmpty)
          _buildDetailSection(
            title: "Cast",
            icon: FontAwesomeIcons.users,
            isPhone: isPhone,
            isTablet: isTablet,
            child: Text(
              serie.info!.cast!,
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
                final isLiked = state.series
                    .where((serie) =>
                        serie.seriesId == widget.channelSerie.seriesId)
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
  void _viewSeasons(SerieDetails serie) {
    Get.to(() => SerieSeasonsModern(serieDetails: serie));
  }

  void _watchTrailer(SerieDetails serie) {
    showDialog(
      context: context,
      builder: (builder) => DialogTrailerYoutube(
        thumb: serie.info!.backdropPath != null &&
                serie.info!.backdropPath!.isNotEmpty
            ? serie.info!.backdropPath!.first
            : null,
        trailer: serie.info!.youtubeTrailer ?? "",
      ),
    );
  }
}
