import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mailgun/mailgun.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main()  async{
  TestWidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load();
  final mailgunApiKey = DotEnv().env['MAILGUN_API_KEY'];
  final mailgunDomain = DotEnv().env['MAILGUN_DOMAIN'];
  final mailgunSender = DotEnv().env['MAILGUN_SENDER'];
  final mailgunRecipient = DotEnv().env['MAILGUN_RECIPIENT'];
  test('env variables', () {
    expect(mailgunApiKey, isNotNull);
    expect(mailgunDomain, isNotNull);
    expect(mailgunSender, isNotNull);
    expect(mailgunRecipient, isNotNull);
  });
  test('send email success', () async {
    final mailer = MailgunSender(
        domain: mailgunDomain!,
        apiKey: mailgunApiKey!);
    var response = await mailer.send(
        from: mailgunSender!,
        to: [mailgunRecipient!],
        subject: 'Hello World',
        content: Content(ContentType.text, 'This is a text message ${DateTime.now().toIso8601String()}'));
    expect(response.status, MGResponseStatus.SUCCESS);
  });

  test('send email success with attachments', () async {
    Directory current = Directory.current;
    final mailer = MailgunSender(
        domain: mailgunDomain!,
        apiKey: mailgunApiKey!);
    var response = await mailer.send(
        from: mailgunSender!,
        to: [mailgunRecipient!],
        subject: 'Hello World',
        content: Content(ContentType.text, 'This is a text message with attachment ${DateTime.now().toIso8601String()}'),
        attachments: [File("${current.path}/test/140x100.png")]);
    expect(response.status, MGResponseStatus.SUCCESS);
  });

  test('send email fail', () async {
    final mailer = MailgunSender(
        domain: mailgunDomain!, apiKey: 'key-invalid');
    var response = await mailer.send(
        from: mailgunSender!,
        to: [mailgunRecipient!],
        subject: 'Hello World',
        content: Content(ContentType.text, 'This is a text message ${DateTime.now().toIso8601String()}'));
    expect(response.status, MGResponseStatus.FAIL);
  });
}
