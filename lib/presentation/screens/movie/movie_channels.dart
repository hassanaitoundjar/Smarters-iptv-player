part of '../screens.dart';

class MovieChannels extends StatefulWidget {
  final String catyId;

  const MovieChannels({Key? key, required this.catyId}) : super(key: key);

  @override
  State<MovieChannels> createState() => _MovieChannelsState();
}

class _MovieChannelsState extends State<MovieChannels> {
  @override
  void initState() {
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          typeCategory: TypeCategory.movies,
          catyId: widget.catyId,
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        padding: EdgeInsets.only(top: 5.h, left: 10, right: 10),
        child: Column(
          children: [
            const AppBarLive(),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, stateAuth) {
                if (stateAuth is AuthSuccess) {
                  final userAuth = stateAuth.user;

                  return Expanded(
                    child: BlocBuilder<ChannelsBloc, ChannelsState>(
                      builder: (context, state) {
                        if (state is ChannelsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is ChannelsMovieSuccess) {
                          final channels = state.channels;

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: channels.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: .7,
                            ),
                            itemBuilder: (_, i) {
                              return CardChannelMovieItem(
                                title: channels[i].name,
                                image: channels[i].streamIcon,
                                onTap: () {
                                  final link =
                                      "${userAuth.serverInfo!.serverUrl}/movie/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${channels[i].streamId}.${channels[i].containerExtension}";
                                  debugPrint("Lunch movie: $link");
                                  Get.to(() => FullVideoScreen(link: link));
                                },
                              );
                            },
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CardChannelMovieItem extends StatelessWidget {
  const CardChannelMovieItem(
      {Key? key, required this.onTap, this.title, this.image})
      : super(key: key);
  final Function() onTap;
  final String? title;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      focusColor: kColorFocus,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: kColorCardLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: CachedNetworkImage(
                  imageUrl: image ?? "",
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, i, e) {
                    return const SizedBox();
                  },
                  placeholder: (_, i) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title ?? 'null',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.textTheme.headline6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
