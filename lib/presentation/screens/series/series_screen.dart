part of '../screens.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  String selectedCategoryId = '';
  String keySearch = "";
  String categorySearch = "";
  bool _isSearching = false;
  bool _hasAutoSelectedCategory = false;
  int _cachedTotalSeriesCount = 0;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _remoteFocus = FocusNode();
  int _selectedSeriesIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCachedCount();
    _loadFirstCategory();
  }

  Future<void> _loadCachedCount() async {
    final count = await LocaleApi.getTotalSeriesCount();
    if (count != null && mounted) {
      setState(() {
        _cachedTotalSeriesCount = count;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categorySearchController.dispose();
    _scrollController.dispose();
    _remoteFocus.dispose();
    super.dispose();
  }
  
  void _handleRemoteKey(KeyEvent event) {
    final action = RemoteControlHandler.handleKeyEvent(event);
    
    if (action == null) return;
    
    switch (action) {
      case RemoteAction.navigateUp:
        _navigateSeries(-4);
        break;
        
      case RemoteAction.navigateDown:
        _navigateSeries(4);
        break;
        
      case RemoteAction.navigateLeft:
        _navigateSeries(-1);
        break;
        
      case RemoteAction.navigateRight:
        _navigateSeries(1);
        break;
        
      case RemoteAction.select:
        _openSelectedSeries();
        break;
        
      case RemoteAction.back:
        Get.back();
        break;
        
      case RemoteAction.colorRed:
        _toggleFavorite();
        break;
        
      case RemoteAction.colorGreen:
        setState(() {
          _isSearching = !_isSearching;
        });
        break;
        
      default:
        break;
    }
  }
  
  void _navigateSeries(int direction) {
    final channelsState = context.read<ChannelsBloc>().state;
    if (channelsState is ChannelsSeriesSuccess) {
      final series = channelsState.channels;
      if (series.isEmpty) return;
      
      setState(() {
        _selectedSeriesIndex = (_selectedSeriesIndex + direction).clamp(0, series.length - 1);
      });
    }
  }
  
  void _openSelectedSeries() {
    final channelsState = context.read<ChannelsBloc>().state;
    if (channelsState is ChannelsSeriesSuccess) {
      final series = channelsState.channels;
      if (_selectedSeriesIndex < series.length) {
        final selectedSeries = series[_selectedSeriesIndex];
        Get.toNamed(screenSeriesScreen, arguments: selectedSeries);
      }
    }
  }
  
  void _toggleFavorite() {
    final channelsState = context.read<ChannelsBloc>().state;
    if (channelsState is ChannelsSeriesSuccess) {
      final series = channelsState.channels;
      if (_selectedSeriesIndex < series.length) {
        final selectedSeries = series[_selectedSeriesIndex];
        final favState = context.read<FavoritesCubit>().state;
        final isFavorite = favState.series.any((fav) => fav.seriesId == selectedSeries.seriesId);
        context.read<FavoritesCubit>().addSerie(selectedSeries, isAdd: !isFavorite);
      }
    }
  }

  void _loadFirstCategory() {
    final bloc = context.read<SeriesCatyBloc>();
    if (bloc.state is SeriesCatySuccess && !_hasAutoSelectedCategory) {
      final categories = (bloc.state as SeriesCatySuccess).categories;

      if (categories.isNotEmpty) {
        setState(() {
          selectedCategoryId = categories.first.categoryId ?? '';
          _hasAutoSelectedCategory = true;
        });

        context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
              catyId: categories.first.categoryId ?? '',
              typeCategory: TypeCategory.series,
            ));
      }
    }
  }

  void _selectCategory(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      keySearch = ""; // Reset search when changing category
      _searchController.clear();
    });

    if (categoryId == 'all') {
      // Load all series
      context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
            typeCategory: TypeCategory.series,
            catyId: '',
          ));
    } else if (categoryId == 'favorites') {
      // Favorites handled in UI
    } else if (categoryId == 'continue_watching') {
      // Continue watching handled in UI
    } else {
      context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
            typeCategory: TypeCategory.series,
            catyId: categoryId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = getSize(context).width;
    final bool isPhone = width < 600;
    final bool isTablet = width >= 600 && width < 950;

    return KeyboardListener(
      focusNode: _remoteFocus,
      onKeyEvent: _handleRemoteKey,
      child: Scaffold(
        body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Column(
          children: [
            _buildHeader(isPhone, isTablet),
            Expanded(
              child: Row(
                children: [
                  _buildCategoriesSidebar(isPhone, isTablet),
                  Expanded(
                    child: _buildSeriesGrid(isPhone, isTablet),
                  ),
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
        horizontal: isPhone ? 4.w : 2.w,
        vertical: isPhone ? 2.h : 1.5.h,
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
              color: kColorPrimary,
              size: isPhone ? 18.sp : 16.sp,
            ),
          ),
          SizedBox(width: 2.w),

          // Title and icon (always visible)
          Icon(
            FontAwesomeIcons.tv,
            color: kColorPrimary,
            size: isPhone ? 20.sp : 18.sp,
          ),
          SizedBox(width: 2.w),
          Text(
            'Series',
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
                  hintText: 'Search series...',
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
      child: Column(
        children: [
          // Search input for categories
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
          Expanded(
            child: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
              builder: (context, state) {
                if (state is SeriesCatyLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SeriesCatySuccess) {
                  final categories = state.categories;

                  // Auto-select first category if not already selected
                  if (!_hasAutoSelectedCategory && categories.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadFirstCategory();
                    });
                  }

                  // Filter categories based on search
                  final filteredCategories = categorySearch.isEmpty
                      ? categories
                      : categories
                          .where((cat) => cat.categoryName!
                              .toLowerCase()
                              .contains(categorySearch.toLowerCase()))
                          .toList();

                  return ListView(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    children: [
                      // All Series
                      BlocBuilder<ChannelsBloc, ChannelsState>(
                        builder: (context, channelsState) {
                          // Use cached count by default, update when data loads
                          final isSelected = selectedCategoryId == 'all';
                          int totalCount = _cachedTotalSeriesCount;
                          
                          if (isSelected && channelsState is ChannelsSeriesSuccess) {
                            totalCount = channelsState.channels.length;
                            // Save to cache when data loads
                            if (totalCount != _cachedTotalSeriesCount) {
                              LocaleApi.saveTotalSeriesCount(totalCount);
                              _cachedTotalSeriesCount = totalCount;
                            }
                          }
                          
                          return _buildCategoryItem(
                            title: 'ALL SERIES',
                            icon: FontAwesomeIcons.tv,
                            count: totalCount > 0 ? totalCount.toString() : '',
                            isSelected: isSelected,
                            isPhone: isPhone,
                            isTablet: isTablet,
                            onTap: () => _selectCategory('all'),
                          );
                        },
                      ),

                      // Continue Watching
                      BlocBuilder<WatchingCubit, WatchingState>(
                        builder: (context, watchingState) {
                          final continueWatchingCount =
                              watchingState.series.length;
                          return _buildCategoryItem(
                            title: 'CONTINUE WATCHING',
                            icon: FontAwesomeIcons.clockRotateLeft,
                            count: continueWatchingCount > 0
                                ? continueWatchingCount.toString()
                                : '',
                            isSelected:
                                selectedCategoryId == 'continue_watching',
                            isPhone: isPhone,
                            isTablet: isTablet,
                            onTap: () => _selectCategory('continue_watching'),
                          );
                        },
                      ),

                      // Favorites
                      BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, favState) {
                          final favoritesCount = favState.series.length;
                          return _buildCategoryItem(
                            title: 'FAVORITES',
                            icon: FontAwesomeIcons.solidHeart,
                            count: favoritesCount > 0
                                ? favoritesCount.toString()
                                : '',
                            isSelected: selectedCategoryId == 'favorites',
                            isPhone: isPhone,
                            isTablet: isTablet,
                            onTap: () => _selectCategory('favorites'),
                          );
                        },
                      ),

                      // Category list
                      ...filteredCategories.map((category) {
                        final isSelected =
                            selectedCategoryId == category.categoryId;
                        return _buildCategoryItem(
                          title: category.categoryName?.toUpperCase() ?? '',
                          count: '',
                          isSelected: isSelected,
                          isPhone: isPhone,
                          isTablet: isTablet,
                          onTap: () =>
                              _selectCategory(category.categoryId ?? ''),
                        );
                      }).toList(),
                    ],
                  );
                }
                return const Center(child: Text("Failed to load categories"));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesGrid(bool isPhone, bool isTablet) {
    if (selectedCategoryId == 'continue_watching') {
      return BlocBuilder<WatchingCubit, WatchingState>(
        builder: (context, state) {
          if (state.series.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.clockRotateLeft,
                    size: 50.sp,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "No series in continue watching",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Clear button
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: kColorCardDark,
                            title: const Text(
                              'Clear Continue Watching',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to clear all series from continue watching?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<WatchingCubit>()
                                      .clearAllSeries();
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kColorPrimary,
                                ),
                                child: const Text('Clear All'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(FontAwesomeIcons.trash, size: 14.sp),
                      label: Text(
                        'Clear All',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(2.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isPhone ? 2 : (isTablet ? 4 : 5),
                    crossAxisSpacing: 2.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: state.series.length,
                  itemBuilder: (context, index) {
                    final item = state.series[index];
                    return _buildContinueWatchingCard(item, isPhone, isTablet);
                  },
                ),
              ),
            ],
          );
        },
      );
    } else if (selectedCategoryId == 'favorites') {
      return BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          final favorites = state.series;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.heart,
                    size: 60,
                    color: Colors.white38,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "No favorite series yet",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: isPhone ? 14.sp : 12.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          final searchList = keySearch.isEmpty
              ? favorites
              : favorites
                  .where((s) => s.name!.toLowerCase().contains(keySearch))
                  .toList();

          return GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(2.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isPhone ? 2 : (isTablet ? 4 : 5),
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.65,
            ),
            itemCount: searchList.length,
            itemBuilder: (context, index) {
              final serie = searchList[index];
              return _buildSerieCard(serie, isPhone, isTablet);
            },
          );
        },
      );
    } else {
      return BlocBuilder<ChannelsBloc, ChannelsState>(
        builder: (context, state) {
          if (state is ChannelsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChannelsSeriesSuccess) {
            final series = state.channels;

            if (series.isEmpty) {
              return Center(
                child: Text(
                  "No series found",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isPhone ? 14.sp : 12.sp,
                  ),
                ),
              );
            }

            final searchList = keySearch.isEmpty
                ? series
                : series
                    .where((s) => s.name!.toLowerCase().contains(keySearch))
                    .toList();

            return GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(2.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isPhone ? 2 : (isTablet ? 4 : 5),
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: 0.65,
              ),
              itemCount: searchList.length,
              itemBuilder: (context, index) {
                final serie = searchList[index];
                return _buildSerieCard(serie, isPhone, isTablet);
              },
            );
          }

          return const Center(
            child: Text(
              "Failed to load series",
              style: TextStyle(color: Colors.white54),
            ),
          );
        },
      );
    }
  }

  Widget _buildSerieCard(ChannelSerie serie, bool isPhone, bool isTablet) {
    return GestureDetector(
      onTap: () {
        Get.to(() => SerieContentModern(
              channelSerie: serie,
              videoId: serie.seriesId ?? '',
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: serie.cover != null && serie.cover!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: serie.cover!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.black26,
                          child: const Icon(
                            FontAwesomeIcons.tv,
                            color: Colors.white38,
                            size: 40,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.black26,
                        child: const Icon(
                          FontAwesomeIcons.tv,
                          color: Colors.white38,
                          size: 40,
                        ),
                      ),
              ),
              Container(
                padding: EdgeInsets.all(isPhone ? 2.w : 1.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
                child: Text(
                  serie.name ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 11.sp : 9.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueWatchingCard(
      WatchingModel item, bool isPhone, bool isTablet) {
    final progress = item.sliderValue / item.durationStrm;

    return GestureDetector(
      onTap: () async {
        // Navigate to episode player with resume position
        debugPrint('=== 🎬 CONTINUE WATCHING - SERIES CLICKED ===');
        debugPrint('streamId: ${item.streamId}');
        debugPrint('sliderValue (position): ${item.sliderValue}s');
        debugPrint('durationStrm (total): ${item.durationStrm}s');
        debugPrint(
            'Progress: ${(item.sliderValue / item.durationStrm * 100).toStringAsFixed(1)}%');
        debugPrint('stream: ${item.stream}');
        debugPrint('==========================================');

        final resumeSeconds = item.sliderValue;

        if (resumeSeconds <= 0) {
          debugPrint(
              '⚠️ WARNING: Invalid resume position: $resumeSeconds - Starting from beginning');
        }

        Get.to(() => FullVideoScreen(
              link: item.stream,
              title: item.title,
              streamId: item.streamId,
              imageUrl: item.image,
              isSeries: true,
              resumePosition: resumeSeconds,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: item.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.black26,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.black26,
                              child: const Icon(
                                FontAwesomeIcons.tv,
                                color: Colors.white38,
                                size: 40,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.black26,
                            child: const Icon(
                              FontAwesomeIcons.tv,
                              color: Colors.white38,
                              size: 40,
                            ),
                          ),
                  ),
                  // Progress bar
                  Container(
                    height: 4,
                    color: Colors.white24,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        color: kColorPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isPhone ? 2.w : 1.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPhone ? 11.sp : 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Play icon overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.circlePlay,
                    color: Colors.white.withOpacity(0.9),
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          color:
              isSelected ? kColorPrimary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              isSelected ? Border.all(color: kColorPrimary, width: 1) : null,
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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                  color:
                      isSelected ? kColorPrimary : Colors.white.withAlpha(51),
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
}
