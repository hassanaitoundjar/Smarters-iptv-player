part of '../screens.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key}) : super(key: key);

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _fullUrl = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _domain = TextEditingController();

  @override
  void dispose() {
    _fullUrl.dispose();
    _username.dispose();
    _password.dispose();
    _domain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
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

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
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
                          controller: _fullUrl,
                          hint: 'full domain access',
                          onChange: (String txt) {
                            if (Uri.tryParse(txt)?.hasAbsolutePath ?? false) {
                              Uri url = Uri.parse(txt);
                              var parameters = url.queryParameters;
                              var origin = url.origin;
                              var host = url.host;
                              var port = url.port;

                              _username.text =
                                  parameters['username'].toString();
                              _password.text =
                                  parameters['password'].toString();
                              _domain.text = "$origin:$port";
                            } else {
                              debugPrint("this text is not url!!");
                              Get.snackbar(
                                  "Error", "This data is not correct??");
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        CardInputLogin(
                          controller: _username,
                          hint: 'username',
                        ),
                        const SizedBox(height: 15),
                        CardInputLogin(
                          controller: _password,
                          hint: 'password',
                        ),
                        const SizedBox(height: 15),
                        CardInputLogin(
                          controller: _domain,
                          hint: 'http://domain:port',
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_username.text.isNotEmpty &&
                                _password.text.isNotEmpty &&
                                _domain.text.isNotEmpty) {
                              context.read<AuthBloc>().add(AuthRegister(
                                    _username.text,
                                    _password.text,
                                    _domain.text,
                                  ));
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(kColorPrimary),
                          ),
                          child: Text(
                            'Submit',
                            style: Get.textTheme.headline5,
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
                      onTap: () {},
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
            );
          },
        ),
      ),
    );
  }
}

class CardInputLogin extends StatelessWidget {
  const CardInputLogin(
      {Key? key, required this.hint, this.controller, this.onChange})
      : super(key: key);
  final String hint;
  final TextEditingController? controller;
  final Function(String)? onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        onChanged: onChange,
        decoration: InputDecoration(
          hintText: hint,
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
    );
  }
}
