part of 'screens.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 10),
        child: Column(
          children: [
            const AppBarWelcome(),
            SizedBox(height: 5.h),
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
                              subTitle: "${state.categories.length} Channels",
                              icon: kIconLive,
                              onTap: () {
                                Get.toNamed(screenLive);
                              },
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: CardWelcomeTv(
                        title: "Movies",
                        subTitle: "230 Movies",
                        icon: kIconMovies,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: CardWelcomeTv(
                        title: "Series",
                        subTitle: "1244 Channels",
                        icon: kIconSeries,
                        onTap: () {},
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
                            onTap: () {},
                          ),
                          CardWelcomeSetting(
                            title: 'Multi-Screen',
                            icon: FontAwesomeIcons.layerGroup,
                            onTap: () {},
                          ),
                          CardWelcomeSetting(
                            title: 'Settings',
                            icon: FontAwesomeIcons.gear,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
