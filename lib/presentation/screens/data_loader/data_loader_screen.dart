import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:evoflix/helpers/helpers.dart';
import 'package:evoflix/logic/blocs/categories/live_caty/live_caty_bloc.dart';
import 'package:evoflix/logic/blocs/categories/movie_caty/movie_caty_bloc.dart';
import 'package:evoflix/logic/blocs/categories/series_caty/series_caty_bloc.dart';
import 'package:evoflix/logic/cubits/data_loader/data_loader_cubit.dart';
import 'package:evoflix/repository/models/progress_step.dart';

class DataLoaderScreen extends StatefulWidget {
  const DataLoaderScreen({super.key});

  @override
  State<DataLoaderScreen> createState() => _DataLoaderScreenState();
}

class _DataLoaderScreenState extends State<DataLoaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _waveAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  final Map<ProgressStep, String> stepTitles = {
    ProgressStep.userInfo: 'Connecting...',
    ProgressStep.categories: 'Preparing Categories',
    ProgressStep.liveChannels: 'Loading Live Channels',
    ProgressStep.movies: 'Loading Movies',
    ProgressStep.series: 'Loading Series',
  };

  final Map<ProgressStep, IconData> stepIcons = {
    ProgressStep.userInfo: Icons.wifi,
    ProgressStep.categories: Icons.category,
    ProgressStep.liveChannels: Icons.live_tv,
    ProgressStep.movies: Icons.movie,
    ProgressStep.series: Icons.tv,
  };

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveAnimationController, curve: Curves.linear),
    );

    _startLoading();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  Future<void> _startLoading() async {
    final cubit = context.read<DataLoaderCubit>();
    final success = await cubit.loadAllData();

    if (success) {
      _animationController.animateTo(1.0);
      _pulseAnimationController.stop();
      _waveAnimationController.stop();
      await Future.delayed(const Duration(milliseconds: 800));

      // Trigger the Blocs to load categories for the Welcome screen
      if (mounted) {
        context.read<LiveCatyBloc>().add(GetLiveCategories());
        context.read<MovieCatyBloc>().add(GetMovieCategories());
        context.read<SeriesCatyBloc>().add(GetSeriesCategories());
      }

      // Navigate to welcome screen
      Get.offAllNamed(screenWelcome);
    }
  }

  double _getProgressValue(ProgressStep step) {
    switch (step) {
      case ProgressStep.userInfo:
        return 0.2;
      case ProgressStep.categories:
        return 0.4;
      case ProgressStep.liveChannels:
        return 0.6;
      case ProgressStep.movies:
        return 0.8;
      case ProgressStep.series:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: BlocConsumer<DataLoaderCubit, DataLoaderState>(
          listener: (context, state) {
            if (state is DataLoaderLoading) {
              _animationController.animateTo(
                _getProgressValue(state.currentStep),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Section - Logo
                    _buildTopSection(),

                    // Middle Section - Current Step
                    _buildMiddleSection(state),

                    // Bottom Section - Progress
                    _buildBottomSection(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF00d4ff),
                      Color(0xFF0099cc),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00d4ff).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          kAppName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Loading your content...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMiddleSection(DataLoaderState state) {
    return Column(
      children: [
        // Wave Animation
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer waves
                  for (int i = 0; i < 3; i++)
                    Transform.scale(
                      scale: 1 + (i * 0.3) + (_waveAnimation.value * 0.5),
                      child: Container(
                        width: 120 + (i * 20),
                        height: 120 + (i * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00d4ff).withOpacity(
                              (1 - _waveAnimation.value) * (0.3 - i * 0.1),
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  // Center icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00d4ff),
                          Color(0xFF0099cc),
                        ],
                      ),
                    ),
                    child: Icon(
                      stepIcons[state.currentStep],
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        Text(
          stepTitles[state.currentStep]!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Progress indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ProgressStep.values.map((step) {
            bool isActive = step.index <= state.currentStep.index;
            bool isCurrent = step == state.currentStep;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isCurrent ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive
                    ? const Color(0xFF00d4ff)
                    : Colors.white.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomSection(DataLoaderState state) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00d4ff),
                            Color(0xFF0099cc),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF00d4ff),
                  ),
                ),
              ],
            );
          },
        ),

        // Error handling
        if (state is DataLoaderError) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Error Occurred',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Unknown error',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(screenMenu);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00d4ff),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
