part of 'widgets.dart';

class ContinueWatchingMovies extends StatelessWidget {
  const ContinueWatchingMovies({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchingCubit, WatchingState>(
      builder: (context, state) {
        final watching = state.movies;
        if (watching.isEmpty) {
          return const SizedBox();
        }

        return SizedBox(
          width: 100.w,
          height: 60.h,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: watching.length,
            itemBuilder: (_, i) {
              return CardMovieContinueWatch(
                model: watching[i],
                onTap: () {
                  final model = watching[i];
                  
                  debugPrint('=== 🎬 CONTINUE WATCHING - MOVIE CLICKED ===');
                  debugPrint('streamId: ${model.streamId}');
                  debugPrint('sliderValue (position): ${model.sliderValue}s');
                  debugPrint('durationStrm (total): ${model.durationStrm}s');
                  debugPrint('Progress: ${(model.sliderValue / model.durationStrm * 100).toStringAsFixed(1)}%');
                  debugPrint('stream: ${model.stream}');
                  debugPrint('==========================================');
                  
                  // sliderValue now contains position in seconds
                  // durationStrm now contains total duration in seconds
                  final resumeSeconds = model.sliderValue;
                  
                  if (resumeSeconds <= 0) {
                    debugPrint('⚠️ WARNING: Invalid resume position: $resumeSeconds - Starting from beginning');
                  }
                  
                  Get.to(() => FullVideoScreen(
                            link: watching[i].stream,
                            title: watching[i].title,
                            streamId: watching[i].streamId,
                            imageUrl: watching[i].image,
                            isSeries: false,
                            resumePosition: resumeSeconds,
                          ))!
                      .then((slider) {
                    if (slider != null) {
                      var newMod = watching[i];
                      newMod.sliderValue = slider[0];
                      context.read<WatchingCubit>().addMovie(newMod);
                      // debugPrint("Value Slider: ${newMod.sliderValue}");
                    }
                  });
                },
              );
            },
            separatorBuilder: (_, i) {
              return const SizedBox(width: 10);
            },
          ),
        );
      },
    );
  }
}

class ContinueWatchingSeries extends StatelessWidget {
  const ContinueWatchingSeries({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchingCubit, WatchingState>(
      builder: (context, state) {
        final watching = state.series;

        if (watching.isEmpty) {
          return const SizedBox();
        }

        return SizedBox(
          width: 100.w,
          height: 60.h,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: watching.length,
            itemBuilder: (_, i) {
              final model = watching[i];

              return CardMovieContinueWatch(
                model: model,
                onTap: () {
                  // sliderValue now contains position in seconds
                  // durationStrm now contains total duration in seconds
                  final resumeSeconds = model.sliderValue;
                  
                  debugPrint('▶️ Resuming series from ${resumeSeconds.toInt()}s');
                  
                  Get.to(() => FullVideoScreen(
                            link: model.stream,
                            title: "Episode ${i + 1}: ${model.title}",
                            streamId: model.streamId,
                            imageUrl: model.image,
                            isSeries: true,
                            resumePosition: resumeSeconds,
                          ))!
                      .then((slider) {
                    debugPrint("DATA: $slider");
                    if (slider != null) {
                      var newMod = model;
                      newMod.sliderValue = slider;
                      context.read<WatchingCubit>().addSerie(newMod);
                    }
                  });
                },
              );
            },
            separatorBuilder: (_, i) {
              return const SizedBox(width: 10);
            },
          ),
        );
      },
    );
  }
}

class CardMovieContinueWatch extends StatelessWidget {
  const CardMovieContinueWatch(
      {super.key, required this.onTap, required this.model});

  final Function() onTap;
  final WatchingModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              width: 50.w,
              decoration: BoxDecoration(
                color: kColorCardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: model.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, i) {
                            return const CardNoImage();
                          },
                          errorWidget: (_, i, e) {
                            return const CardNoImage();
                          },
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTap,
                            child: Ink(
                              width: double.infinity,
                              height: double.infinity,
                              color: kColorCardDark.withOpacity(.5),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onTap,
                          child: Center(
                            child: Icon(
                              FontAwesomeIcons.circlePlay,
                              size: 26.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100.w,
                    height: 3,
                    child: Row(
                      children: [
                        Expanded(
                            flex: model.durationStrm > 0 
                                ? (model.sliderValue / model.durationStrm * 100).round()
                                : 0,
                            child: Container(
                              color: kColorPrimary,
                            )),
                        Expanded(
                            flex: model.durationStrm > 0
                                ? (100 - (model.sliderValue / model.durationStrm * 100)).round()
                                : 100,
                            child: Container(
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          model.title,
          maxLines: 1,
          style: Get.textTheme.bodyLarge!.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class CardNoImage extends StatelessWidget {
  const CardNoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: kColorCardDark,
      child: Center(
        child: Image.asset(
          kIconSplash,
          width: 30.sp,
          height: 30.sp,
        ),
      ),
    );
  }
}
