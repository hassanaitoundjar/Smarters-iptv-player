part of 'data_loader_cubit.dart';

@immutable
abstract class DataLoaderState {
  final ProgressStep currentStep;
  final String? errorMessage;
  final String? errorKey;

  const DataLoaderState({
    required this.currentStep,
    this.errorMessage,
    this.errorKey,
  });
}

class DataLoaderInitial extends DataLoaderState {
  DataLoaderInitial() : super(currentStep: ProgressStep.userInfo);
}

class DataLoaderLoading extends DataLoaderState {
  const DataLoaderLoading(ProgressStep step)
      : super(currentStep: step);
}

class DataLoaderSuccess extends DataLoaderState {
  DataLoaderSuccess() : super(currentStep: ProgressStep.series);
}

class DataLoaderError extends DataLoaderState {
  const DataLoaderError(String message, String? key, ProgressStep step)
      : super(
          currentStep: step,
          errorMessage: message,
          errorKey: key,
        );
}
