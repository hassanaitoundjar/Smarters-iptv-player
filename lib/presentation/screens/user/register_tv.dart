part of '../screens.dart';

class RegisterUserTv extends StatefulWidget {
  const RegisterUserTv({Key? key}) : super(key: key);

  @override
  State<RegisterUserTv> createState() => _RegisterUserTvState();
}

class _RegisterUserTvState extends State<RegisterUserTv> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _domain = TextEditingController();

  int indexTab = 0;

  final FocusNode focusNode0 = FocusNode();
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode _remoteFocus = FocusNode();

  _onKey(RawKeyEvent event) {
    debugPrint("EVENT");
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      debugPrint('downd');

      if (indexTab == 0) {
        indexTab = 1;
      } else if (indexTab == 1) {
        indexTab = 2;
      } else if (indexTab == 2) {
        indexTab = 3;
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      debugPrint('up');
      if (indexTab == 0) {
      } else if (indexTab == 1) {
        indexTab = 0;
      } else if (indexTab == 2) {
        indexTab = 1;
      } else if (indexTab == 3) {
        indexTab = 2;
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.select)) {
      debugPrint("enter");

      if (indexTab == 0) {
        focusNode0.requestFocus();
      } else if (indexTab == 1) {
        focusNode1.requestFocus();
      } else if (indexTab == 2) {
        focusNode2.requestFocus();
      } else if (indexTab == 3) {
        debugPrint("Login");
        _login();
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    focusNode0.requestFocus();
  }

  @override
  void dispose() {
    _domain.dispose();
    _username.dispose();
    _password.dispose();
    focusNode0.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    _remoteFocus.dispose();

    super.dispose();
  }

  _login() {
    if (_username.text.isNotEmpty &&
        _password.text.isNotEmpty &&
        _domain.text.isNotEmpty) {
      context.read<AuthBloc>().add(AuthRegister(
            _username.text,
            _password.text,
            _domain.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _remoteFocus,
      onKey: _onKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return AzulEnvatoChecker(
              uniqueKey: state.setting,
              successPage: Stack(
                children: [
                  ///Background
                  const Opacity(
                    opacity: .1,
                    child: IntroImageAnimated(isTv: true),
                  ),

                  Ink(
                    width: getSize(context).width,
                    height: getSize(context).height,
                    decoration: kDecorBackground,
                    child: BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          context.read<LiveCatyBloc>().add(GetLiveCategories());
                          context
                              .read<MovieCatyBloc>()
                              .add(GetMovieCategories());
                          context
                              .read<SeriesCatyBloc>()
                              .add(GetSeriesCategories());

                          Get.offAndToNamed(screenWelcome);
                        } else if (state is AuthFailed) {
                          showWarningToast(
                            context,
                            'Login failed.',
                            'Please check your IPTV credentials and try again.',
                          );
                          debugPrint(state.message);
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                width: getSize(context).height * .22,
                                height: getSize(context).height * .22,
                                image: const AssetImage(kIconSplash),
                              ),
                              Center(
                                child: Ink(
                                  width: getSize(context).width * .9,
                                  decoration: BoxDecoration(
                                      gradient: kDecorBackground.gradient,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black38,
                                          blurRadius: 5,
                                        )
                                      ]),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 20,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 15),
                                        CardInputTv(
                                          label: "username",
                                          controller: _username,
                                          icon: FontAwesomeIcons.solidUser,
                                          focusNode: focusNode0,
                                          isEnabled: indexTab == 0,
                                          isFocused: indexTab == 0,
                                          onEditingComplete: null,
                                          onTap: () {
                                            setState(() {
                                              indexTab = 0;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        CardInputTv(
                                          label: "password",
                                          controller: _password,
                                          icon: FontAwesomeIcons.lock,
                                          focusNode: focusNode1,
                                          isEnabled: indexTab == 1,
                                          isFocused: indexTab == 1,
                                          onTap: () {
                                            setState(() {
                                              indexTab = 1;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 15),
                                        CardInputTv(
                                          label: "http://example.ex:8080",
                                          controller: _domain,
                                          icon: FontAwesomeIcons.lock,
                                          focusNode: focusNode2,
                                          isEnabled: indexTab == 2,
                                          isFocused: indexTab == 2,
                                          onTap: () {
                                            setState(() {
                                              indexTab = 2;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 15),
                                        SizedBox(
                                          width: getSize(context).width,
                                          height: 50,
                                          child: CardButtonWatchMovie(
                                            isFocused: indexTab == 3,
                                            onFocusChanged: (value) {},
                                            onTap: () {
                                              _login();
                                            },
                                            title: 'Login',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              /*  SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "You don't have account? ",
                                    style: Get.textTheme.subtitle2!.copyWith(
                                      color: kColorCardDark,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await launchUrlString(kContact,
                                          mode:
                                              LaunchMode.externalApplication);
                                    },
                                    child: Text(
                                      'contact us',
                                      style:
                                          Get.textTheme.headline5!.copyWith(
                                        color: kColorPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),*/
                            ],
                          ),
                        );
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
  }
}
