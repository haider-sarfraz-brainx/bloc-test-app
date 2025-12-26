abstract class UseCase<ReturnType, Params> {
  Future<ReturnType> call(Params params);
}

abstract class UseCaseNoParams<ReturnType> {
  Future<ReturnType> call();
}

abstract class UseCaseSync<ReturnType, Params> {
  ReturnType call(Params params);
}

abstract class UseCaseSyncNoParams<ReturnType> {
  ReturnType call();
}

