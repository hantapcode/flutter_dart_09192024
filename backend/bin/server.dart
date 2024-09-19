import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Ccau hinh cac routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/api/v1/check', _checkHandle)
  ..get('/api/v1/echo/<message>', _echoHandler)
  ..get('/api/v1/submit', _submitHandler);
final _headers = {'Content-Type': 'application/json'};
// ham su ly asc yeu cau goc tai duong dan '/'
// tra ve 1 phan hoi voi thong diep "hello , world"duoi dang json
//"reg": doi tuong yeu cau tu client
// tra ve : mot doi tuong " response" voi trang thai 200 va noi dung 200

Response _rootHandler(Request req) {
  //contructor "ok" cua response co statuscode la 200
  return Response.ok(
    json.encode({'message': 'lmao lmao??'}),
    headers: _headers,
  );
}

// ham su ly yeu cau tai /v1/check
Response _checkHandle(Request req) {
  return Response.ok(
    json.encode({'message': "chao mung lmao vang kun "}),
    headers: _headers,
  );
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Future<Response> _submitHandler(Request reg) async {
  try {
    // doc payload tu request
    final payload = await reg.readAsString();
    // giai ma json tu payload
    final data = json.decode(payload);
    // kiem tra neu ten hop le
    final name = data['name'] as String?;
    //triem tra neu ten hop le
    if (name != null && name.isNotEmpty) {
      // taop phan hoi chao mung
      final response = {'message': "chao mung $name"};
      // tra ve phan hoi voi status code 200 va  noi dung json
      return Response.ok(
        json.encode(response),
        headers: _headers,
      );
    } else {
      // tao phan hoi yeu cau voi yeu cau cung cap ten
      final response = {'message': "server khong nhan duoc ten cua ban ."};
      // tra ve phan hoi voi status code 400 va  noi dung json
      return Response.badRequest(
        body: json.encode(response),
        headers: _headers,
      );
    }
  } catch (e) {
    final errorResponese = {
      'message': 'yeu cau k hop le , loi ${e.toString()}'
    };
    return Response.badRequest(
      body: json.encode(errorResponese),
      headers: _headers,
    );
  }
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
