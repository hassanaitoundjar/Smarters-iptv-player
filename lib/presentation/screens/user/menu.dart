part of '../screens.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = isTv(context);
    final width = getSize(context).width;
    
    // Determine layout based on screen size
    final bool isPhone = width < 600;
    final bool isTablet = width >= 600 && width < 950;
    final bool isLaptop = width >= 950;
    
    return Scaffold(
      body: Container(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Logo at the top
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 4.w : (isTablet ? 3.w : 2.w),
                  vertical: isPhone ? 1.5.h : (isTablet ? 2.h : 2.5.h),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        EvoFlixLogo(
                          size: isPhone ? 15.w : (isTablet ? 10.w : 8.w),
                          showGlow: true,
                        ),
                        SizedBox(height: isPhone ? 1.h : 0.8.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            kAppName,
                            textAlign: TextAlign.center,
                            style: Get.textTheme.headlineSmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isPhone ? 16.sp : (isTablet ? 16.sp : 15.sp),
                              letterSpacing: isPhone ? 1.5 : 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main menu container
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: getSize(context).width * 0.7,
                      margin: EdgeInsets.symmetric(
                        vertical: isPhone ? 2.h : 3.h,
                      ),
                      padding: EdgeInsets.all(isPhone ? 5.w : (isTablet ? 4.w : 3.5.w)),
                      decoration: BoxDecoration(
                        color: kColorCardDark.withAlpha(200),
                        borderRadius: BorderRadius.circular(isPhone ? 15 : 20),
                        border: Border.all(
                          color: Colors.white.withAlpha(51),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(102),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // First row - two buttons
                          isPhone
                              ? Column(
                                  children: [
                                    MenuButton(
                                      icon: FontAwesomeIcons.list,
                                      title: 'LOAD YOUR PLAYLIST OR FILE/URL',
                                      isPhone: isPhone,
                                      isTablet: isTablet,
                                      onTap: () {
                                        Get.toNamed(screenM3uLogin);
                                      },
                                    ),
                                    SizedBox(height: 2.h),
                                    MenuButton(
                                      icon: FontAwesomeIcons.download,
                                      title: 'LOAD YOUR DATA FROM DEVICE',
                                      isPhone: isPhone,
                                      isTablet: isTablet,
                                      onTap: () {
                                        Get.snackbar(
                                          'Info',
                                          'Load from device functionality',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: MenuButton(
                                        icon: FontAwesomeIcons.list,
                                        title: 'LOAD YOUR PLAYLIST OR FILE/URL',
                                        isPhone: isPhone,
                                        isTablet: isTablet,
                                        onTap: () {
                                          Get.toNamed(screenM3uLogin);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: isTablet ? 2.5.w : 1.5.w),
                                    Expanded(
                                      child: MenuButton(
                                        icon: FontAwesomeIcons.download,
                                        title: 'LOAD YOUR DATA FROM DEVICE',
                                        isPhone: isPhone,
                                        isTablet: isTablet,
                                        onTap: () {
                                          Get.snackbar(
                                            'Info',
                                            'Load from device functionality',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: 2.h),

                          // Second row - two buttons
                          isPhone
                              ? Column(
                                  children: [
                                    MenuButton(
                                      icon: FontAwesomeIcons.code,
                                      title: 'LOGIN WITH XTREAM CODES API',
                                      isPhone: isPhone,
                                      isTablet: isTablet,
                                      onTap: () {
                                        Get.toNamed(screenRegisterTv);
                                      },
                                    ),
                                    SizedBox(height: 2.h),
                                    MenuButton(
                                      icon: FontAwesomeIcons.play,
                                      title: 'PLAY SINGLE STREAM',
                                      isPhone: isPhone,
                                      isTablet: isTablet,
                                      onTap: () {
                                        Get.snackbar(
                                          'Info',
                                          'Play single stream functionality',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: MenuButton(
                                        icon: FontAwesomeIcons.code,
                                        title: 'LOGIN WITH XTREAM CODES API',
                                        isPhone: isPhone,
                                        isTablet: isTablet,
                                        onTap: () {
                                          Get.toNamed(screenRegisterTv);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: isTablet ? 2.5.w : 1.5.w),
                                    Expanded(
                                      child: MenuButton(
                                        icon: FontAwesomeIcons.play,
                                        title: 'PLAY SINGLE STREAM',
                                        isPhone: isPhone,
                                        isTablet: isTablet,
                                        onTap: () {
                                          Get.snackbar(
                                            'Info',
                                            'Play single stream functionality',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: 2.h),

                          // Third row - single centered button
                          Center(
                            child: SizedBox(
                              width: isPhone
                                  ? double.infinity
                                  : (isTablet ? 280 : 320),
                              child: MenuButton(
                                icon: FontAwesomeIcons.users,
                                title: 'LIST USERS',
                                isPhone: isPhone,
                                isTablet: isTablet,
                                onTap: () {
                                  Get.toNamed(screenUserList);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Footer text
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: isPhone ? 2.h : 1.5.h,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'By using this application, you agree to the ',
                      style: Get.textTheme.bodySmall!.copyWith(
                        color: Colors.white.withAlpha(204),
                        fontSize: isPhone ? 10.sp : 11.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    InkWell(
                      onTap: () async {
                        await launchUrlString(kPrivacy);
                      },
                      child: Text(
                        'Terms of Services.',
                        style: Get.textTheme.bodySmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isPhone ? 10.sp : 11.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
}

class MenuButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isPhone;
  final bool isTablet;

  const MenuButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isPhone = false,
    this.isTablet = false,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool isHovered = false;
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() {
          isFocused = focused;
        });
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isPhone ? 4.w : (widget.isTablet ? 3.w : 2.w),
              vertical: widget.isPhone ? 2.h : (widget.isTablet ? 1.8.h : 1.5.h),
            ),
            decoration: BoxDecoration(
              color: isHovered || isFocused
                  ? Colors.white
                  : Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: isHovered || isFocused ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  widget.icon,
                  color: kColorPrimary,
                  size: widget.isPhone ? 16.sp : (widget.isTablet ? 14.sp : 13.sp),
                ),
                SizedBox(width: widget.isPhone ? 3.w : (widget.isTablet ? 2.w : 1.5.w)),
                Expanded(
                  child: Text(
                    widget.title,
                    style: Get.textTheme.bodyMedium!.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.isPhone
                          ? 10.sp
                          : (widget.isTablet ? 10.sp : 9.sp),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

