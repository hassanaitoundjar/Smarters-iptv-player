part of '../screens.dart';

class RegisterUserTv extends StatefulWidget {
  const RegisterUserTv({super.key});

  @override
  State<RegisterUserTv> createState() => _RegisterUserTvState();
}

class _RegisterUserTvState extends State<RegisterUserTv>
    with SingleTickerProviderStateMixin {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _domain = TextEditingController();

  int indexTab = 0;

  final FocusNode focusNode0 = FocusNode();
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode _remoteFocus = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  void _onKey(KeyEvent event) {
    final action = RemoteControlHandler.handleKeyEvent(event);
    
    if (action == null) return;
    
    debugPrint("Remote Action: $action");
    
    switch (action) {
      case RemoteAction.navigateDown:
        debugPrint('Navigate Down');
        if (indexTab == 0) {
          indexTab = 1;
        } else if (indexTab == 1) {
          indexTab = 2;
        } else if (indexTab == 2) {
          indexTab = 3;
        }
        setState(() {});
        break;
        
      case RemoteAction.navigateUp:
        debugPrint('Navigate Up');
        if (indexTab == 1) {
          indexTab = 0;
        } else if (indexTab == 2) {
          indexTab = 1;
        } else if (indexTab == 3) {
          indexTab = 2;
        }
        setState(() {});
        break;
        
      case RemoteAction.select:
        debugPrint("Select/Enter");
        if (indexTab == 0) {
          focusNode0.requestFocus();
        } else if (indexTab == 1) {
          focusNode1.requestFocus();
        } else if (indexTab == 2) {
          focusNode2.requestFocus();
        } else if (indexTab == 3) {
          debugPrint("Login");
          _login();
        }
        break;
        
      case RemoteAction.back:
        // Go back to menu
        Get.back();
        break;
        
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode0.requestFocus();

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
    _domain.dispose();
    _username.dispose();
    _password.dispose();
    focusNode0.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    _remoteFocus.dispose();
    _animationController.dispose();

    super.dispose();
  }

  _login() {
    if (_username.text.isNotEmpty &&
        _password.text.isNotEmpty &&
        _domain.text.isNotEmpty) {
      context.read<AuthBloc>().add(AuthRegister(
            _username.text,
            _password.text,
            _domain.text,
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
      onKeyEvent: _onKey,
      child: Scaffold(
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
                  'Login failed.',
                  'Please check your IPTV credentials and try again.',
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            EvoFlixLogo(
                              size: isPhone ? 20.w : (isTablet ? 12.w : 10.w),
                              showGlow: true,
                            ),
                            SizedBox(height: 1.h),

                            // Title
                            Text(
                              kAppName,
                              style: Get.textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isPhone
                                    ? 18.sp
                                    : (isTablet ? 16.sp : 15.sp),
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 1.h),

                            Text(
                              'Sign in to your account',
                              style: Get.textTheme.bodyMedium!.copyWith(
                                color: Colors.white70,
                                fontSize: isPhone
                                    ? 12.sp
                                    : (isTablet ? 11.sp : 10.sp),
                              ),
                            ),
                            SizedBox(height: 3.h),

                            // Login Form Container
                            Container(
                              width: isPhone
                                  ? getSize(context).width * 0.85
                                  : (isTablet
                                      ? getSize(context).width * 0.6
                                      : getSize(context).width * 0.45),
                              padding: EdgeInsets.all(
                                  isPhone ? 6.w : (isTablet ? 4.w : 3.w)),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A0933).withAlpha(220),
                                borderRadius: BorderRadius.circular(20),
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Username Field
                                  _buildInputField(
                                    label: 'Username',
                                    controller: _username,
                                    icon: FontAwesomeIcons.solidUser,
                                    focusNode: focusNode0,
                                    isFocused: indexTab == 0,
                                    isPhone: isPhone,
                                    isTablet: isTablet,
                                  ),
                                  SizedBox(height: 2.h),

                                  // Password Field
                                  _buildInputField(
                                    label: 'Password',
                                    controller: _password,
                                    icon: FontAwesomeIcons.lock,
                                    focusNode: focusNode1,
                                    isFocused: indexTab == 1,
                                    isPhone: isPhone,
                                    isTablet: isTablet,
                                    obscureText: true,
                                  ),
                                  SizedBox(height: 2.h),

                                  // Domain/URL Field
                                  _buildInputField(
                                    label:
                                        'Server URL (http://example.com:8080)',
                                    controller: _domain,
                                    icon: FontAwesomeIcons.server,
                                    focusNode: focusNode2,
                                    isFocused: indexTab == 2,
                                    isPhone: isPhone,
                                    isTablet: isTablet,
                                  ),
                                  SizedBox(height: 3.h),

                                  // Login Button
                                  Focus(
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        setState(() => indexTab = 3);
                                      }
                                    },
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: indexTab == 3
                                            ? const Color(0xFF6B2F8E)
                                            : const Color(0xFF8E44AD),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isPhone ? 2.h : 1.8.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: indexTab == 3 ? 8 : 4,
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'LOGIN',
                                              style: TextStyle(
                                                fontSize: isPhone
                                                    ? 14.sp
                                                    : (isTablet
                                                        ? 12.sp
                                                        : 11.sp),
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),

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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required FocusNode focusNode,
    required bool isFocused,
    required bool isPhone,
    required bool isTablet,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFF6B2F8E) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: const Color(0xFF6B2F8E).withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        onTap: () {
          final index = focusNode == focusNode0
              ? 0
              : focusNode == focusNode1
                  ? 1
                  : 2;
          setState(() => indexTab = index);
        },
        style: TextStyle(
          color: Colors.black87,
          fontSize: isPhone ? 13.sp : (isTablet ? 11.sp : 10.sp),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isPhone ? 11.sp : (isTablet ? 10.sp : 9.sp),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF6B2F8E),
            size: isPhone ? 18.sp : (isTablet ? 16.sp : 14.sp),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: isPhone ? 2.h : 1.5.h,
          ),
        ),
      ),
    );
  }
}
