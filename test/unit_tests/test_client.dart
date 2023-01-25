import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:dart_mailgun/types.dart';

void main() {
  group('MGResponse', () {
    test('.ok() returns true when status code is 200', () {
      var httpResponse = http.Response('ok', 200);
      var response = Response(httpResponse);
      expect(response.ok(), true);
    });
    test('.ok() returns false when status code is 400', () {
      var httpResponse = http.Response('bad request', 400);
      var response = Response(httpResponse);
      expect(response.ok(), false);
    });

    test('.body parses json as map', () async {
      var httpResponse = http.Response('{"message": "ok"}', 200);
      var response = Response(httpResponse);
      var body = await response.body;
      expect(body, isNotNull);
      expect(body, isMap);
      expect(body!['message'], 'ok');
    });
    test('.body parses string response into map', () async {
      var httpResponse = http.Response('ok', 200);
      var response = Response(httpResponse);
      var body = await response.body;
      expect(body, isNotNull);
      expect(body, isMap);
      expect(body!['message'], 'ok');
    });
    test('.body parses StreamedResponse json as map', () async {
      var httpResponse = http.StreamedResponse(
          Stream.fromIterable([utf8.encode('{"message": "ok"}')]), 200);
      var response = Response(httpResponse);
      var body = await response.body;
      expect(body, isNotNull);
      expect(body, isMap);
      expect(body!['message'], 'ok');
    });
    test('.body parses StreamedResponse string response into map', () async {
      var httpResponse =
          http.StreamedResponse(Stream.fromIterable([utf8.encode('ok')]), 200);
      var response = Response(httpResponse);
      var body = await response.body;
      expect(body, isNotNull);
      expect(body, isMap);
      expect(body!['message'], 'ok');
    });
    test('.statusCode returns 200 when status code is 200', () {
      var httpResponse = http.Response('ok', 200);
      var response = Response(httpResponse);
      expect(response.statusCode, 200);
    });
    test('.reasonPhrase is null when status code is 200', () {
      var httpResponse = http.Response('ok', 200);
      var response = Response(httpResponse);
      expect(response.reasonPhrase, isNull);
    });
    test('.status().reason is not null when status code is 400', () {
      var httpResponse = http.Response('bad request', 400, reasonPhrase: 'bad');
      var response = Response(httpResponse);
      expect(response.reasonPhrase, isNotNull);
      expect(response.reasonPhrase, 'bad');
    });

    test('.status() parses exception as 500, toString()', () {
      var exception = Exception('test');
      var response = Response(exception);
      expect(response.statusCode, 500);
      expect(response.reasonPhrase, 'Exception: test');
    });
    test('.status() resturn 500, unknown error when result is unknown', () {
      var response = Response('test');
      expect(response.statusCode, 500);
      expect(response.reasonPhrase, 'Unknown Error');
    });
  }, tags: 'unit');
  group('MessageParams', () {
    test('toRequest() returns fields converted to request', () async {
      var current = Directory.current;
      var request =
          http.MultipartRequest('POST', Uri.parse('http://localhost'));
      var options = MessageParams(
          'from', ['to'], 'subject', MessageContent.text('text'),
          cc: ['cc'], bcc: ['bcc'], attachments: [File("${current.path}/test/unit_tests/140x100.png")]);
      request = await options.toRequest(request);
      expect(request.fields['from'], 'from');
      expect(request.fields['to'], 'to');
      expect(request.fields['subject'], 'subject');
      expect(request.fields['text'], 'text');
      expect(request.fields['cc'], 'cc');
      expect(request.fields['bcc'], 'bcc');
      expect(request.files.length, 1);
      expect(request.files.first.filename, '140x100.png');
    });
  }, tags: 'unit');
  group('MessageOptions', () {
    test('throws InvalidPlanException when trying locked options without scale plan',
        () {

      expect(
        (){
          var opts = MessageOptions(plan: PlanType.other);
          opts.deliveryTimeOptimizePeriod = 24;
          },
        throwsA(
          isA<InvalidPlanException>(),
        ),
      );
      expect(
        (){
          var opts = MessageOptions(plan: PlanType.other);
          opts.timeZoneLocalize = 'Asia/Tokyo';
        },
        throwsA(
          isA<InvalidPlanException>(),
        ),
      );
    });
    test(
        'throws FormatException when deliverytimeoptimizeperiod is not between 24 and 72',
        () {
      var opts = MessageOptions(plan: PlanType.scale);
      expect(
        () => opts.deliveryTimeOptimizePeriod = 23,
        throwsA(
          isA<FormatException>(),
        ),
      );
      expect(
        () => opts.deliveryTimeOptimizePeriod = 73,
        throwsA(
          isA<FormatException>(),
        ),
      );
    });
  }, tags: 'unit');
}
