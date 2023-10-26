part of '../screens.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        child: Column(
          children: [
            const IntroImageAnimated(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 15, bottom: 10),
                child: Column(
                  children: [
                    Text(
                      "Watch films anywhere\nand anytime",
                      textAlign: TextAlign.center,
                      style: Get.textTheme.headlineLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Enjoy watching your favorite movies\nwherever and whenever you like"
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Get.textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 15.sp,
                      ),
                    ),
                    const Spacer(),
                    CardTallButton(
                      label: "Add User",
                      onTap: () => Get.toNamed(screenRegister),
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
