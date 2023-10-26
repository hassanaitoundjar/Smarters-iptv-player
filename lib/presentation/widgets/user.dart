part of 'widgets.dart';

class CardInputTv extends StatelessWidget {
  const CardInputTv(
      {super.key,
      this.controller,
      required this.label,
      required this.icon,
      required this.focusNode,
      required this.onTap,
      this.onEditingComplete,
      required this.isFocused,
      required this.isEnabled});
  final TextEditingController? controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final Function() onTap;
  final Function()? onEditingComplete;

  final bool isFocused, isEnabled;

  @override
  Widget build(BuildContext context) {
    final style = Get.textTheme.bodyMedium!.copyWith(
      color: Colors.black,
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
    );

    return SizedBox(
      width: getSize(context).width,
      height: 50,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFocused ? kColorPrimary : Colors.transparent,
              width: 3,
            ),
          ),
          padding: const EdgeInsets.only(left: 10),
          child: TextField(
            controller: controller,
            enabled: isEnabled,
            focusNode: focusNode,
            textInputAction: TextInputAction.next,
            onEditingComplete: onEditingComplete,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: Get.textTheme.bodyMedium!.copyWith(color: Colors.grey),
              suffixIcon: Icon(
                icon,
                size: 18,
                color: kColorPrimary,
              ),
              border: InputBorder.none,
            ),
            cursorColor: kColorPrimary,
            style: style,
          ),
        ),
      ),
    );
  }
}

class IntroImageAnimated extends StatefulWidget {
  final bool isTv;
  const IntroImageAnimated({super.key, this.isTv = false});

  @override
  State<IntroImageAnimated> createState() => _IntroImageAnimatedState();
}

class _IntroImageAnimatedState extends State<IntroImageAnimated> {
  late Timer timer;
  bool isImage = true;
  ScrollController controller = ScrollController();

  _startAnimation() async {
    const int second = 27;

    await Future.delayed(const Duration(milliseconds: 400));
    //debugPrint("start first one");

    await controller.animateTo(
      isImage ? controller.position.maxScrollExtent : 0,
      duration: const Duration(seconds: second),
      curve: Curves.linear,
    );

    setState(() {
      isImage = !isImage;
    });
    await _startAnimation();
  }

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    //  timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = getSize(context).height / (widget.isTv ? 1 : 2);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: getSize(context).width,
          height: height,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Image.asset(
              kImageIntro,
              fit: BoxFit.cover,
              width: getSize(context).width + 140,
            ),
          ),
        ),
        Opacity(
          opacity: widget.isTv ? 0 : .5,
          child: Container(
            width: getSize(context).width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isTv
                    ? [kColorBackDark]
                    : [kColorPrimary, kColorPrimaryDark],
              ),
            ),
          ),
        ),
        if (!widget.isTv)
          Column(
            children: [
              Image.asset(
                kIconSplash,
                width: 40.w,
                height: 40.w,
              ),
              Text(
                kAppName.toUpperCase(),
                textAlign: TextAlign.center,
                style: Get.textTheme.headlineLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
