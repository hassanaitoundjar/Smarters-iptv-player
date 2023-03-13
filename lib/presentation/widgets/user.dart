part of 'widgets.dart';

class CardInputLogin extends StatefulWidget {
  const CardInputLogin({
    Key? key,
    required this.hint,
    this.controller,
    this.onChange,
    this.autofocus = false,
    required this.textInputAction,
    required this.onSubmitted,
  }) : super(key: key);
  final String hint;
  final TextEditingController? controller;
  final Function(String)? onChange;
  final TextInputAction textInputAction;
  final bool autofocus;
  final Function(String) onSubmitted;

  @override
  State<CardInputLogin> createState() => _CardInputLoginState();
}

class _CardInputLoginState extends State<CardInputLogin> {
  bool isFocused = false;

  final FocusNode node = FocusNode();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // node.requestFocus();
        setState(() {
          isFocused = true;
        });
      },
      onFocusChange: (value) {
        if (value) {
          node.requestFocus();
        }
        setState(() {
          isFocused = value;
        });
      },
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isFocused ? kColorPrimary : Colors.white,
            width: 3,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          focusNode: node,
          autofocus: widget.autofocus,
          onSubmitted: widget.onSubmitted,
          controller: widget.controller,
          onChanged: widget.onChange,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: Get.textTheme.subtitle2!.copyWith(
              color: Colors.grey,
            ),
            border: InputBorder.none,
          ),
          style: Get.textTheme.subtitle2!.copyWith(
            color: Colors.black,
          ),
          cursorColor: kColorPrimary,
        ),
      ),
    );
  }
}

class IntroImageAnimated extends StatefulWidget {
  const IntroImageAnimated({Key? key}) : super(key: key);

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
    debugPrint("start first one");

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
    final height = 50.h;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100.w,
          height: height,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Image.asset(
              kImageIntro,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Opacity(
          opacity: .5,
          child: Container(
            width: 100.w,
            height: height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kColorPrimary, kColorPrimaryDark],
              ),
            ),
          ),
        ),
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
