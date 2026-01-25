abstract interface class StreamUsecase<ReturnType, Params> {
  Stream<ReturnType> call(Params params);
}
