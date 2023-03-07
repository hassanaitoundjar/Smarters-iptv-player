part of '../screens.dart';

class CatchUpScreen extends StatefulWidget {
  const CatchUpScreen({Key? key}) : super(key: key);

  @override
  State<CatchUpScreen> createState() => _CatchUpScreenState();
}

class _CatchUpScreenState extends State<CatchUpScreen> {
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Column(
          children: [
            const AppBarCatchUp(),
            SizedBox(
              width: 100.w,
              height: 45,
              child: Row(
                children: [
                  Expanded(
                    child: CardButtonWatchMovie(
                      title: "Movies",
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
                      title: "Series",
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
                ],
              ),
            ),
            SizedBox(height: 8.h),
            [
              const ContinueWatchingMovies(),
              const ContinueWatchingSeries()
            ][indexPage],
          ],
        ),
      ),
    );
  }
}
