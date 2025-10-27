part of '../screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  goScreen(String screen) {
    Future.delayed(const Duration(seconds: 3)).then((value) {
      Get.offAndToNamed(screen);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (isTv(context)) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
          ]);
        }
        context.read<SettingsCubit>().getSettingsCode();
        context.read<AuthBloc>().add(AuthGetUser());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("width: ${MediaQuery.of(context).size.width}");
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        //bool isPortrait = orientation == Orientation.portrait;

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              // Check if categories are already loaded
              final liveCatyState = context.read<LiveCatyBloc>().state;
              final movieCatyState = context.read<MovieCatyBloc>().state;
              final seriesCatyState = context.read<SeriesCatyBloc>().state;
              
              final categoriesLoaded = 
                  liveCatyState is LiveCatySuccess &&
                  movieCatyState is MovieCatySuccess &&
                  seriesCatyState is SeriesCatySuccess;
              
              if (categoriesLoaded) {
                // Categories already loaded, go directly to welcome screen
                goScreen(screenWelcome);
              } else {
                // First time login, load all data
                goScreen(screenDataLoader);
              }
            } else if (state is AuthFailed) {
              if (isTv(context)) {
                goScreen(screenRegisterTv);
              } else {
                goScreen(screenMenu);
              }
            }
          },
          child: const LoadingWidget(),
        );
      }),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getSize(context).width,
      height: getSize(context).height,
      decoration: kDecorBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EvoFlixLogo(
            size: getSize(context).height * .22,
            showGlow: true,
          ),
          const SizedBox(height: 20),
          Text(
            kAppName,
            style: Get.textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: const CircularProgressIndicator(),
                );
              } else if (state is AuthFailed) {
                return const Text('');
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
