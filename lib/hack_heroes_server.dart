class AppServer {
  AppServer();

  Future<void> start(int port) async {
    print('Server started on localhost:$port');
  }
}