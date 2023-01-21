import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:dart_mailgun/types.dart';

void main() {
  group('MGResponse', () {
    test('.ok() returns true when status code is 200', () {
      var httpResponse = http.Response('ok', 200);
      var response = MGResponse(httpResponse);
      expect(response.ok(), true);
    });
    test('.ok() returns false when status code is 400', () {
      var httpResponse = http.Response('bad request', 400);
      var response = MGResponse(httpResponse);
      expect(response.ok(), false);
    });

    test('.body parses json as map', () async {
      var httpResponse = http.Response('{"message": "ok"}', 200);
      var response = MGResponse(httpResponse);
      var body = await response.body;
      expect(body, isNotNull);
      expect(body, isMap);
      expect(body!['message'], 'ok');
    });
    test('.body parses string response into map', () async {
      var httpResponse = http.Response('ok', 200);
      var response = MGResponse(httpResponse);
      var body = await response.body;
      expect(body, isNotNull);
      expect(body, isMap);
      expect(body!['message'], 'ok');
    });
    test('.body parses StreamedResponse json as map', () async {
      var httpResponse = http.StreamedResponse(
          Stream.fromIterable([utf8.encode('{"message": "ok"}')]), 200);
      var response = MGResponse(httpResponse);
      var body = await response.body;
      expect(body, isNotNull);
      expect(body, isMap);
      expect(body!['message'], 'ok');
    });
    test('.body parses StreamedResponse string response into map', () async {
      var httpResponse =
          http.StreamedResponse(Stream.fromIterable([utf8.encode('ok')]), 200);
      var response = MGResponse(httpResponse);
      var body = await response.body;
      expect(body, isNotNull);
      expect(body, isMap);
      expect(body!['message'], 'ok');
    });
    test('.status().code returns 200 when status code is 200', () {
      var httpResponse = http.Response('ok', 200);
      var response = MGResponse(httpResponse);
      expect(response.status().code, 200);
    });
    test('.status().reason is null when status code is 200', () {
      var httpResponse = http.Response('ok', 200);
      var response = MGResponse(httpResponse);
      expect(response.status().reason, isNull);
    });
    test('.status().reason is not null when status code is 400', () {
      var httpResponse = http.Response('bad request', 400, reasonPhrase: 'bad');
      var response = MGResponse(httpResponse);
      var status = response.status();
      expect(status.reason, isNotNull);
      expect(status.reason, 'bad');
    });

    test('.status() parses exception as 500, toString()', () {
      var exception = Exception('test');
      var response = MGResponse(exception);
      var status = response.status();
      expect(status.code, 500);
      expect(status.reason, 'Exception: test');
    });
    test('.status() resturn 500, unknown error when result is unknown', () {
      var response = MGResponse('test');
      var status = response.status();
      expect(status.code, 500);
      expect(status.reason, 'Unknown Error');
    });
  });
  group('MessageParams', () {
    test('toRequest() returns fields converted to request', () async {
      var request =
          http.MultipartRequest('POST', Uri.parse('http://localhost'));
      var options = MessageParams(
          'from', ['to'], 'subject', MessageContent.text('text'),
          cc: ['cc'], bcc: ['bcc'], attachments: [File('140x100.png')]);
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
  });
  group('MessageOptions', () {
    test('throws InvalidPlanException when trying options and plantype not set',
        () {
      var opts = MessageOptions();
      expect(
        () => opts.deliveryTimeOptimizePeriod = 25,
        throwsA(
          isA<InvalidPlanException>(),
        ),
      );
      expect(
        () => opts.timeZoneLocalize = 'Europe/Berlin',
        throwsA(
          isA<InvalidPlanException>(),
        ),
      );
    });
    test(
        'throws FormatException when deliverytimeoptimizeperiod is not between 24 and 72',
        () {
      var opts = MessageOptions(planType: MGPlanType.scale);
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
  });
}
