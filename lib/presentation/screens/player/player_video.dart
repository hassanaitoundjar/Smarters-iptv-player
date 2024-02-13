part of '../screens.dart';

class StreamPlayerPage extends StatefulWidget {
  const StreamPlayerPage({super.key, required this.controller});
  final VlcPlayerController? controller;

  @override
  State<StreamPlayerPage> createState() => _StreamPlayerPageState();
}

class _StreamPlayerPageState extends State<StreamPlayerPage> {
  bool isPlayed = true;

  bool showControllersVideo = true;
  late Timer timer;

  @override
  void initState() {
    Wakelock.enable();
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (showControllersVideo) {
        setState(() {
          showControllersVideo = false;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) {
      return const Center(
        child: Text(
          'Select a player...',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return Ink(
      color: Colors.black,
      width: getSize(context).width,
      height: getSize(context).height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VlcPlayer(
            controller: widget.controller!,
            aspectRatio: 16 / 9,
            placeholder: const Center(child: CircularProgressIndicator()),
          ),

          GestureDetector(
            onTap: () {
              debugPrint("click");
              setState(() {
                showControllersVideo = !showControllersVideo;
              });
            },
            child: Container(
              width: getSize(context).width,
              height: getSize(context).height,
              color: Colors.transparent,
            ),
          ),

          ///Controllers
          BlocBuilder<VideoCubit, VideoState>(
            builder: (context, state) {
              if (!state.isFull) {
                return const SizedBox();
              }

              return SizedBox(
                width: getSize(context).width,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: !showControllersVideo
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: IconButton(
                                    focusColor: kColorFocus,
                                    onPressed: () {
                                      context
                                          .read<VideoCubit>()
                                          .changeUrlVideo(false);
                                      //Get.back();
                                    },
                                    icon: const Icon(
                                        FontAwesomeIcons.chevronRight),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              focusColor: kColorFocus,
                              onPressed: () {
                                if (isPlayed) {
                                  widget.controller!.pause();
                                  isPlayed = false;
                                } else {
                                  widget.controller!.play();
                                  isPlayed = true;
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                isPlayed
                                    ? FontAwesomeIcons.pause
                                    : FontAwesomeIcons.play,
                                size: 24.sp,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
