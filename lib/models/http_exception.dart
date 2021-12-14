//implements uses a class (Exception in this case) is like signing a contract saying you are forced to implement ALL functions the class has.
//we are making this custom HttpException to allow us to see the error message by overriding the normal .toString method (which would normally just
//return 'Instance of HTTP Exception' which is worthless)
class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
    // return super.toString(); //this would be the "Instance of HttpException"
  }
}
