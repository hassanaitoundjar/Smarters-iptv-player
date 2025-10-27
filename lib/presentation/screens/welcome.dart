part of 'screens.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late InterstitialAd _interstitialAd;
  final FocusNode _remoteFocus = FocusNode();
  int _selectedIndex = 0; // 0=Live, 1=Movies, 2=Series
  
  _loadIntel() async {
    if (!showAds) {
      return false;
    }
    InterstitialAd.load(
        adUnitId: kInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint("Ads is Loaded");
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().initialData();
    context.read<WatchingCubit>().initialData();
    _loadIntel();
    
    // Preload all movies and series once
    _preloadContent();
    
    _remoteFocus.requestFocus();
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
          if (_selectedIndex > 0) _selectedIndex--;
        });
        break;
        
      case RemoteAction.navigateRight:
        setState(() {
          if (_selectedIndex < 2) _selectedIndex++;
        });
        break;
        
      case RemoteAction.select:
        _navigateToScreen(_selectedIndex);
        break;
        
      case RemoteAction.back:
        // Show exit dialog or go to menu
        Get.offAllNamed(screenMenu);
        break;
        
      case RemoteAction.home:
        Get.offAllNamed(screenMenu);
        break;
        
      case RemoteAction.colorRed:
        // Red button = Favorites
        break;
        
      case RemoteAction.colorGreen:
        // Green button = Search
        break;
        
      case RemoteAction.colorYellow:
        // Yellow button = Settings
        Get.toNamed(screenSettings);
        break;
        
      default:
        break;
    }
  }
  
  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Get.toNamed(screenLive);
        break;
      case 1:
        Get.toNamed(screenMovies);
        break;
      case 2:
        Get.toNamed(screenSeries);
        break;
    }
  }
  
  // Preload all movies and series to cache them
  void _preloadContent() {
    // Load all movies
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
      catyId: '',
      typeCategory: TypeCategory.movies,
    ));
    
    // Load all series
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
      catyId: '',
      typeCategory: TypeCategory.series,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final width = getSize(context).width;
    final isPhone = width < 600;
    final isTablet = width >= 600 && width < 950;

    return KeyboardListener(
      focusNode: _remoteFocus,
      onKeyEvent: _handleRemoteKey,
      child: Scaffold(
        body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(isPhone, isTablet),
              Expanded(
                child: Center(
                  child: Container(
                    height: 70.h, // 70% of screen height
                    padding: EdgeInsets.symmetric(
                      horizontal: isPhone ? 4.w : 3.w,
                    ),
                    child: Row(
                      children: [
                        // Column 1 - LIVE TV
                        Expanded(
                          child: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                            builder: (context, state) {
                              if (state is LiveCatyLoading) {
                                return _buildLoadingCard();
                              }
                              if (state is LiveCatySuccess) {
                                return _buildMainCard(
                                  title: "LIVE TV",
                                  subtitle:
                                      "${state.categories.length} Channels",
                                  icon: FontAwesomeIcons.tv,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF373047),
                                      Color(0xFF2F2840)
                                    ],
                                  ),
                                  onTap: () {
                                    Get.toNamed(screenLive)!
                                        .then((value) async {
                                      _interstitialAd.show();
                                      await _loadIntel();
                                    });
                                  },
                                  isPhone: isPhone,
                                );
                              }
                              return _buildErrorCard();
                            },
                          ),
                        ),
                        SizedBox(width: isPhone ? 3.w : 2.w),
                        // Column 2 - MOVIES
                        Expanded(
                          child: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                            builder: (context, state) {
                              if (state is MovieCatyLoading) {
                                return _buildLoadingCard();
                              } else if (state is MovieCatySuccess) {
                                return _buildMainCard(
                                  title: "MOVIES",
                                  subtitle:
                                      "${state.categories.length} Categories",
                                  icon: FontAwesomeIcons.circlePlay,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(
                                          0xFF3A3352), // Dark card base (same as others)
                                      Color(0xFF2F2840), // Darker
                                    ],
                                  ),
                                  isOrangeAccent: true,
                                  onTap: () {
                                    Get.toNamed(screenMovieScreen)!
                                        .then((value) async {
                                      await _interstitialAd.show();
                                      await _loadIntel();
                                    });
                                  },
                                  isPhone: isPhone,
                                );
                              }
                              return _buildErrorCard();
                            },
                          ),
                        ),
                        SizedBox(width: isPhone ? 3.w : 2.w),
                        // Column 3 - SERIES
                        Expanded(
                          child: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                            builder: (context, state) {
                              if (state is SeriesCatyLoading) {
                                return _buildLoadingCard();
                              } else if (state is SeriesCatySuccess) {
                                return _buildMainCard(
                                  title: "SERIES",
                                  subtitle:
                                      "${state.categories.length} Categories",
                                  icon: FontAwesomeIcons.clapperboard,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF373047),
                                      Color(0xFF2F2840)
                                    ],
                                  ),
                                  onTap: () {
                                    Get.toNamed(screenSeriesScreen)!
                                        .then((value) async {
                                      await _interstitialAd.show();
                                      await _loadIntel();
                                    });
                                  },
                                  isPhone: isPhone,
                                );
                              }
                              return _buildErrorCard();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom Info Bar - Fixed at bottom
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 4.w : 3.w,
                  vertical: 1.h,
                ),
                child: _buildBottomInfo(isPhone),
              ),
              AdmobWidget.getBanner(),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildModernHeader(bool isPhone, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 4.w : 3.w,
        vertical: isPhone ? 2.h : 1.5.h,
      ),
      child: Row(
        children: [
          // Left: Logo and App Name
          Row(
            children: [
              EvoFlixLogo(
                size: isPhone ? 35 : 40,
                showGlow: false,
              ),
              SizedBox(width: 2.w),
              Text(
                kAppName,
                style: Get.textTheme.headlineMedium!.copyWith(
                  fontSize: isPhone ? 18.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Center: Date and Time
          Text(
            dateNowWelcome(),
            style: TextStyle(
              color: Colors.white,
              fontSize: isPhone ? 18.sp : 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Right: Icon Buttons
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return Row(
                  children: [
                    // Icon Buttons
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.bell,
                        color: Colors.white,
                        size: isPhone ? 18.sp : 16.sp,
                      ),
                      onPressed: () {
                        // TODO: Notifications
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.user,
                        color: Colors.white,
                        size: isPhone ? 18.sp : 16.sp,
                      ),
                      onPressed: () {
                        Get.toNamed(screenUserList);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.rectangleList,
                        color: Colors.white,
                        size: isPhone ? 18.sp : 16.sp,
                      ),
                      onPressed: () {
                        Get.toNamed(screenFavourite);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.gear,
                        color: Colors.white,
                        size: isPhone ? 18.sp : 16.sp,
                      ),
                      onPressed: () {
                        Get.toNamed(screenSettings);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.rightFromBracket,
                        color: Colors.white,
                        size: isPhone ? 18.sp : 16.sp,
                      ),
                      onPressed: () {
                        Get.toNamed(screenMenu);
                      },
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required bool isPhone,
    bool isOrangeAccent = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOrangeAccent
                ? const Color(0xFFFFC107).withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isOrangeAccent
                  ? const Color(0xFFFFC107).withOpacity(0.2)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isOrangeAccent ? 20 : 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Orange accent indicator (top right) - only for Movies
            if (isOrangeAccent)
              Positioned(
                top: isPhone ? 2.w : 1.5.w,
                right: isPhone ? 2.w : 1.5.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 2.w : 1.5.w,
                    vertical: isPhone ? 0.5.h : 0.4.h,
                  ),
                ),
              ),
            // Background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: isPhone ? 150 : 200,
                color: isOrangeAccent
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.03),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(isPhone ? 4.w : 3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isPhone ? 3.w : 2.5.w),
                    decoration: BoxDecoration(
                      color: isOrangeAccent
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: isPhone ? 40 : 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isPhone ? 20.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isPhone ? 12.sp : 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Error loading data',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(bool isPhone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final userInfo = state.user.userInfo;
              return Text(
                "Expiration : ${expirationDate(userInfo!.expDate)}",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isPhone ? 11.sp : 15.sp,
                ),
              );
            }
            return const SizedBox();
          },
        ),
        Row(
          children: [
            Icon(
              FontAwesomeIcons.cartShopping,
              color: Colors.white70,
              size: isPhone ? 14.sp : 12.sp,
            ),
            SizedBox(width: 1.w),
            InkWell(
              onTap: () async {
                await launchUrlString(kContact);
              },
              child: Text(
                "Purchase Ads Free Version",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isPhone ? 11.sp : 15.sp,
                ),
              ),
            ),
          ],
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final userInfo = state.user.userInfo;
              return Text(
                "Logged in : ${userInfo!.username}",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isPhone ? 11.sp : 15.sp,
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}
