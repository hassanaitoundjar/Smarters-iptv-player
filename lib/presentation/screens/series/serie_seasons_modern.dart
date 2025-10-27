part of '../screens.dart';

class SerieSeasonsModern extends StatefulWidget {
  const SerieSeasonsModern({super.key, required this.serieDetails});
  final SerieDetails serieDetails;

  @override
  State<SerieSeasonsModern> createState() => _SerieSeasonsModernState();
}

class _SerieSeasonsModernState extends State<SerieSeasonsModern> {
  late SerieDetails serieDetails;
  int selectedSeason = 0;
  int selectedEpisode = 0;
  final FocusNode _remoteFocus = FocusNode();
  bool _isSeasonFocused = true; // true = seasons, false = episodes

  @override
  void initState() {
    super.initState();
    serieDetails = widget.serieDetails;
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

    final seasons = _getSeasons();
    final episodes = serieDetails.episodes!["${selectedSeason + 1}"] ?? [];

    switch (action) {
      case RemoteAction.navigateUp:
        if (_isSeasonFocused) {
          setState(() {
            if (selectedSeason > 0) selectedSeason--;
          });
        } else {
          setState(() {
            if (selectedEpisode > 0) selectedEpisode--;
          });
        }
        break;

      case RemoteAction.navigateDown:
        if (_isSeasonFocused) {
          setState(() {
            if (selectedSeason < seasons.length - 1) selectedSeason++;
          });
        } else {
          setState(() {
            if (selectedEpisode < episodes.length - 1) selectedEpisode++;
          });
        }
        break;

      case RemoteAction.navigateLeft:
        if (!_isSeasonFocused) {
          setState(() {
            _isSeasonFocused = true;
          });
        }
        break;

      case RemoteAction.navigateRight:
        if (_isSeasonFocused) {
          setState(() {
            _isSeasonFocused = false;
            selectedEpisode = 0;
          });
        }
        break;

      case RemoteAction.select:
        if (!_isSeasonFocused) {
          _playEpisode();
        }
        break;

      case RemoteAction.back:
        Get.back();
        break;

      default:
        break;
    }
  }

  List<String> _getSeasons() {
    List<String> seasons = [];
    if (serieDetails.episodes != null && serieDetails.episodes!.isNotEmpty) {
      serieDetails.episodes!.forEach((k, v) {
        seasons.add(k);
      });
    }
    return seasons;
  }

