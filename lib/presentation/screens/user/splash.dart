part of '../screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  goScreen(String screen) {
    Future.delayed(const Duration(seconds: 2)).then((value) {
      Get.offAndToNamed(screen);
    });
  }

  @override
  void initState() {
    context.read<AuthBloc>().add(AuthGetUser());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.read<LiveCatyBloc>().add(GetLiveCategories());
            context.read<MovieCatyBloc>().add(GetMovieCategories());
            context.read<SeriesCatyBloc>().add(GetSeriesCategories());
            goScreen(screenWelcome);
          } else if (state is AuthFailed) {
            goScreen(screenRegister);
          }
        },
        child: Container(
          width: 100.w,
          height: 100.h,
          decoration: kDecorBackground,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: kDecorIconCircle,
                child: Icon(
                  FontAwesomeIcons.video,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                kAppName,
                style: Get.textTheme.headline3,
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: const CircularProgressIndicator(),
                    );
                  } else if (state is AuthFailed) {
                    return const Text('Failed to Load user data');
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
