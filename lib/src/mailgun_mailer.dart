import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'mailgun_types.dart';

class MailgunSender implements IMailgunSender {
  final String domain;
  final String apiKey;
  final bool regionIsEU;

  MailgunSender(
      {required this.domain, required this.apiKey, this.regionIsEU = false});

  Future<MGResponse> send(params) async {
    var client = http.Client();
    var host = regionIsEU ? 'api.eu.mailgun.net' : 'api.mailgun.net';
    try {
      var request = http.MultipartRequest(
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
