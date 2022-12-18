part of '../screens.dart';

class LiveCategoriesScreen extends StatefulWidget {
  const LiveCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<LiveCategoriesScreen> createState() => _LiveCategoriesScreenState();
}

class _LiveCategoriesScreenState extends State<LiveCategoriesScreen> {
  final ScrollController _hideButtonController = ScrollController();
  bool _hideButton = true;

  @override
  void initState() {
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
      body: Ink(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        // padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10),
        child: NestedScrollView(
          controller: _hideButtonController,
          headerSliverBuilder: (_, ch) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: AppBarLive(),
                ),
              ),
            ];
          },
          body: BlocBuilder<LiveCatyBloc, LiveCatyState>(
            builder: (context, state) {
              if (state is LiveCatyLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LiveCatySuccess) {
                final categories = state.categories;
                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 4.8,
                  ),
                  itemBuilder: (_, i) {
                    return CardLiveItem(
                      title: categories[i].categoryName ?? "",
                      onTap: () {
                        //TODO: OPEN Channels
                        Get.to(() => LiveChannelsScreen(
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
      ),
    );
  }
}
