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

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  @override
  void dispose() {
    _domain.dispose();
    _username.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return AzulEnvatoChecker(
            uniqueKey: state.setting,
            successPage: Ink(
              width: 100.w,
              height: 100.h,
              decoration: kDecorBackground,
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    context.read<LiveCatyBloc>().add(GetLiveCategories());
                    context.read<MovieCatyBloc>().add(GetMovieCategories());
                    context.read<SeriesCatyBloc>().add(GetSeriesCategories());

                    Get.offAndToNamed(screenWelcome);
                  } else if (state is AuthFailed) {
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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            width: 0.55.dp,
                            height: 0.55.dp,
                            image: const AssetImage(kIconSplash),
                          ),
                          Center(
                            child: Ink(
                              width: 90.w,
                              // height: 70.h,
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CardInputLogin(
                                    textInputAction: TextInputAction.next,
                                    autofocus: true,
                                    controller: _username,
                                    hint: 'username',
                                    onSubmitted: (_) {},
                                  ),
                                  const SizedBox(height: 15),
                                  CardInputLogin(
                                    textInputAction: TextInputAction.next,
                                    controller: _password,
                                    hint: 'password',
                                    onSubmitted: (_) {},
                                  ),
                                  const SizedBox(height: 15),
                                  CardInputLogin(
                                    textInputAction: TextInputAction.send,
                                    controller: _domain,
                                    hint: 'http://domain:port',
                                    onSubmitted: (_) {
                                      print("domain: $_");
                                      FocusScope.of(context).unfocus();
                                      if (_username.text.isNotEmpty &&
                                          _password.text.isNotEmpty &&
                                          _domain.text.isNotEmpty) {
                                        context
                                            .read<AuthBloc>()
                                            .add(AuthRegister(
                                              _username.text,
                                              _password.text,
                                              _domain.text,
                                            ));
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: 100.w,
                                    height: 50,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: CardButtonWatchMovie(
                                            onTap: () {
                                              if (_username.text.isNotEmpty &&
                                                  _password.text.isNotEmpty &&
                                                  _domain.text.isNotEmpty) {
                                                context
                                                    .read<AuthBloc>()
                                                    .add(AuthRegister(
                                                      _username.text,
                                                      _password.text,
                                                      _domain.text,
                                                    ));
                                              }
                                            },
                                            title: 'Login',
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        CardButtonWatchMovie(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            _username.clear();
                                            _password.clear();
                                            _domain.clear();
                                          },
                                          title: 'reload',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
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
                                      mode: LaunchMode.externalApplication);
                                },
                                child: Text(
                                  'contact us',
                                  style: Get.textTheme.headline5!.copyWith(
                                    color: kColorPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
