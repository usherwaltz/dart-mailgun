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

  Future<MGResponse> send(
      {from = 'mailgun',
      required to,
      required subject,
      required content,
      cc,
      bcc,
      attachments = const [],
      options,
      useDifferentFromDomain}) async {
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
      request.fields['subject'] = subject;
      request.fields['from'] = from;
      request.fields['cc'] = cc?.join(", ") ?? '';
      request.fields['bcc'] = bcc?.join(", ") ?? '';
      switch (content.type) {
        case ContentType.html:
          request.fields['html'] = content.value;
          break;
        case ContentType.text:
          request.fields['text'] = content.value;
          break;
        case ContentType.template:
          request.fields['template'] = content.value;
          request.fields['h:X-Mailgun-Variables'] = content.templateVariables;
          break;
        default:
          throw Exception('Invalid content type');
      }

      if (to.length > 0) {
        request.fields['to'] = to.join(", ");
      }
      if (options != null) {
        if (options.templateVariables != null) {
          request.fields['h:X-Mailgun-Variables'] =
              jsonEncode(options.templateVariables);
        }
      }
      if (attachments.length > 0) {
        request.headers["Content-Type"] = "multipart/form-data";
        for (var i = 0; i < attachments.length; i++) {
          var attachment = attachments[i];
          if (attachment is File) {
            request.files.add(await http.MultipartFile.fromPath(
                'attachment', attachment.path));
          }
        }
      }
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
