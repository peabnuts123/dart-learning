import 'dart:io';

// Config
/// Host the web server will bind to
final String host = 'localhost';

/// Port number the web server will bind to
const int port = 9080;

/// File that the web server will send when requested for _any_ resource
final File targetFile = File('web/index.html');

Future main() async {
  // The server instance that will survive the duration of the application
  HttpServer server;

  // Validate targetFile exists before starting the web server
  if (!(await targetFile.exists())) {
    throw FileSystemException(
        "Target file '${targetFile.path}' does not exist. Cannot start web server");
  }
  print('Target file: ${targetFile.path}.');

  // Attempt to start/bind web server
  try {
    server = await HttpServer.bind(host, port);
    print('Server running on http://${host}:${port}/');
  } catch (e) {
    // I just don't know what went wrong 6_9
    stderr.writeln('Failed to start web server: ${e}');
    exit(1);
  }

  // Asyncronously iterate through each request the server has
  // This is a "smart" way of saying "Handle every request the server receives"
  await for (HttpRequest req in server) {
    // Log request details
    print('${req.method}: ${req.uri}\t[${req.headers.value('user-agent')}]');

    // Set content type
    req.response.headers.contentType = ContentType.html;

    // Set body content
    try {
      await req.response.addStream(targetFile.openRead());
    } catch (e) {
      throw FileSystemException("Couldn't read file: $e");
    }

    // Send / "close" response
    await req.response.close();
  }
}
