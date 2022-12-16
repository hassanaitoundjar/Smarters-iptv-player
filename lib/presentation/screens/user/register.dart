part of '../screens.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key}) : super(key: key);

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('register page'),
      ),
      body: Ink(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.read<LiveCatyBloc>().add(GetLiveCategories());
              context.read<MovieCatyBloc>().add(GetMovieCategories());
              //  context.read<MovieCatyBloc>().add(GetMovieCategories());

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
              child: TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthRegister());
                  },
                  child: const Text('click to continue')),
            );
          },
        ),
      ),
    );
  }
}
