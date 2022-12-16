part of 'widgets.dart';

class AppBarLive extends StatelessWidget {
  const AppBarLive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 11.h,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: kDecorIconCircle,
            child: Icon(
              FontAwesomeIcons.video,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            kAppName,
            style: Get.textTheme.headline4,
          ),
          Container(
            width: 1,
            height: 8.h,
            margin: const EdgeInsets.symmetric(horizontal: 13),
            color: kColorHint,
          ),
          Image(height: 9.h, image: const AssetImage(kIconLive)),
          const Spacer(),
          IconButton(
            focusColor: kColorFocus,
            onPressed: () {},
            icon: const Icon(
              FontAwesomeIcons.magnifyingGlass,
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

class CardLiveItem extends StatelessWidget {
  const CardLiveItem(
      {Key? key,
      required this.title,
      required this.onTap,
      this.isSelected = false,
      this.link})
      : super(key: key);
  final String title;
  final Function() onTap;
  final bool isSelected;
  final String? link;

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
            Icon(
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
                style: Get.textTheme.headline5!.copyWith(
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
