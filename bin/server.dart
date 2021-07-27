import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'converter.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(application);

  var multiHandler = shelf.Cascade().add(movieHandler).add(application).handler;

  var server = await io.serve(multiHandler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

shelf.Response application(shelf.Request request) {
  if (request.requestedUri.path == '/') {
    print(request.requestedUri.path);
    var bodyJson = JsonEncoder().convert({'body': '${request.url}'});
    return shelf.Response.ok(bodyJson);
  }
  return shelf.Response.notFound('Not found');
}

shelf.Response movieHandler(shelf.Request request) {
  print(request.handlerPath);
  if (request.requestedUri.path == '/movies') {
    var movies = CSVConverter.Init();
    return shelf.Response.ok('movies');
  }
  return shelf.Response.notFound('Not found');
}
