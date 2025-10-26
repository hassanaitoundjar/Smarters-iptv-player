part of '../screens.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  // MediaKit Player (cross-platform)
  Player? _player;
  video.VideoController? _videoController;
  
  String? selectedCategoryId = 'all'; // Auto-select "All Channels"
  int? selectedChannelIndex;
  ChannelLive? selectedChannel;
  String keySearch = "";
  String categorySearch = "";
  bool isLoadingVideo = false;
  bool _hasAutoSelectedChannel = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categorySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load categories on init
    context.read<LiveCatyBloc>().add(GetLiveCategories());
    
    // Auto-load channels for "All Channels" category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllChannels();
    });
  }
  
  void _loadAllChannels() async {
    // Get all categories
    final bloc = context.read<LiveCatyBloc>();
    if (bloc.state is LiveCatySuccess) {
      final categories = (bloc.state as LiveCatySuccess).categories;
      
      // Load channels from the first category (or you can load from all categories)
      if (categories.isNotEmpty) {
        context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          catyId: categories.first.categoryId ?? '',
          typeCategory: TypeCategory.live,
        ));
      }
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    _searchController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(String streamId) async {
    setState(() => isLoadingVideo = true);
    
    UserModel? user = await LocaleApi.getUser();

    // Dispose of existing player
    await _player?.dispose();
    _player = null;
    await Future.delayed(const Duration(milliseconds: 300));

    // Xtream Codes API format for live streams
    // Format: http://domain:port/live/username/password/streamId.ext
    var videoUrl = "${user!.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/$streamId";

    debugPrint("Load Video: $videoUrl (using MediaKit)");
    
    try {
      // Initialize MediaKit player
      _player = Player();
      _videoController = video.VideoController(_player!);
      
      await _player!.open(Media(videoUrl), play: true);
      
      setState(() => isLoadingVideo = false);
    } catch (e) {
      debugPrint("MediaKit Player Error: $e");
      setState(() {
        isLoadingVideo = false;
      });
    }
  }

  void _selectCategory(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedChannelIndex = null;
      selectedChannel = null;
      keySearch = ""; // Reset search when changing category
      _searchController.clear();
      _hasAutoSelectedChannel = false; // Reset auto-selection for new category
      
      // Stop current player
      _player?.pause();
    });
    
    // Don't load channels for "all" or "favorites" - they are handled differently
    if (categoryId != 'all' && categoryId != 'favorites') {
      // Load channels for selected category
      context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
            catyId: categoryId,
            typeCategory: TypeCategory.live,
          ));
    }
  }

  void _selectChannel(ChannelLive channel, int index) async {
    setState(() {
      selectedChannelIndex = index;
      selectedChannel = channel;
    });
    
    await _initializeVideo(channel.streamId.toString());
  }

  @override
  Widget build(BuildContext context) {
    final width = getSize(context).width;
    final bool isPhone = width < 600;
    final bool isTablet = width >= 600 && width < 950;
    
    return Scaffold(
      body: Container(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(isPhone, isTablet),
              
              // Main Content
              Expanded(
                child: Row(
                  children: [
                    // Categories Sidebar
                    _buildCategoriesSidebar(isPhone, isTablet),
                    
                    // Channels List
                    _buildChannelsList(isPhone, isTablet),
                    
                    // Video Player & EPG
                    if (selectedChannel != null && !isPhone)
                      _buildVideoPlayer(isPhone, isTablet),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isPhone, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 3.w : 2.w,
        vertical: isPhone ? 1.5.h : 1.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(102),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              FontAwesomeIcons.chevronLeft,
              color: Colors.white,
              size: isPhone ? 18.sp : 16.sp,
            ),
          ),
          SizedBox(width: 2.w),
          Icon(
            FontAwesomeIcons.tv,
            color: kColorPrimary,
            size: isPhone ? 20.sp : 18.sp,
          ),
          SizedBox(width: 2.w),
          if (!_isSearching)
            Text(
              'Live TV',
              style: Get.textTheme.headlineSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isPhone ? 18.sp : (isTablet ? 16.sp : 15.sp),
              ),
            ),
          const Spacer(),
          
          // Show search input when active
          if (_isSearching) ...[
            // Search Input (30% width)
            Container(
              width: 30.w,
              height: isPhone ? 6.h : 5.h,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(102),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: kColorPrimary,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPhone ? 14.sp : 12.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Search channels...',
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontSize: isPhone ? 14.sp : 12.sp,
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: kColorPrimary,
                    size: isPhone ? 16.sp : 14.sp,
                  ),
                  suffixIcon: keySearch.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            FontAwesomeIcons.xmark,
                            color: Colors.white70,
                            size: isPhone ? 16.sp : 14.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              keySearch = "";
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 1.h,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    keySearch = value;
                  });
                },
              ),
            ),
            SizedBox(width: 2.w),
            // Close search button
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  keySearch = "";
                  _searchController.clear();
                });
              },
              icon: Icon(
                FontAwesomeIcons.xmark,
                color: kColorPrimary,
                size: isPhone ? 18.sp : 16.sp,
              ),
            ),
          ] else ...[
            // Search Icon (when not searching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              icon: Icon(
                FontAwesomeIcons.magnifyingGlass,
                color: kColorPrimary,
                size: isPhone ? 18.sp : 16.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesSidebar(bool isPhone, bool isTablet) {
    return Container(
      width: isPhone ? 35.w : (isTablet ? 25.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        border: Border(
          right: BorderSide(
            color: Colors.white.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: BlocBuilder<LiveCatyBloc, LiveCatyState>(
        builder: (context, state) {
          if (state is LiveCatyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LiveCatySuccess) {
            final categories = state.categories;

            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                // Filter categories based on search
                final filteredCategories = categorySearch.isEmpty
                    ? categories
                    : categories.where((cat) {
                        final categoryName = cat.categoryName?.toLowerCase() ?? '';
                        final searchTerm = categorySearch.toLowerCase();
                        return categoryName.contains(searchTerm);
                      }).toList();

                return Column(
                  children: [
                    // Category Search Input
                    Container(
                      margin: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(102),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withAlpha(51),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _categorySearchController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isPhone ? 12.sp : 10.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search categories...',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: isPhone ? 12.sp : 10.sp,
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: kColorPrimary,
                            size: isPhone ? 14.sp : 12.sp,
                          ),
                          suffixIcon: categorySearch.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.xmark,
                                    color: Colors.white70,
                                    size: isPhone ? 14.sp : 12.sp,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      categorySearch = "";
                                      _categorySearchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            categorySearch = value;
                          });
                        },
                      ),
                    ),
                    // Categories List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                        ),
                        itemCount: filteredCategories.length + 2, // +2 for All and Favorites
                        itemBuilder: (context, index) {
                    // All Channels
                    if (index == 0) {
                      final isSelected = selectedCategoryId == 'all';
                      return _buildCategoryItem(
                        title: 'All Channels',
                        count: categories.fold<int>(
                          0,
                          (sum, cat) => sum + (int.tryParse(cat.categoryId ?? '0') ?? 0),
                        ).toString(),
                        isSelected: isSelected,
                        isPhone: isPhone,
                        isTablet: isTablet,
                        onTap: () => _selectCategory('all'),
                      );
                    }
                    
                    // Favorites
                    if (index == 1) {
                      final isSelected = selectedCategoryId == 'favorites';
                      return _buildCategoryItem(
                        title: 'Favorites',
                        count: favState.lives.length.toString(),
                        isSelected: isSelected,
                        isPhone: isPhone,
                        isTablet: isTablet,
                        onTap: () => _selectCategory('favorites'),
                      );
                    }

                          // Regular categories
                          final category = filteredCategories[index - 2];
                          final isSelected = selectedCategoryId == category.categoryId;

                          return _buildCategoryItem(
                            title: category.categoryName ?? '',
                            count: '0',
                            isSelected: isSelected,
                            isPhone: isPhone,
                            isTablet: isTablet,
                            onTap: () => _selectCategory(category.categoryId ?? ''),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const Center(
            child: Text(
              'Failed to load categories',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem({
    required String title,
    IconData? icon,
    required String count,
    required bool isSelected,
    required bool isPhone,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 1.w,
          vertical: 0.3.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isPhone ? 2.w : 1.5.w,
          vertical: isPhone ? 1.5.h : 1.2.h,
        ),
        decoration: BoxDecoration(
                              color: isSelected ? kColorPrimary.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: kColorPrimary, width: 1)
                                  : null,
                            ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? kColorPrimary : Colors.white70,
                size: isPhone ? 14.sp : 12.sp,
              ),
              SizedBox(width: 2.w),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPhone ? 13.sp : (isTablet ? 12.sp : 11.sp),
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count.isNotEmpty && count != '0') ...[
              SizedBox(width: 1.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.w,
                  vertical: 0.2.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? kColorPrimary
                      : Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 10.sp : 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChannelsList(bool isPhone, bool isTablet) {
    if (selectedCategoryId == null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.tv,
                size: 50.sp,
                color: Colors.white30,
              ),
              SizedBox(height: 2.h),
              Text(
                'Select a category to view channels',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isPhone ? 14.sp : 12.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Handle Favorites
    if (selectedCategoryId == 'favorites') {
      return Container(
        width: isPhone
            ? 65.w
            : (selectedChannel != null
                ? (isTablet ? 35.w : 30.w)
                : (isTablet ? 75.w : 80.w)),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(51),
        ),
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favState) {
            final favorites = favState.lives;

            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.heart,
                      size: 40.sp,
                      color: Colors.white30,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No favorite channels yet',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isPhone ? 14.sp : 12.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            return _buildChannelsListView(favorites, isPhone, isTablet);
          },
        ),
      );
    }

    return Container(
      width: isPhone
          ? 65.w
          : (selectedChannel != null
              ? (isTablet ? 35.w : 30.w)
              : (isTablet ? 75.w : 80.w)),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(51),
      ),
      child: BlocBuilder<ChannelsBloc, ChannelsState>(
        builder: (context, state) {
          if (state is ChannelsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChannelsLiveSuccess) {
            final channels = state.channels;

            if (channels.isEmpty) {
              return Center(
                child: Text(
                  'No channels available',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isPhone ? 14.sp : 12.sp,
                  ),
                ),
              );
            }

            // Auto-select first channel if not already selected
            if (!_hasAutoSelectedChannel && channels.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_hasAutoSelectedChannel) {
                  _hasAutoSelectedChannel = true;
                  _selectChannel(channels.first, 0);
                }
              });
            }

            return _buildChannelsListView(channels, isPhone, isTablet);
          }

          return const Center(
            child: Text(
              'Failed to load channels',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer(bool isPhone, bool isTablet) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(128),
        ),
        child: Column(
          children: [
            // Video Player with Controls
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.black,
                child: isLoadingVideo
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _videoController != null
                        ? video.Video(
                            controller: _videoController!,
                            controls: video.AdaptiveVideoControls,
                          )
                        : Center(
                            child: Icon(
                              FontAwesomeIcons.tv,
                              size: 50.sp,
                              color: Colors.white30,
                            ),
                          ),
              ),
            ),
            
            // Channel Info & EPG
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: kColorCardDark,
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withAlpha(26),
                      width: 1,
                    ),
                  ),
                ),
                child: selectedChannel != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Channel Name
                          Text(
                            selectedChannel!.name ?? '',
                            style: Get.textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 14.sp : 12.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1.h),
                          Divider(color: Colors.white.withAlpha(51)),
                          SizedBox(height: 1.h),
                          // EPG Section
                          Expanded(
                            child: _buildEPGSection(),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEPGSection() {
    if (selectedChannel?.streamId == null) {
      return const SizedBox();
    }

    return FutureBuilder<List<EpgModel>>(
      future: IpTvApi.getEPGbyStreamId(selectedChannel!.streamId.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No program guide available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.sp,
              ),
            ),
          );
        }

        final epgList = snapshot.data!;

        return ListView.separated(
          itemCount: epgList.length > 10 ? 10 : epgList.length,
          itemBuilder: (context, index) {
            final epg = epgList[index];
            String title = '';
            String description = '';
            
            try {
              title = utf8.decode(base64.decode(epg.title ?? ""));
              description = utf8.decode(base64.decode(epg.description ?? ""));
            } catch (e) {
              title = epg.title ?? '';
              description = epg.description ?? '';
            }

            final isNow = checkEpgTimeIsNow(epg.start ?? "", epg.end ?? "");

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: 1.w,
                vertical: 0.5.h,
              ),
              decoration: BoxDecoration(
                color: isNow
                    ? const Color(0xFF6B2F8E).withAlpha(77)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isNow
                    ? Border.all(
                        color: const Color(0xFF6B2F8E),
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${getTimeFromDate(epg.start ?? "")} - ${getTimeFromDate(epg.end ?? "")}",
                    style: TextStyle(
                      color: isNow ? kColorPrimary : Colors.white70,
                      fontSize: 9.sp,
                      fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 0.2.h),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 8.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 0.5.h),
        );
      },
    );
  }

  Widget _buildChannelsListView(List<ChannelLive> channels, bool isPhone, bool isTablet) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        // Filter channels based on search query
        final filteredChannels = keySearch.isEmpty
            ? channels
            : channels.where((channel) {
                final channelName = channel.name?.toLowerCase() ?? '';
                final searchTerm = keySearch.toLowerCase();
                return channelName.contains(searchTerm);
              }).toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 1.h,
            horizontal: 1.w,
          ),
          itemCount: filteredChannels.length,
          itemBuilder: (context, index) {
            final channel = filteredChannels[index];
            // Find the original index for selection tracking
            final originalIndex = channels.indexOf(channel);
            final isSelected = selectedChannelIndex == originalIndex;
            final isFavorite = favState.lives.any(
              (fav) => fav.streamId == channel.streamId,
            );

            return InkWell(
              onTap: () => _selectChannel(channel, originalIndex),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 0.5.h),
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 2.w : 1.5.w,
                  vertical: isPhone ? 1.h : 0.8.h,
                ),
                decoration: BoxDecoration(
                              color: isSelected ? kColorPrimary.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: kColorPrimary, width: 1)
                                  : null,
                            ),
                child: Row(
                  children: [
                    // Channel Icon
                    Container(
                      width: isPhone ? 12.w : (isTablet ? 8.w : 6.w),
                      height: isPhone ? 12.w : (isTablet ? 8.w : 6.w),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: (channel.streamIcon != null &&
                              channel.streamIcon!.isNotEmpty &&
                              channel.streamIcon != 'null' &&
                              Uri.tryParse(channel.streamIcon!) != null)
                          ? ClipOval(
                              child: Image.network(
                                channel.streamIcon!,
                                width: isPhone ? 12.w : (isTablet ? 8.w : 6.w),
                                height: isPhone ? 12.w : (isTablet ? 8.w : 6.w),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.medium,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: isPhone ? 12.w : (isTablet ? 8.w : 6.w),
                                    height: isPhone ? 12.w : (isTablet ? 8.w : 6.w),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF6B2F8E),
                                    ),
                                    child: Center(
                                      child: Text(
                                        channel.name != null && channel.name!.isNotEmpty
                                            ? channel.name!.substring(0, 1).toUpperCase()
                                            : 'T',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isPhone ? 16.sp : 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: isPhone ? 12.w : (isTablet ? 8.w : 6.w),
                              height: isPhone ? 12.w : (isTablet ? 8.w : 6.w),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF6B2F8E),
                              ),
                              child: Center(
                                child: Text(
                                  channel.name != null && channel.name!.isNotEmpty
                                      ? channel.name!.substring(0, 1).toUpperCase()
                                      : 'T',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isPhone ? 16.sp : 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: 2.w),
                    // Channel Name
                    Expanded(
                      child: Text(
                        channel.name ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isPhone ? 13.sp : (isTablet ? 11.sp : 10.sp),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Favorite Icon
                    IconButton(
                      onPressed: () {
                        context.read<FavoritesCubit>().addLive(
                              channel,
                              isAdd: !isFavorite,
                            );
                      },
                      icon: Icon(
                        isFavorite
                            ? FontAwesomeIcons.solidHeart
                            : FontAwesomeIcons.heart,
                        color: isFavorite ? Colors.red : Colors.white70,
                        size: isPhone ? 14.sp : 12.sp,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 1.w),
                    // Play Icon
                    if (isSelected)
                      Icon(
                        FontAwesomeIcons.play,
                        color: kColorPrimary,
                        size: isPhone ? 12.sp : 10.sp,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
