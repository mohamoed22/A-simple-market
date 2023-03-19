class HttpException implements Exception {
  // ignore: prefer_typing_uninitialized_variables
  final message;
  HttpException(this.message);

  @override
  String toString() {
    return message;
    //return super.toString();
  }
}
