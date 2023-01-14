import 'dart:io';
import 'mailgun_mailer.dart';
import 'mailgun_internal_exports.dart';

class MailgunSender implements IMailgunSender {
  final String domain;
  final String apiKey;
  final bool regionIsEU;

  MailgunSender(
      {required this.domain, required this.apiKey, this.regionIsEU = false});

  Future<MGResponse> send(params) async {
    var client = Client();
    var host = regionIsEU ? 'api.eu.mailgun.net' : 'api.mailgun.net';
    try {
      var request = MultipartRequest(
          'POST',
          Uri(
              userInfo: 'api:$apiKey',
              scheme: 'https',
              host: host,
              path: '/v3/$domain/messages'));
      request = params.configureRequest(request);
      var response = await client.send(request);
      var responseBody = await response.stream.bytesToString();
      var jsonBody = jsonDecode(responseBody);
      var message = jsonBody['message'] ?? '';
      if (response.statusCode != HttpStatus.ok) {
        return MGResponse(MGResponseStatus.FAIL, message);
      }

      return MGResponse(MGResponseStatus.SUCCESS, message);
    } catch (e) {
      return MGResponse(MGResponseStatus.FAIL, e.toString());
    } finally {
      client.close();
    }
  }
}
