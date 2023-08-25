part of '../screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullUrl = TextEditingController(
      text:
          "http://sniperstv.vip:8080/player_api.php?password=195576333764d3366d6e5e6&username=332265931841");

  final _username = TextEditingController();
  final _password = TextEditingController();
  final _url = TextEditingController();
  final _user = TextEditingController(text: "ff");

  _convertM3utoXtreme(style) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Past your M3u Link'),
        content: Material(
          color: Colors.transparent,
          child: TextField(
            controller: _fullUrl,
            decoration: InputDecoration(
              hintText:
                  "http://domain.tr:8080?get.php/username=test&password=123",
              hintStyle: Get.textTheme.bodyMedium!.copyWith(
                color: Colors.grey,
              ),
            ),
            style: style,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                _fullUrl.clear();
                Get.back();
              },
              child: Text(
                'Cancel',
                style: Get.textTheme.bodyMedium!.copyWith(
                  color: Colors.grey.shade400,
                ),
              )),
          TextButton(
              onPressed: () {
                var txt = _fullUrl.text;
                if (txt.isEmpty) {
                  return;
                }

                if (Uri.tryParse(txt)?.hasAbsolutePath ?? false) {
                  Uri url = Uri.parse(txt);
                  var parameters = url.queryParameters;
                  debugPrint("${url.scheme}://${url.host}:${url.port}");

                  _username.text = parameters['username'].toString();
                  _password.text = parameters['password'].toString();
                  _url.text =
                      "${url.scheme}://${url.host}${url.hasPort ? ":${url.port}" : ""}";
                  Get.back();
                } else {
                  debugPrint("this text is not url!!");
                  Get.snackbar("Error", "This data is not correct??");
                }
              },
              child: Text(
                'Save',
                style: Get.textTheme.bodyMedium!.copyWith(
                  color: kColorPrimary,
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _url.dispose();
    _username.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Get.textTheme.bodyMedium!.copyWith(
      color: Colors.white,
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: Ink(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, stateSetting) {
            return AzulEnvatoChecker(
              uniqueKey: stateSetting.setting,
              successPage: SafeArea(
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFailed) {
                      showWarningToast(
                        context,
                        'Login failed.',
                        'Please check your IPTV credentials and try again.',
                      );
                    } else if (state is AuthSuccess) {
                      context.read<LiveCatyBloc>().add(GetLiveCategories());
                      context.read<MovieCatyBloc>().add(GetMovieCategories());
                      context.read<SeriesCatyBloc>().add(GetSeriesCategories());
                      Get.offAndToNamed(screenWelcome);
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return IgnorePointer(
                      ignoring: isLoading,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () => Get.back(),
                                  icon: const Icon(
                                    FontAwesomeIcons.chevronLeft,
                                    color: Colors.white,
                                  )),
                              TextButton.icon(
                                icon: const Icon(
                                  FontAwesomeIcons.link,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _convertM3utoXtreme(style);
                                },
                                label: Text(
                                  'ADD M3U',
                                  style:
                                      Get.theme.textTheme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 1.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        kIconSplash,
                                        width: .7.dp,
                                        height: .7.dp,
                                        //  color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'SignIn to discover all movies & tv shows & lives tv,\nand enjoy our features.',
                                    textAlign: TextAlign.center,
                                    style: Get.textTheme.bodyLarge!.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  TextField(
                                    controller: _user,
                                    decoration: InputDecoration(
                                      hintText: "Account Name",
                                      hintStyle:
                                          Get.textTheme.bodyMedium!.copyWith(
                                        color: Colors.grey,
                                      ),
                                      suffixIcon: const Icon(
                                        FontAwesomeIcons.house,
                                        size: 18,
                                        color: kColorPrimary,
                                      ),
                                    ),
                                    style: style,
                                  ),
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: _username,
                                    decoration: InputDecoration(
                                      hintText: "Username",
                                      hintStyle:
                                          Get.textTheme.bodyMedium!.copyWith(
                                        color: Colors.grey,
                                      ),
                                      suffixIcon: const Icon(
                                        FontAwesomeIcons.solidUser,
                                        size: 18,
                                        color: kColorPrimary,
                                      ),
                                    ),
                                    style: style,
                                  ),
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: _password,
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      hintStyle:
                                          Get.textTheme.bodyMedium!.copyWith(
                                        color: Colors.grey,
                                      ),
                                      suffixIcon: const Icon(
                                        FontAwesomeIcons.lock,
                                        size: 18,
                                        color: kColorPrimary,
                                      ),
                                    ),
                                    style: style,
                                  ),
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: _url,
                                    decoration: InputDecoration(
                                      hintText: "http://url.domain.net:8080",
                                      hintStyle:
                                          Get.textTheme.bodyMedium!.copyWith(
                                        color: Colors.grey,
                                      ),
                                      suffixIcon: const Icon(
                                        FontAwesomeIcons.link,
                                        size: 18,
                                        color: kColorPrimary,
                                      ),
                                    ),
                                    style: style,
                                  ),
                                  const SizedBox(height: 15),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.solidCircle,
                                          color: Colors.white70,
                                          size: 12.sp,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'By registering, you are agreeing to our ',
                                          style: Get.textTheme.bodyMedium!
                                              .copyWith(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            var url = Uri.parse(kPrivacy);
                                            await launchUrl(url,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          },
                                          child: Text(
                                            'privacy policy.',
                                            style: Get.textTheme.bodyMedium!
                                                .copyWith(
                                              color: kColorPrimary
                                                  .withOpacity(.70),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CardTallButton(
                              label: "Add User",
                              isLoading: isLoading,
                              onTap: () {
                                //Get.toNamed(screenDownload)

                                if (_username.text.isNotEmpty &&
                                    _password.text.isNotEmpty &&
                                    _url.text.isNotEmpty &&
                                    _user.text.isNotEmpty) {
                                  context.read<AuthBloc>().add(AuthRegister(
                                        _username.text,
                                        _password.text,
                                        _url.text,
                                      ));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
