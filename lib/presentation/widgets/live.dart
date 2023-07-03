part of 'widgets.dart';

class AppBarLive extends StatefulWidget {
  const AppBarLive({
    Key? key,
    this.onSearch,
    this.isLiked = false,
    this.onLike,
  }) : super(key: key);
  final Function(String)? onSearch;
  final bool isLiked;
  final Function()? onLike;

  @override
  State<AppBarLive> createState() => _AppBarLiveState();
}

class _AppBarLiveState extends State<AppBarLive> {
  bool showSearch = false;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Image(
            width: 90,
            height: 90,
            image: AssetImage(kIconSplash),
          ),
          const SizedBox(width: 5),
          Text(
            kAppName,
            style: Get.textTheme.headlineMedium,
          ),
          Container(
            width: 1,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 13),
            color: kColorHint,
          ),
          const Image(height: 80, image: AssetImage(kIconLive)),
          const Spacer(),
          showSearch
              ? Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 15),
                    child: TextField(
                      controller: _search,
                      onChanged: widget.onSearch,
                      decoration: const InputDecoration(
                        hintText: "Search...",
                      ),
                    ),
                  ),
                )
              : const Spacer(),
          if (showSearch)
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.xmark,
                color: Colors.white,
              ),
              focusColor: kColorPrimary,
              onPressed: () {
                if (widget.onSearch != null) {
                  widget.onSearch!("");
                }

                setState(() {
                  showSearch = false;
                  _search.clear();
                });
              },
            ),
          if (!showSearch)
            IconButton(
              focusColor: kColorFocus,
              onPressed: () {
                setState(() {
                  showSearch = true;
                });
              },
              icon: const Icon(
                FontAwesomeIcons.magnifyingGlass,
                color: Colors.white,
              ),
            ),
          if (widget.onLike != null)
            IconButton(
              focusColor: kColorFocus,
              onPressed: widget.onLike,
              icon: Icon(
                widget.isLiked
                    ? FontAwesomeIcons.solidHeart
                    : FontAwesomeIcons.heart,
                color: Colors.white,
              ),
            ),
          IconButton(
            focusColor: kColorFocus,
            onPressed: () {
              context.read<VideoCubit>().changeUrlVideo(false);
              Get.back();
            },
            icon: const Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBarMovie extends StatefulWidget {
  const AppBarMovie(
      {Key? key,
      this.onSearch,
      this.onFavorite,
      this.top,
      this.isLiked = false})
      : super(key: key);

  final Function()? onFavorite;
  final Function(String)? onSearch;
  final double? top;
  final bool isLiked;

  @override
  State<AppBarMovie> createState() => _AppBarMovieState();
}

class _AppBarMovieState extends State<AppBarMovie> {
  bool showSearch = false;
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: widget.top ?? 2.h),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            const Image(
              width: 90,
              height: 90,
              image: AssetImage(kIconSplash),
            ),
            const SizedBox(width: 5),
            Text(
              kAppName,
              style: Get.textTheme.headlineMedium,
            ),
            Container(
              width: 1,
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 13),
              color: kColorHint,
            ),
            const Image(height: 90, image: const AssetImage(kIconMovies)),
            const Spacer(),
            showSearch
                ? Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: TextField(
                        controller: _search,
                        onChanged: widget.onSearch,
                        decoration: const InputDecoration(
                          hintText: "Search...",
                        ),
                      ),
                    ),
                  )
                : const Spacer(),
            if (showSearch)
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.xmark,
                  color: Colors.white,
                ),
                focusColor: kColorPrimary,
                onPressed: () {
                  if (widget.onSearch != null) {
                    widget.onSearch!("");
                  }

                  setState(() {
                    showSearch = false;
                    _search.clear();
                  });
                },
              ),
            if (widget.onSearch != null)
              if (!showSearch)
                IconButton(
                  focusColor: kColorFocus,
                  onPressed: () {
                    setState(() {
                      showSearch = true;
                    });
                  },
                  icon: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.white,
                  ),
                ),
            if (widget.onFavorite != null)
              IconButton(
                focusColor: kColorFocus,
                onPressed: widget.onFavorite,
                icon: Icon(
                  widget.isLiked
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  color: Colors.white,
                ),
              ),
            IconButton(
              focusColor: kColorFocus,
              onPressed: () {
                context.read<VideoCubit>().changeUrlVideo(false);
                Get.back();
              },
              icon: const Icon(
                FontAwesomeIcons.chevronRight,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarSeries extends StatefulWidget {
  const AppBarSeries(
      {Key? key,
      this.onSearch,
      this.onFavorite,
      this.top,
      this.isLiked = false})
      : super(key: key);

  final Function()? onFavorite;
  final Function(String)? onSearch;
  final double? top;
  final bool isLiked;

  @override
  State<AppBarSeries> createState() => _AppBarSeriesState();
}

class _AppBarSeriesState extends State<AppBarSeries> {
  bool showSearch = false;
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.only(top: widget.top ?? 4.h, left: 10, right: 10),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Image(
              width: 0.3.dp,
              height: 0.3.dp,
              image: const AssetImage(kIconSplash),
            ),
            const SizedBox(width: 5),
            Text(
              kAppName,
              style: Get.textTheme.headlineMedium,
            ),
            Container(
              width: 1,
              height: 8.h,
              margin: const EdgeInsets.symmetric(horizontal: 13),
              color: kColorHint,
            ),
            Image(height: 9.h, image: const AssetImage(kIconSeries)),
            const Spacer(),
            showSearch
                ? Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: TextField(
                        controller: _search,
                        onChanged: widget.onSearch,
                        decoration: const InputDecoration(
                          hintText: "Search...",
                        ),
                      ),
                    ),
                  )
                : const Spacer(),
            if (showSearch)
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.xmark,
                  color: Colors.white,
                ),
                focusColor: kColorPrimary,
                onPressed: () {
                  if (widget.onSearch != null) {
                    widget.onSearch!("");
                  }

                  setState(() {
                    showSearch = false;
                    _search.clear();
                  });
                },
              ),
            if (widget.onSearch != null)
              if (!showSearch)
                IconButton(
                  focusColor: kColorFocus,
                  onPressed: () {
                    setState(() {
                      showSearch = true;
                    });
                  },
                  icon: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.white,
                  ),
                ),
            if (widget.onFavorite != null)
              IconButton(
                focusColor: kColorFocus,
                onPressed: widget.onFavorite,
                icon: Icon(
                  widget.isLiked
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  color: Colors.white,
                ),
              ),
            IconButton(
              focusColor: kColorFocus,
              onPressed: () {
                context.read<VideoCubit>().changeUrlVideo(false);
                Get.back();
              },
              icon: const Icon(
                FontAwesomeIcons.chevronRight,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarSettings extends StatelessWidget {
  const AppBarSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: Colors.transparent,
      //  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Image(
            width: 0.3.dp,
            height: 0.3.dp,
            image: const AssetImage(kIconSplash),
          ),
          const SizedBox(width: 5),
          Text(
            "Settings",
            style: Get.textTheme.headlineMedium,
          ),
          Container(
            width: 1,
            height: 8.h,
            margin: const EdgeInsets.symmetric(horizontal: 13),
            color: kColorHint,
          ),
          Icon(
            FontAwesomeIcons.gear,
            size: 20.sp,
            color: Colors.white,
          ),
          const Spacer(),
          IconButton(
            focusColor: kColorFocus,
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class CardLiveItem extends StatelessWidget {
  const CardLiveItem(
      {Key? key,
      required this.title,
      required this.onTap,
      this.isSelected = false,
      this.link,
      this.image})
      : super(key: key);
  final String title;
  final Function() onTap;
  final bool isSelected;
  final String? link;
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
          border: isSelected ? Border.all(color: Colors.yellow) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            image != null && !isSelected
                ? CachedNetworkImage(
                    imageUrl: image ?? "",
                    width: 9.w,
                    errorWidget: (_, i, e) {
                      return Icon(
                        FontAwesomeIcons.tv,
                        size: isSelected ? 18.sp : 16.sp,
                        color: Colors.white,
                      );
                    },
                  )
                : Icon(
                    isSelected ? FontAwesomeIcons.play : FontAwesomeIcons.tv,
                    size: isSelected ? 18.sp : 16.sp,
                    color: Colors.white,
                  ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            if (isSelected && link != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  FontAwesomeIcons.expand,
                  size: 18.sp,
                  color: isSelected ? Colors.yellow : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppBarFav extends StatelessWidget {
  const AppBarFav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Image(
            width: 0.3.dp,
            height: 0.3.dp,
            image: const AssetImage(kIconSplash),
          ),
          const SizedBox(width: 5),
          Text(
            "Favourites",
            style: Get.textTheme.headlineMedium,
          ),
          Container(
            width: 1,
            height: 8.h,
            margin: const EdgeInsets.symmetric(horizontal: 13),
            color: kColorHint,
          ),
          Icon(
            FontAwesomeIcons.solidHeart,
            size: 20.sp,
            color: Colors.white,
          ),
          const Spacer(),
          IconButton(
            focusColor: kColorFocus,
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBarCatchUp extends StatelessWidget {
  const AppBarCatchUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Image(
            width: 0.3.dp,
            height: 0.3.dp,
            image: const AssetImage(kIconSplash),
          ),
          const SizedBox(width: 5),
          Text(
            "Catch Up",
            style: Get.textTheme.headlineMedium,
          ),
          Container(
            width: 1,
            height: 8.h,
            margin: const EdgeInsets.symmetric(horizontal: 13),
            color: kColorHint,
          ),
          Icon(
            FontAwesomeIcons.rotate,
            size: 20.sp,
            color: Colors.white,
          ),
          const Spacer(),
          IconButton(
            focusColor: kColorFocus,
            onPressed: () {
              context.read<WatchingCubit>().clearData();
            },
            icon: const Icon(
              FontAwesomeIcons.broom,
              color: Colors.white,
            ),
          ),
          IconButton(
            focusColor: kColorFocus,
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
