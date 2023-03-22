part of '../screens.dart';

class SeriesChannels extends StatefulWidget {
  final String catyId;

  const SeriesChannels({Key? key, required this.catyId}) : super(key: key);

  @override
  State<SeriesChannels> createState() => SeriesChannelsState();
}

class SeriesChannelsState extends State<SeriesChannels> {
  final ScrollController _hideButtonController = ScrollController();
  bool _hideButton = true;
  String keySearch = "";

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
    _loadIntel();
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          typeCategory: TypeCategory.series,
          catyId: widget.catyId,
        ));
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_hideButton == true) {
          setState(() {
            _hideButton = false;
          });
        }
      } else {
        if (_hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_hideButton == false) {
            setState(() {
              _hideButton = true;
            });
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: !_hideButton,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _hideButtonController.animateTo(0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease);
              _hideButton = true;
            });
          },
          backgroundColor: kColorPrimaryDark,
          child: const Icon(
            FontAwesomeIcons.chevronUp,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Ink(
            width: 100.w,
            height: 100.h,
            decoration: kDecorBackground,
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: NestedScrollView(
              controller: _hideButtonController,
              headerSliverBuilder: (_, ch) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: AppBarSeries(
                        top: 3.h,
                        onSearch: (String value) {
                          setState(() {
                            keySearch = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),
                ];
              },
              body: BlocBuilder<ChannelsBloc, ChannelsState>(
                builder: (context, state) {
                  if (state is ChannelsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChannelsSeriesSuccess) {
                    final channels = state.channels;
                    final List<ChannelSerie> searchList = channels
                        .where((element) =>
                            element.name!.toLowerCase().contains(keySearch))
                        .toList();

                    return GridView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 80,
                        top: 10,
                      ),
                      itemCount: keySearch.isEmpty
                          ? channels.length
                          : searchList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: .7,
                      ),
                      itemBuilder: (_, i) {
                        final model =
                            keySearch.isEmpty ? channels[i] : searchList[i];

                        return CardChannelMovieItem(
                          title: model.name,
                          image: model.cover,
                          onTap: () {
                            Get.to(() => SerieContent(
                                    channelSerie: model,
                                    videoId: model.seriesId ?? ''))!
                                .then((value) async {
                              _interstitialAd.show();
                              _loadIntel();
                            });
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
          AdmobWidget.getBanner(),
        ],
      ),
    );
  }
}
