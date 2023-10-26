part of 'screens.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late InterstitialAd _interstitialAd;
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
    context.read<FavoritesCubit>().initialData();
    context.read<WatchingCubit>().initialData();
    _loadIntel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        child: Column(
          children: [
            const AppBarWelcome(),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                        builder: (context, state) {
                          if (state is LiveCatyLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is LiveCatySuccess) {
                            return CardWelcomeTv(
                              title: "LIVE TV",
                              autoFocus: true,
                              subTitle: "${state.categories.length} Channels",
                              icon: kIconLive,
                              onTap: () {
                                Get.toNamed(screenLiveCategories)!
                                    .then((value) async {
                                  debugPrint("show interstitial");
                                  _interstitialAd.show();
                                  await _loadIntel();
                                });
                              },
                            );
                          }

                          return const Text('error live caty');
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                        builder: (context, state) {
                          if (state is MovieCatyLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is MovieCatySuccess) {
                            return CardWelcomeTv(
                              title: "Movies",
                              subTitle: "${state.categories.length} Channels",
                              icon: kIconMovies,
                              onTap: () {
                                Get.toNamed(screenMovieCategories)!
                                    .then((value) async {
                                  await _interstitialAd.show();
                                  await _loadIntel();
                                });
                              },
                            );
                          }

                          return const Text('error movie caty');
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                        builder: (context, state) {
                          if (state is SeriesCatyLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is SeriesCatySuccess) {
                            return CardWelcomeTv(
                              title: "Series",
                              subTitle: "${state.categories.length} Channels",
                              icon: kIconSeries,
                              onTap: () {
                                Get.toNamed(screenSeriesCategories)!
                                    .then((value) async {
                                  await _interstitialAd.show();
                                  await _loadIntel();
                                });
                              },
                            );
                          }

                          return const Text('could not load series');
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    SizedBox(
                      width: 20.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CardWelcomeSetting(
                            title: 'Catch up',
                            icon: FontAwesomeIcons.rotate,
                            onTap: () {
                              Get.toNamed(screenCatchUp);
                            },
                          ),
                          CardWelcomeSetting(
                            title: 'Favourites',
                            icon: FontAwesomeIcons.heart,
                            onTap: () {
                              Get.toNamed(screenFavourite);
                            },
                          ),
                          CardWelcomeSetting(
                            title: 'Settings',
                            icon: FontAwesomeIcons.gear,
                            onTap: () {
                              Get.toNamed(screenSettings);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'By using this application, you agree to the',
                  style: Get.textTheme.titleSmall!.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await launchUrlString(kPrivacy);
                  },
                  child: Text(
                    ' Terms of Services.',
                    style: Get.textTheme.titleSmall!.copyWith(
                      fontSize: 12.sp,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            AdmobWidget.getBanner(),
          ],
        ),
      ),
    );
  }
}
