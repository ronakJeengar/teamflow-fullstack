import '../error/failures.dart';

String mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case AuthFailure _:
      return failure.message;
    case ServerFailure _:
      return 'Something went wrong. Please try again.';
    case CacheFailure _:
      return 'No cached data available.';
    default:
      return 'Unexpected error occurred.';
  }
}
