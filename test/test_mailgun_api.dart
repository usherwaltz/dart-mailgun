import 'package:dart_mailgun/client.dart';
import 'package:test/test.dart';
import 'constants.dart';

void main() async {
  final domain = TestConstants.domain;
  final apiKey = TestConstants.apiKey;
  final from = TestConstants.from;
  final to = TestConstants.to;
  final client = MailgunClient(domain, apiKey);
  group('MessageClient', () {
    test('send text', () async {
      var messageClient = client.message;
      var opts = MessageParams(from, [to], 'test', MessageContent.text('test'));
      var res = await messageClient.send(opts);
      expect(res.ok(), true);
    });
    test('send html', () async {
      var messageClient = client.message;
      var opts = MessageParams(from, [to], 'test',
          MessageContent.html('<div><h1>test</h1><p>this is a html test</p></div>'));
      var res = await messageClient.send(opts);
      expect(res.ok(), true);
    });
    test('send template', () async {
      var messageClient = client.message;
      var opts = MessageParams(
          from,
          [to],
          'test',
          MessageContent.template(
              'tester', {'testvar1': 'testval1', 'testvar2': 'testval2'}));
      var res = await messageClient.send(opts);
      expect(res.ok(), true);
    });
    test('should fail', () async {
      var tempClient = MailgunClient(domain, 'wrongapikey');
      var messageClient = tempClient.message;
      var opts = MessageParams(from, [to], 'test', MessageContent.text('test'));
      var res = await messageClient.send(opts);
      expect(res.ok(), false);
    });
  }, tags: "api");
}
