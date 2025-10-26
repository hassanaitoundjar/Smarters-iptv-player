part of '../screens.dart';

class M3uLoginScreen extends StatefulWidget {
  const M3uLoginScreen({Key? key}) : super(key: key);

  @override
  State<M3uLoginScreen> createState() => _M3uLoginScreenState();
}

class _M3uLoginScreenState extends State<M3uLoginScreen> with SingleTickerProviderStateMixin {
  final _m3uUrlController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _m3uUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _parseAndLogin() {
    final txt = _m3uUrlController.text.trim();
    
    if (txt.isEmpty) {
      showWarningToast(
        context,
        'Error',
        'Please enter your M3U URL',
      );
      return;
    }

    if (Uri.tryParse(txt)?.hasAbsolutePath ?? false) {
      Uri url = Uri.parse(txt);
      var parameters = url.queryParameters;
      
      final username = parameters['username']?.toString() ?? '';
      final password = parameters['password']?.toString() ?? '';
      final domain = "${url.scheme}://${url.host}${url.hasPort ? ":${url.port}" : ""}";
      
      debugPrint("Parsed - Domain: $domain, Username: $username");

      if (username.isNotEmpty && password.isNotEmpty && domain.isNotEmpty) {
        context.read<AuthBloc>().add(AuthRegister(
          username,
          password,
          domain,
        ));
      } else {
        showWarningToast(
          context,
          'Invalid URL',
          'Could not extract username and password from URL',
        );
      }
    } else {
      showWarningToast(
        context,
        'Invalid URL',
        'Please enter a valid M3U URL',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = getSize(context).width;
    final bool isPhone = width < 600;
    final bool isTablet = width >= 600 && width < 950;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              // Navigate to data loader screen which will load all categories
              Get.offAndToNamed(screenDataLoader);
            } else if (state is AuthFailed) {
              showWarningToast(
                context,
                'Login failed',
                'Please check your M3U URL and try again.',
              );
              debugPrint(state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isPhone ? 6.w : 10.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            EvoFlixLogo(
                              size: isPhone ? 20.w : (isTablet ? 15.w : 12.w),
                              showGlow: true,
                            ),
                            SizedBox(height: 2.h),
                            
                            // Title
                            Text(
                              kAppName,
                              style: Get.textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isPhone ? 18.sp : (isTablet ? 16.sp : 15.sp),
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            
                            Text(
                              'Load Your Playlist',
                              style: Get.textTheme.bodyMedium!.copyWith(
                                color: Colors.white70,
                                fontSize: isPhone ? 12.sp : (isTablet ? 11.sp : 10.sp),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            
                            // M3U URL Container
                            Container(
                              width: isPhone 
                                  ? double.infinity
                                  : (isTablet ? getSize(context).width * 0.65 : getSize(context).width * 0.5),
                              padding: EdgeInsets.all(isPhone ? 6.w : (isTablet ? 4.w : 3.w)),
                              decoration: BoxDecoration(
                                color: kColorCardDark.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Info icon and text
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.circleInfo,
                                        color: kColorPrimary,
                                        size: isPhone ? 5.w : 2.5.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: Text(
                                          'Paste your M3U playlist URL',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: isPhone ? 12.sp : (isTablet ? 10.sp : 9.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3.h),
                                  
                                  // M3U URL Input
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kColorPrimary.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _m3uUrlController,
                                      maxLines: 4,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: isPhone ? 12.sp : (isTablet ? 10.sp : 9.sp),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'http://domain.com:8080/get.php?username=test&password=123\n\nor\n\nhttp://domain.com:8080/username/test/password/123',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: isPhone ? 11.sp : (isTablet ? 9.sp : 8.sp),
                                          height: 1.5,
                                        ),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Icon(
                                            FontAwesomeIcons.link,
                                            color: kColorPrimary,
                                            size: isPhone ? 18.sp : (isTablet ? 16.sp : 14.sp),
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                          vertical: 2.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  
                                  // Login Button
                                  ElevatedButton(
                                    onPressed: isLoading ? null : _parseAndLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kColorPrimary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isPhone ? 2.h : 1.8.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.circlePlay,
                                                size: isPhone ? 16.sp : 12.sp,
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                'LOAD PLAYLIST',
                                                style: TextStyle(
                                                  fontSize: isPhone ? 14.sp : (isTablet ? 12.sp : 11.sp),
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  SizedBox(height: 2.h),
                                  
                                  // OR divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white.withOpacity(0.3),
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: isPhone ? 11.sp : 9.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white.withOpacity(0.3),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),
                                  
                                  // Xtream Codes Login Button
                                  OutlinedButton(
                                    onPressed: () => Get.toNamed(screenRegisterTv),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 2,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: isPhone ? 1.8.h : 1.5.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.server,
                                          size: isPhone ? 14.sp : 11.sp,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'LOGIN WITH XTREAM CODES',
                                          style: TextStyle(
                                            fontSize: isPhone ? 12.sp : (isTablet ? 10.sp : 9.sp),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                            
                            // Back button
                            TextButton.icon(
                              onPressed: () => Get.offAllNamed(screenMenu),
                              icon: Icon(
                                FontAwesomeIcons.arrowLeft,
                                color: Colors.white70,
                                size: isPhone ? 14.sp : 12.sp,
                              ),
                              label: Text(
                                'Back to Menu',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isPhone ? 12.sp : 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

