import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mbark_iptv/repository/api/api.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'helpers/helpers.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/categories/channels/channels_bloc.dart';
import 'logic/blocs/categories/live_caty/live_caty_bloc.dart';
import 'logic/blocs/categories/movie_caty/movie_caty_bloc.dart';
import 'logic/blocs/categories/series_caty/series_caty_bloc.dart';
import 'logic/cubits/video/video_cubit.dart';
import 'presentation/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(MyApp(
    iptv: IpTvApi(),
    authApi: AuthApi(),
  ));
}

class MyApp extends StatefulWidget {
  final IpTvApi iptv;
  final AuthApi authApi;
  const MyApp({super.key, required this.iptv, required this.authApi});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    //Enable FullScreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    /*SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values); to disable full screen mode*/
    //change portrait mobile
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => AuthBloc(widget.authApi),
        ),
        BlocProvider<LiveCatyBloc>(
          create: (BuildContext context) => LiveCatyBloc(widget.iptv),
        ),
        BlocProvider<ChannelsBloc>(
          create: (BuildContext context) => ChannelsBloc(widget.iptv),
        ),
        BlocProvider<MovieCatyBloc>(
          create: (BuildContext context) => MovieCatyBloc(widget.iptv),
        ),
        BlocProvider<SeriesCatyBloc>(
          create: (BuildContext context) => SeriesCatyBloc(widget.iptv),
        ),
        BlocProvider<VideoCubit>(
          create: (BuildContext context) => VideoCubit(),
        ),
      ],
      child: ResponsiveSizer(
        builder: (context, orient, type) {
          return GetMaterialApp(
            title: 'Azul IPTV',
            theme: MyThemApp.themeData(context),
            debugShowCheckedModeBanner: false,
            initialRoute: "/",
            getPages: [
              GetPage(name: screenSplash, page: () => const SplashScreen()),
              GetPage(name: screenWelcome, page: () => const WelcomeScreen()),
              GetPage(
                  name: screenLiveCategories,
                  page: () => const LiveCategoriesScreen()),
              GetPage(name: screenRegister, page: () => const RegisterUser()),
              GetPage(
                  name: screenMovieCategories,
                  page: () => const MovieCategoriesScreen()),
              GetPage(
                  name: screenSeriesCategories,
                  page: () => const SeriesCategoriesScreen()),
            ],
          );
        },
      ),
    );
  }
}
