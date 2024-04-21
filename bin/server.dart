// import 'dart:io';
//
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart';
// import 'package:shelf_router/shelf_router.dart';
//
// // Configure routes.
// final _router = Router()
//   ..get('/', _rootHandler)
//   ..get('/echo/<message>', _echoHandler);
//
// Response _rootHandler(Request req) {
//   return Response.ok('Hello, World!\n');
// }
//
// Response _echoHandler(Request request) {
//   final message = request.params['message'];
//   return Response.ok('$message\n');
// }
//
// void main(List<String> args) async {
//   // Use any available host or container IP (usually `0.0.0.0`).
//   final ip = InternetAddress.anyIPv4;
//
//   // Configure a pipeline that logs requests.
//   final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router.call);
//
//   // For running in containers, we respect the PORT environment variable.
//   final port = int.parse(Platform.environment['PORT'] ?? '8080');
//   final server = await serve(handler, ip, port);
//   print('Server listening on port ${server.port}');
// }

import 'dart:convert';
import 'dart:io';

Future<List<String>> readLinesFromFile(File file) async {
  return file
      .openRead()
      .map(utf8.decode)
      .transform(const LineSplitter())
      .toList();
}

List<String> extractTitles(List<String> lines) {
  return lines.first.split(',');
}

List<Map<String, dynamic>> parseLinesToMaps(
    List<String> lines, List<String> titles) {
  return lines.sublist(1).map((line) {
    final data = line.split(',');
    Map<String, dynamic> map = <String, dynamic>{};
    map = parseLineToMap(data, titles);
    map.addAll({'start_date': DateTime.fromMicrosecondsSinceEpoch(int.parse(map['time_start'])).toIso8601String()});
    return map;
  }).toList();
}

Map<String, dynamic> parseLineToMap(List<String> data, List<String> titles) {
  return Map.fromIterables(titles, data);
}

void writeJsonToFile(List<Map<String, dynamic>> data, String filePath) {
  final buffer = StringBuffer();
  buffer.write(jsonEncode(data));
  File(filePath)
      .writeAsStringSync(buffer.toString(), mode: FileMode.write, flush: true);
}

void main() async {
  final file = File('bin/csv/time_zone.csv');

  final lines = await readLinesFromFile(file);
  final titles = extractTitles(lines);
  final parsedData = parseLinesToMaps(lines, titles);

  writeJsonToFile(parsedData, 'bin/csv/parsed.json');
}
