part of '../screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    final width = getSize(context).width;
    final bool isPhone = width < 600;
    final bool isTablet = width >= 600 && width < 950;

    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final userInfo = state.user;

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    slivers: [
                      // Modern App Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(isPhone ? 4.w : (isTablet ? 3.w : 2.w)),
                    child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isPhone ? 2.w : 1.5.w),
                                  decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [kColorPrimaryDark, kColorPrimary],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.gear,
                                  size: isPhone ? 20.sp : 18.sp,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: isPhone ? 3.w : 2.w),
                              Text(
                                "Settings",
                                style: Get.textTheme.headlineMedium!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isPhone ? 20.sp : (isTablet ? 18.sp : 16.sp),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: Icon(
                                  FontAwesomeIcons.xmark,
                                  color: Colors.white70,
                                  size: isPhone ? 18.sp : 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Content
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isPhone ? 4.w : (isTablet ? 3.w : 2.w),
                          vertical: 2.h,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: isPhone
                              ? _buildPhoneLayout(userInfo, isPhone, isTablet)
                              : _buildDesktopLayout(userInfo, isPhone, isTablet),
                        ),
                      ),

                      // Footer
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                                    'Created By: ',
                                    style: TextStyle(
                                      fontSize: isPhone ? 11.sp : 10.sp,
                                      color: Colors.white60,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await launchUrlString(
                            "https://mouadzizi.me",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                                      '@Azul Mouad',
                                      style: TextStyle(
                                        fontSize: isPhone ? 11.sp : 10.sp,
                                        color: kColorPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(UserModel userInfo, bool isPhone, bool isTablet) {
    return Column(
      children: [
        _buildAccountInfoCard(userInfo, isPhone, isTablet),
        SizedBox(height: 2.h),
        _buildSubscriptionCard(userInfo, isPhone, isTablet),
        SizedBox(height: 2.h),
        _buildActionButton(
          icon: FontAwesomeIcons.arrowsRotate,
          title: 'Refresh All Data',
          color: kColorPrimary,
          isPhone: isPhone,
          isTablet: isTablet,
          onTap: () {
            context.read<LiveCatyBloc>().add(GetLiveCategories());
            context.read<MovieCatyBloc>().add(GetMovieCategories());
            context.read<SeriesCatyBloc>().add(GetSeriesCategories());
            Get.snackbar(
              'Success',
              'All data refreshed successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: kColorPrimary.withOpacity(0.8),
              colorText: Colors.white,
            );
            Get.back();
          },
        ),
        SizedBox(height: 1.5.h),
        _buildActionButton(
          icon: FontAwesomeIcons.userPlus,
          title: 'Add New User',
          color: const Color(0xFF6B2F8E),
          isPhone: isPhone,
          isTablet: isTablet,
          onTap: () {
            context.read<AuthBloc>().add(AuthLogOut());
            Get.offAllNamed(screenMenu);
          },
        ),
        SizedBox(height: 1.5.h),
        _buildActionButton(
          icon: FontAwesomeIcons.rightFromBracket,
          title: 'Log Out',
          color: const Color(0xFFFF6B9D),
          isPhone: isPhone,
          isTablet: isTablet,
          onTap: () {
            context.read<AuthBloc>().add(AuthLogOut());
            Get.offAllNamed("/");
            Get.reload();
          },
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(UserModel userInfo, bool isPhone, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Info cards
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildAccountInfoCard(userInfo, isPhone, isTablet),
              SizedBox(height: 2.h),
              _buildSubscriptionCard(userInfo, isPhone, isTablet),
            ],
          ),
        ),
        SizedBox(width: 3.w),
        // Right side - Action buttons
        Expanded(
          child: Column(
            children: [
              _buildActionButton(
                icon: FontAwesomeIcons.arrowsRotate,
                title: 'Refresh All Data',
                color: kColorPrimary,
                isPhone: isPhone,
                isTablet: isTablet,
                onTap: () {
                  context.read<LiveCatyBloc>().add(GetLiveCategories());
                  context.read<MovieCatyBloc>().add(GetMovieCategories());
                  context.read<SeriesCatyBloc>().add(GetSeriesCategories());
                  Get.snackbar(
                    'Success',
                    'All data refreshed successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: kColorPrimary.withOpacity(0.8),
                    colorText: Colors.white,
                  );
                  Get.back();
                },
              ),
              SizedBox(height: 2.h),
              _buildActionButton(
                icon: FontAwesomeIcons.userPlus,
                title: 'Add New User',
                color: const Color(0xFF6B2F8E),
                isPhone: isPhone,
                isTablet: isTablet,
                onTap: () {
                  context.read<AuthBloc>().add(AuthLogOut());
                  Get.offAllNamed(screenMenu);
                },
              ),
              SizedBox(height: 2.h),
              _buildActionButton(
                icon: FontAwesomeIcons.rightFromBracket,
                title: 'Log Out',
                color: const Color(0xFFFF6B9D),
                isPhone: isPhone,
                isTablet: isTablet,
                onTap: () {
                  context.read<AuthBloc>().add(AuthLogOut());
                  Get.offAllNamed("/");
                  Get.reload();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(UserModel userInfo, bool isPhone, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 5.w : (isTablet ? 4.w : 3.w)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isPhone ? 2.w : 1.5.w),
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FontAwesomeIcons.user,
                  size: isPhone ? 16.sp : 14.sp,
                  color: kColorPrimary,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Account Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPhone ? 16.sp : (isTablet ? 14.sp : 13.sp),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Username',
            userInfo.userInfo?.username ?? 'N/A',
            FontAwesomeIcons.solidUser,
            isPhone,
            isTablet,
          ),
          SizedBox(height: 1.5.h),
          _buildInfoRow(
            'Password',
            userInfo.userInfo?.password ?? 'N/A',
            FontAwesomeIcons.lock,
            isPhone,
            isTablet,
          ),
          SizedBox(height: 1.5.h),
          _buildInfoRow(
            'Server URL',
            userInfo.serverInfo?.serverUrl ?? 'N/A',
            FontAwesomeIcons.server,
            isPhone,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(UserModel userInfo, bool isPhone, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 5.w : (isTablet ? 4.w : 3.w)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isPhone ? 2.w : 1.5.w),
                decoration: BoxDecoration(
                  color: kColorFocus.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FontAwesomeIcons.calendarDays,
                  size: isPhone ? 16.sp : 14.sp,
                  color: kColorFocus,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Subscription Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPhone ? 16.sp : (isTablet ? 14.sp : 13.sp),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Status',
            userInfo.userInfo?.status ?? 'N/A',
            FontAwesomeIcons.circleCheck,
            isPhone,
            isTablet,
          ),
          SizedBox(height: 1.5.h),
          _buildInfoRow(
            'Expiration Date',
            userInfo.userInfo?.expDate != null
                ? expirationDate(userInfo.userInfo!.expDate)
                : 'N/A',
            FontAwesomeIcons.clock,
            isPhone,
            isTablet,
          ),
          SizedBox(height: 1.5.h),
          _buildInfoRow(
            'Active Connections',
            userInfo.userInfo?.activeCons ?? 'N/A',
            FontAwesomeIcons.plug,
            isPhone,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isPhone, bool isTablet) {
    return Row(
      children: [
        Icon(
          icon,
          size: isPhone ? 12.sp : 11.sp,
          color: Colors.white70,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: isPhone ? 11.sp : 10.sp,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPhone ? 13.sp : (isTablet ? 12.sp : 11.sp),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required bool isPhone,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isPhone ? 3.h : 2.5.h,
          horizontal: isPhone ? 4.w : 3.w,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: isPhone ? 16.sp : 14.sp,
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isPhone ? 14.sp : (isTablet ? 13.sp : 12.sp),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
