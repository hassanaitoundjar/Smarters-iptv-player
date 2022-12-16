part of '../screens.dart';

class ListLiveScreen extends StatefulWidget {
  const ListLiveScreen({Key? key}) : super(key: key);

  @override
  State<ListLiveScreen> createState() => _ListLiveScreenState();
}

class _ListLiveScreenState extends State<ListLiveScreen> {
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
            const AppBarLive(),
            const SizedBox(height: 15),
            Expanded(
              child: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                builder: (context, state) {
                  if (state is LiveCatyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LiveCatySuccess) {
                    final categories = state.categories;
                    return GridView.builder(
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 4,
                      ),
                      itemBuilder: (_, i) {
                        return CardLiveItem(
                          title: categories[i].categoryName ?? "",
                          onTap: () {
                            //TODO: OPEN Channels
                            Get.to(() => ListChannelsScreen(
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
