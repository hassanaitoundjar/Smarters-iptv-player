part of '../screens.dart';

class SeriesCategoriesScreen extends StatefulWidget {
  const SeriesCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<SeriesCategoriesScreen> createState() => _SeriesCategoriesScreenState();
}

class _SeriesCategoriesScreenState extends State<SeriesCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10),
        child: Column(
          children: [
            const AppBarSeries(),
            const SizedBox(height: 15),
            Expanded(
              child: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                builder: (context, state) {
                  if (state is SeriesCatyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SeriesCatySuccess) {
                    final categories = state.categories;
                    return GridView.builder(
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 4.9,
                      ),
                      itemBuilder: (_, i) {
                        return CardLiveItem(
                          title: categories[i].categoryName ?? "",
                          onTap: () {
                            // OPEN Channels
                            Get.to(() => SeriesChannels(
                                catyId: categories[i].categoryId ?? ''));
                          },
                        );
                      },
                    );
                  }

                  return const Center(
                    child: Text("Failed to load data..."),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
