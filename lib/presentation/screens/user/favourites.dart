part of '../screens.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        child: Column(
          children: [
            const AppBarFav(),
            SizedBox(
              width: 100.w,
              height: 45,
              child: Row(
                children: [
                  Expanded(
                    child: CardButtonWatchMovie(
                      title: "Live",
                      // isFocused: true,
                      hideBorder: true,
                      isSelected: indexPage == 0,
                      index: 0,
                      onTap: () {
                        setState(() {
                          indexPage = 0;
                        });
                      },
                      onFocusChanged: (value) {
                        setState(() {
                          indexPage = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CardButtonWatchMovie(
                      title: "Movies",
                      hideBorder: true,
                      isSelected: indexPage == 1,
                      index: 1,
                      onTap: () {
                        setState(() {
                          indexPage = 1;
                        });
                      },
                      onFocusChanged: (value) {
                        setState(() {
                          indexPage = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CardButtonWatchMovie(
                      title: "Series",
                      hideBorder: true,
                      isSelected: indexPage == 2,
                      index: 2,
                      onTap: () {
                        setState(() {
                          indexPage = 2;
                        });
                      },
                      onFocusChanged: (value) {
                        setState(() {
                          indexPage = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: [
                const _FavLivePage(),
                const _FavMoviesPage(),
                const _FavSeriesPage(),
              ][indexPage],
            ),
          ],
        ),
      ),
    );
  }
}

class _FavLivePage extends StatelessWidget {
  const _FavLivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, stateAuth) {
        if (stateAuth is AuthSuccess) {
          final userAuth = stateAuth.user;
          return BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final lives = state.lives;
              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 6,
                ),
                itemCount: lives.length,
                itemBuilder: (_, i) {
                  return CardLiveItem(
                    title: lives[i].name ?? "",
                    onTap: () {
                      final link =
                          "${userAuth.serverInfo!.serverUrl}/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${lives[i].streamId}";
                      Get.to(() => FullVideoScreen(
                            isLive: true,
                            link: link,
                            title: lives[i].name ?? "",
                          ));
                    },
                  );
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _FavMoviesPage extends StatelessWidget {
  const _FavMoviesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, stateAuth) {
        if (stateAuth is AuthSuccess) {
          // final userAuth = stateAuth.user;
          return BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final movies = state.movies;
              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: .7,
                ),
                itemCount: movies.length,
                itemBuilder: (_, i) {
                  return CardChannelMovieItem(
                    title: movies[i].name ?? "",
                    image: movies[i].streamIcon,
                    onTap: () {
                      Get.to(() => MovieContent(
                              channelMovie: movies[i],
                              videoId: movies[i].streamId ?? ''))!
                          .then((value) async {
                        //  _interstitialAd.show();
                        // _loadIntel();
                      });
                    },
                  );
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _FavSeriesPage extends StatelessWidget {
  const _FavSeriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, stateAuth) {
        if (stateAuth is AuthSuccess) {
          // final userAuth = stateAuth.user;
          return BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final series = state.series;
              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: .7,
                ),
                itemCount: series.length,
                itemBuilder: (_, i) {
                  return CardChannelMovieItem(
                    title: series[i].name ?? "",
                    image: series[i].cover,
                    onTap: () {
                      Get.to(() => SerieContent(
                              channelSerie: series[i],
                              videoId: series[i].seriesId ?? ''))!
                          .then((value) async {
                        //  _interstitialAd.show();
                        // _loadIntel();
                      });
                    },
                  );
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