  void _playEpisode() {
    final episodes = serieDetails.episodes!["${selectedSeason + 1}"];
    if (episodes != null && selectedEpisode < episodes.length) {
      final episode = episodes[selectedEpisode];
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthSuccess) {
        final userAuth = authState.user;
        final link =
            "${userAuth.serverInfo!.serverUrl}/series/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${episode!.id}.${episode.containerExtension}";

        Get.to(() => FullVideoScreen(
                  link: link,
                  title: episode.title ?? "",
                  streamId: episode.id.toString(),
                  imageUrl: episode.info?.movieImage ??
                      serieDetails.info?.cover ??
                      "",
                  isSeries: true,
                ))!
            .then((slider) {
          if (slider != null) {
            var model = WatchingModel(
              sliderValue: slider[0],
              durationStrm: slider[1],
              stream: link,
              title: episode.title ?? "",
              image: episode.info?.movieImage ?? serieDetails.info?.cover ?? "",
              streamId: episode.id.toString(),
            );
            context.read<WatchingCubit>().addSerie(model);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = getSize(context).width;
    final bool isPhone = width < 600;
    final bool isTablet = width >= 600 && width < 950;
    final bool isDesktop = width >= 950;

    final seasons = _getSeasons();

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
                return Stack(
                  children: [
                    // Background with gradient
                    _buildBackground(isPhone, isTablet),

                    // Main content
                    SafeArea(
                      child: Column(
                        children: [
                          // Header
                          _buildHeader(isPhone, isTablet),

                          // Series info banner
                          _buildSeriesInfoBanner(isPhone, isTablet),

                          // Seasons and Episodes
                          Expanded(
                            child: isPhone
                                ? _buildPhoneLayout(seasons, userAuth, isPhone)
                                : _buildTabletDesktopLayout(seasons, userAuth,
                                    isPhone, isTablet, isDesktop),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(bool isPhone, bool isTablet) {
    final backdropUrl = serieDetails.info!.backdropPath != null &&
            serieDetails.info!.backdropPath!.isNotEmpty
        ? serieDetails.info!.backdropPath!.first
        : serieDetails.info!.cover ?? "";

    return Stack(
      children: [
        if (backdropUrl.isNotEmpty)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: backdropUrl,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.7),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isPhone, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 4.w : (isTablet ? 3.w : 2.w),
        vertical: 1.h,
      ),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(isPhone ? 2.w : 1.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
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
          SizedBox(width: 3.w),
          // Title
          Expanded(
            child: Text(
              "Seasons & Episodes",
              style: TextStyle(
                color: Colors.white,
                fontSize: isPhone ? 16.sp : 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesInfoBanner(bool isPhone, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isPhone ? 4.w : (isTablet ? 3.w : 2.w),
        vertical: 1.h,
      ),
      padding: EdgeInsets.all(isPhone ? 3.w : 2.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Poster thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: serieDetails.info!.cover ?? "",
              width: isPhone ? 15.w : 10.w,
              height: isPhone ? 20.w : 15.w,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(FontAwesomeIcons.tv, color: Colors.white54),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serieDetails.info!.name ?? "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 14.sp : 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    if (serieDetails.info!.rating != null)
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.star,
                            color: Colors.amber,
                            size: isPhone ? 10.sp : 8.sp,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            serieDetails.info!.rating!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isPhone ? 11.sp : 9.sp,
                            ),
                          ),
                        ],
                      ),
                    if (serieDetails.info!.rating != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text(
                          "•",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    Text(
                      "${_getSeasons().length} Season${_getSeasons().length > 1 ? 's' : ''}",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isPhone ? 11.sp : 9.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout(
      List<String> seasons, UserModel userAuth, bool isPhone) {
    return Column(
      children: [
        // Season selector
        Container(
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: seasons.length,
            itemBuilder: (_, i) {
              final isSelected = i == selectedSeason;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSeason = i;
                    selectedEpisode = 0;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 2.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kColorPrimary
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? kColorPrimary
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Season ${seasons[i]}",
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Episodes list
        Expanded(
          child: _buildEpisodesList(userAuth, isPhone, false, false),
        ),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(
    List<String> seasons,
    UserModel userAuth,
    bool isPhone,
    bool isTablet,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 3.w : 2.w,
        vertical: 1.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seasons sidebar
          Container(
            width: isTablet ? 25.w : 20.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                // Seasons header
                Container(
                  padding: EdgeInsets.all(isTablet ? 3.w : 2.w),
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.layerGroup,
                        color: kColorPrimary,
                        size: isTablet ? 14.sp : 12.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "Seasons",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 13.sp : 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Seasons list
                Expanded(
                  child: ListView.builder(
                    itemCount: seasons.length,
                    padding: EdgeInsets.all(isTablet ? 2.w : 1.w),
                    itemBuilder: (_, i) {
                      final isSelected = i == selectedSeason;
                      final isFocused = _isSeasonFocused && isSelected;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSeason = i;
                            selectedEpisode = 0;
                            _isSeasonFocused = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 3.w : 2.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kColorPrimary.withOpacity(0.3)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isFocused
                                  ? kColorPrimary
                                  : (isSelected
                                      ? kColorPrimary.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.1)),
                              width: isFocused ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isTablet ? 2.w : 1.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kColorPrimary
                                      : Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  seasons[i],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: isTablet ? 12.sp : 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Season ${seasons[i]}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 12.sp : 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${serieDetails.episodes!["${i + 1}"]?.length ?? 0} Episodes",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: isTablet ? 10.sp : 8.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 2.w),

          // Episodes list
          Expanded(
            child: _buildEpisodesList(userAuth, isPhone, isTablet, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesList(
      UserModel userAuth, bool isPhone, bool isTablet, bool isDesktop) {
    final episodes = serieDetails.episodes!["${selectedSeason + 1}"] ?? [];

    if (episodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.film,
              color: Colors.white54,
              size: isPhone ? 40 : 60,
            ),
            SizedBox(height: 2.h),
            Text(
              "No episodes available",
              style: TextStyle(
                color: Colors.white70,
                fontSize: isPhone ? 14.sp : 12.sp,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Episodes header
          Container(
            padding: EdgeInsets.all(isPhone ? 3.w : (isTablet ? 3.w : 2.w)),
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.film,
                  color: kColorPrimary,
                  size: isPhone ? 14.sp : (isTablet ? 14.sp : 12.sp),
                ),
                SizedBox(width: 2.w),
                Text(
                  "Episodes (${episodes.length})",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 13.sp : (isTablet ? 13.sp : 11.sp),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Episodes list
          Expanded(
            child: ListView.builder(
              itemCount: episodes.length,
              padding: EdgeInsets.all(isPhone ? 2.w : (isTablet ? 2.w : 1.w)),
              itemBuilder: (_, i) {
                final episode = episodes[i];
                final isSelected = selectedEpisode == i;
                final isFocused = !_isSeasonFocused && isSelected;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEpisode = i;
                      _isSeasonFocused = false;
                    });
                    _playEpisode();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isFocused
                            ? kColorPrimary
                            : (isSelected
                                ? Colors.white.withOpacity(0.3)
                                : Colors.transparent),
                        width: isFocused ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          isPhone ? 2.w : (isTablet ? 2.w : 1.w)),
                      child: Row(
                        children: [
                          // Episode thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: episode!.info?.movieImage ??
                                  serieDetails.info!.cover ??
                                  "",
                              width: isPhone ? 25.w : (isTablet ? 20.w : 15.w),
                              height: isPhone ? 15.w : (isTablet ? 12.w : 10.w),
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  FontAwesomeIcons.film,
                                  color: Colors.white54,
                                  size: isPhone ? 20 : 15,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 3.w),

                          // Episode info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Episode number and title
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isPhone ? 2.w : 1.w,
                                        vertical: 0.5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kColorPrimary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "EP ${i + 1}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: isPhone ? 10.sp : 8.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        episode.title ?? "Episode ${i + 1}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isPhone
                                              ? 12.sp
                                              : (isTablet ? 11.sp : 10.sp),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                if (episode.info?.plot != null &&
                                    episode.info!.plot!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.5.h),
                                    child: Text(
                                      episode.info!.plot!,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: isPhone
                                            ? 10.sp
                                            : (isTablet ? 9.sp : 8.sp),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                if (episode.info?.duration != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.5.h),
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.clock,
                                          color: Colors.white54,
                                          size: isPhone ? 10.sp : 8.sp,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          episode.info!.duration!,
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: isPhone ? 10.sp : 8.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Play icon
                          Container(
                            padding: EdgeInsets.all(isPhone ? 2.w : 1.w),
                            decoration: BoxDecoration(
                              color: isFocused
                                  ? kColorPrimary
                                  : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FontAwesomeIcons.play,
                              color: isFocused ? Colors.black : Colors.white,
                              size: isPhone ? 12.sp : 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
