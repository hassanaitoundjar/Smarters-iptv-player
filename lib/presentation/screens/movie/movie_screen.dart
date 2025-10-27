part of '../screens.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  String? selectedCategoryId;
  String keySearch = "";
  String categorySearch = "";
  bool _hasAutoSelectedCategory = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();
  final FocusNode _remoteFocus = FocusNode();
  int _cachedTotalMoviesCount = 0;
  int _selectedMovieIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load cached count
    _loadCachedCount();
    
    // Load categories on init
    context.read<MovieCatyBloc>().add(GetMovieCategories());

    // Auto-load first category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFirstCategory();
    });
  }

  Future<void> _loadCachedCount() async {
    final count = await LocaleApi.getTotalMoviesCount();
    if (count != null && mounted) {
      setState(() {
        _cachedTotalMoviesCount = count;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categorySearchController.dispose();
    _remoteFocus.dispose();
    super.dispose();
  }
  
  void _handleRemoteKey(KeyEvent event) {
    final action = RemoteControlHandler.handleKeyEvent(event);
    
    if (action == null) return;
    
    switch (action) {
      case RemoteAction.navigateUp:
        _navigateMovie(-4); // Move up one row (assuming 4 columns)
        break;
        
      case RemoteAction.navigateDown:
        _navigateMovie(4); // Move down one row
        break;
        
      case RemoteAction.navigateLeft:
        _navigateMovie(-1);
        break;
        
      case RemoteAction.navigateRight:
        _navigateMovie(1);
        break;
        
      case RemoteAction.select:
        _playSelectedMovie();
        break;
        
      case RemoteAction.back:
        Get.back();
        break;
        
      case RemoteAction.colorRed:
        // Toggle favorite
        _toggleFavorite();
        break;
        
      case RemoteAction.colorGreen:
        // Toggle search
        setState(() {
          _isSearching = !_isSearching;
        });
        break;
        
      default:
        break;
    }
  }
  
  void _navigateMovie(int direction) {
    final channelsState = context.read<ChannelsBloc>().state;
    if (channelsState is ChannelsMovieSuccess) {
      final movies = channelsState.channels;
      if (movies.isEmpty) return;
      
      setState(() {
        _selectedMovieIndex = (_selectedMovieIndex + direction).clamp(0, movies.length - 1);
      });
    }
  }
  
  void _playSelectedMovie() {
    final channelsState = context.read<ChannelsBloc>().state;
    if (channelsState is ChannelsMovieSuccess) {
      final movies = channelsState.channels;
      if (_selectedMovieIndex < movies.length) {
        final movie = movies[_selectedMovieIndex];
        Get.toNamed(screenMovieScreen, arguments: movie);
      }
    }
  }
  
  void _toggleFavorite() {
    final channelsState = context.read<ChannelsBloc>().state;
    if (channelsState is ChannelsMovieSuccess) {
      final movies = channelsState.channels;
      if (_selectedMovieIndex < movies.length) {
        final movie = movies[_selectedMovieIndex];
        final favState = context.read<FavoritesCubit>().state;
        final isFavorite = favState.movies.any((fav) => fav.streamId == movie.streamId);
        context.read<FavoritesCubit>().addMovie(movie, isAdd: !isFavorite);
      }
    }
  }

  void _loadFirstCategory() async {
    final bloc = context.read<MovieCatyBloc>();
    if (bloc.state is MovieCatySuccess && !_hasAutoSelectedCategory) {
      final categories = (bloc.state as MovieCatySuccess).categories;

      if (categories.isNotEmpty) {
        setState(() {
          selectedCategoryId = categories.first.categoryId;
          _hasAutoSelectedCategory = true;
        });

        context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
              catyId: categories.first.categoryId ?? '',
              typeCategory: TypeCategory.movies,
            ));
      }
    }
  }

  void _selectCategory(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      keySearch = ""; // Reset search when changing category
    });

    // Only load from API for regular categories (not special ones)
    if (categoryId != 'continue_watching' &&
        categoryId != 'favorites' &&
        categoryId != 'all_movies') {
      // Load movies for selected category
      context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
            catyId: categoryId,
            typeCategory: TypeCategory.movies,
          ));
    } else if (categoryId == 'all_movies') {
      // Load all movies (empty category ID loads all)
      context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
            catyId: '',
            typeCategory: TypeCategory.movies,
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

                    // Movies Grid
                    _buildMoviesGrid(isPhone, isTablet),
                  ],
                ),
              ),
            ],
          ),
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
              color: kColorPrimary,
              size: isPhone ? 18.sp : 16.sp,
            ),
          ),
          SizedBox(width: 2.w),

          // Title and icon (always visible)
          Icon(
            FontAwesomeIcons.film,
            color: kColorPrimary,
            size: isPhone ? 20.sp : 18.sp,
          ),
          SizedBox(width: 2.w),
          Text(
            'Movies',
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
                  hintText: 'Search movies...',
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
      child: BlocBuilder<MovieCatyBloc, MovieCatyState>(
        builder: (context, state) {
          if (state is MovieCatyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MovieCatySuccess) {
            final categories = state.categories;

            // Auto-select first category if not done yet
            if (!_hasAutoSelectedCategory && categories.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadFirstCategory();
              });
            }

            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                return BlocBuilder<WatchingCubit, WatchingState>(
                  builder: (context, watchingState) {
                    // Filter categories based on search
                    final filteredCategories = categorySearch.isEmpty
                        ? categories
                        : categories.where((cat) {
                            final categoryName =
                                cat.categoryName?.toLowerCase() ?? '';
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
                              hintText: 'Search by categories...',
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
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            itemCount: filteredCategories.length +
                                4, // +4 for All Movies, Recently Added, Continue Watching, Favorites
                            itemBuilder: (context, index) {
                              // All Movies
                              if (index == 0) {
                                final isSelected =
                                    selectedCategoryId == 'all_movies';
                                return BlocBuilder<ChannelsBloc, ChannelsState>(
                                  builder: (context, channelsState) {
                                    // Use cached count by default, update when data loads
                                    int totalCount = _cachedTotalMoviesCount;
                                    
                                    if (isSelected && channelsState is ChannelsMovieSuccess) {
                                      totalCount = channelsState.channels.length;
                                      // Save to cache when data loads
                                      if (totalCount != _cachedTotalMoviesCount) {
                                        LocaleApi.saveTotalMoviesCount(totalCount);
                                        _cachedTotalMoviesCount = totalCount;
                                      }
                                    }
                                    
                                    return _buildCategoryItem(
                                      title: 'ALL MOVIES',
                                      count: totalCount > 0 ? totalCount.toString() : '',
                                      isSelected: isSelected,
                                      isPhone: isPhone,
                                      isTablet: isTablet,
                                      onTap: () => _selectCategory('all_movies'),
                                    );
                                  },
                                );
                              }

                              // Recently Added
                              if (index == 1) {
                                final isSelected =
                                    selectedCategoryId == 'recently_added';
                                return _buildCategoryItem(
                                  title: 'RECENTLY ADDED',
                                  count: '30',
                                  isSelected: isSelected,
                                  isPhone: isPhone,
                                  isTablet: isTablet,
                                  onTap: () =>
                                      _selectCategory('recently_added'),
                                );
                              }

                              // Continue Watching
                              if (index == 2) {
                                final isSelected =
                                    selectedCategoryId == 'continue_watching';
                                final continueWatchingCount =
                                    watchingState.movies.length;
                                return _buildCategoryItem(
                                  title: 'CONTINUE WATCHING',
                                  count: continueWatchingCount > 0
                                      ? continueWatchingCount.toString()
                                      : '',
                                  isSelected: isSelected,
                                  isPhone: isPhone,
                                  isTablet: isTablet,
                                  onTap: () =>
                                      _selectCategory('continue_watching'),
                                );
                              }

                              // Favorites
                              if (index == 3) {
                                final isSelected =
                                    selectedCategoryId == 'favorites';
                                final favoritesCount = favState.movies.length;
                                return _buildCategoryItem(
                                  title: 'FAVORITES',
                                  count: favoritesCount > 0
                                      ? favoritesCount.toString()
                                      : '',
                                  isSelected: isSelected,
                                  isPhone: isPhone,
                                  isTablet: isTablet,
                                  onTap: () => _selectCategory('favorites'),
                                );
                              }

                              // Regular Categories
                              final category = filteredCategories[index - 4];
                              final isSelected =
                                  selectedCategoryId == category.categoryId;

                              return _buildCategoryItem(
                                title:
                                    category.categoryName?.toUpperCase() ?? '',
                                count: '',
                                isSelected: isSelected,
                                isPhone: isPhone,
                                isTablet: isTablet,
                                onTap: () =>
                                    _selectCategory(category.categoryId ?? ''),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
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

  Widget _buildMoviesGrid(bool isPhone, bool isTablet) {
    // Handle special categories
    if (selectedCategoryId == 'continue_watching') {
      return Expanded(
        child: Container(
          color: Colors.black.withAlpha(26),
          child: BlocBuilder<WatchingCubit, WatchingState>(
            builder: (context, watchingState) {
              final continueWatchingMovies = watchingState.movies;

              if (continueWatchingMovies.isEmpty) {
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
                        'No movies in continue watching',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Display continue watching movies with clear button
              return Column(
                children: [
                  // Clear All Button Header
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(51),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withAlpha(26),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.clockRotateLeft,
                          color: kColorPrimary,
                          size: isPhone ? 16.sp : 14.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Continue Watching',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isPhone ? 16.sp : 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w,
                            vertical: 0.3.h,
                          ),
                          decoration: BoxDecoration(
                            color: kColorPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            continueWatchingMovies.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isPhone ? 12.sp : 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Show confirmation dialog
                            Get.dialog(
                              AlertDialog(
                                backgroundColor: Colors.grey[900],
                                title: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.triangleExclamation,
                                      color: Colors.orange,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        'Clear Continue Watching',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  'Are you sure you want to clear all ${continueWatchingMovies.length} movies from continue watching?',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Clear all continue watching movies
                                      context.read<WatchingCubit>().clearData();
                                      Get.back();
                                      showSoftToast(
                                        context,
                                        'Success',
                                        'Continue watching list cleared',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      'Clear All',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            FontAwesomeIcons.trashCan,
                            size: isPhone ? 14.sp : 12.sp,
                          ),
                          label: Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: isPhone ? 14.sp : 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Movies Grid
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(2.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isPhone ? 2 : (isTablet ? 4 : 6),
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 2.w,
                        mainAxisSpacing: 2.h,
                      ),
                      itemCount: continueWatchingMovies.length,
                      itemBuilder: (context, index) {
                        final watching = continueWatchingMovies[index];
                        return _buildContinueWatchingCard(
                            watching, isPhone, isTablet);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    if (selectedCategoryId == 'favorites') {
      return Expanded(
        child: Container(
          color: Colors.black.withAlpha(26),
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favState) {
              final favoriteMovies = favState.movies;

              if (favoriteMovies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.heart,
                        size: 50.sp,
                        color: Colors.white30,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No favorite movies yet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(2.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isPhone ? 2 : (isTablet ? 4 : 6),
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.h,
                ),
                itemCount: favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoriteMovies[index];
                  return _buildMovieCard(movie, isPhone, isTablet);
                },
              );
            },
          ),
        ),
      );
    }

    // Regular categories from API
    return Expanded(
      child: Container(
        color: Colors.black.withAlpha(26),
        child: BlocBuilder<ChannelsBloc, ChannelsState>(
          builder: (context, state) {
            if (state is ChannelsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChannelsMovieSuccess) {
              var movies = state.channels;

              // Apply search filter if keySearch is not empty
              if (keySearch.isNotEmpty) {
                movies = movies.where((movie) {
                  final movieName = movie.name?.toLowerCase() ?? '';
                  final searchTerm = keySearch.toLowerCase();
                  return movieName.contains(searchTerm);
                }).toList();
              }

              if (movies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.film,
                        size: 50.sp,
                        color: Colors.white30,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No movies found',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(2.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isPhone ? 2 : (isTablet ? 4 : 6),
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.h,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return _buildMovieCard(movie, isPhone, isTablet);
                },
              );
            }

            return const Center(
              child: Text(
                'Failed to load movies',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContinueWatchingCard(
      WatchingModel watching, bool isPhone, bool isTablet) {
    // Calculate progress percentage for visual indicator
    final progress = watching.durationStrm > 0
        ? (watching.sliderValue / watching.durationStrm).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () {
        // Navigate directly to player with resume position
        debugPrint("🎬 Continue Watching - Title: ${watching.title}");
        debugPrint(
            "🎬 Continue Watching - Position: ${watching.sliderValue} seconds");
        debugPrint(
            "🎬 Continue Watching - Duration: ${watching.durationStrm} seconds");
        debugPrint(
            "🎬 Continue Watching - Progress: ${(progress * 100).toStringAsFixed(1)}%");
        debugPrint("🎬 Continue Watching - Stream: ${watching.stream}");

        Get.to(() => FullVideoScreen(
              link: watching.stream,
              title: watching.title,
              resumePosition: watching.sliderValue,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Movie Poster
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[900],
                child: watching.image.isNotEmpty
                    ? Image.network(
                        watching.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackPoster(watching.title);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : _buildFallbackPoster(watching.title),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Progress Bar at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                      child: Text(
                        watching.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isPhone ? 12.sp : 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Progress bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kColorPrimary, Colors.pink],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Play icon overlay
              Center(
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.play,
                    color: kColorPrimary,
                    size: isPhone ? 20.sp : 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCard(ChannelMovie movie, bool isPhone, bool isTablet) {
    return GestureDetector(
      onTap: () {
        // Navigate to movie detail screen first
        Get.to(() => MovieContentModern(
              videoId: movie.streamId ?? "",
              channelMovie: movie,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Movie Poster
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[900],
                child: movie.streamIcon != null && movie.streamIcon!.isNotEmpty
                    ? Image.network(
                        movie.streamIcon!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackPoster(movie.name ?? 'Movie');
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: kColorPrimary,
                            ),
                          );
                        },
                      )
                    : _buildFallbackPoster(movie.name ?? 'Movie'),
              ),

              // Gradient Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Movie Title
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  movie.name ?? 'Unknown Movie',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 10.sp : 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Play Button Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: kColorPrimary.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FontAwesomeIcons.play,
                        color: Colors.white,
                        size: isPhone ? 16.sp : 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPoster(String title) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kColorPrimary.withOpacity(0.8),
            kColorPrimary.withOpacity(0.4),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.film,
            color: Colors.white,
            size: 30.sp,
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required String title,
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
