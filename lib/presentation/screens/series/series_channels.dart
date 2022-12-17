part of '../screens.dart';

class SeriesChannels extends StatefulWidget {
  final String catyId;

  const SeriesChannels({Key? key, required this.catyId}) : super(key: key);

  @override
  State<SeriesChannels> createState() => SeriesChannelsState();
}

class SeriesChannelsState extends State<SeriesChannels> {
  @override
  void initState() {
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          typeCategory: TypeCategory.series,
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
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            const AppBarSeries(),
            Expanded(
              child: BlocBuilder<ChannelsBloc, ChannelsState>(
                builder: (context, state) {
                  if (state is ChannelsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChannelsSeriesSuccess) {
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
                          image: channels[i].cover,
                          onTap: () {
                            /*Get.to(() => MovieContent(
                                videoId: channels[i].streamId ?? ''));*/
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
