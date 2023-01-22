import 'package:http/http.dart' as http;

import '../types/index.dart';

/// The [MessageClient] class is the default message client class
/// used for communicating with the `<domain>/messages` endpoint.
///
/// Methods:
/// -------
/// - [MessageClient.send] sends an email using the mailgun API.
/// - [MessageClient.sendMime] - sends an email using the mailgun API.
class MessageClient extends BaseClient {
  late String _endpoint;
  late BaseMessageParams _params;

  /// Initialise a [MessageClient] instance.
  /// ## Parameters:
  /// - [client] - the http client to use for sending requests.
  /// - [domain] - the domain of the Mailgun account.
  /// - [apiKey] - the API key of the Mailgun account.
  /// - [host] - the host to send requests to.
  /// - [callback] - a callback function that is called after the request is sent.
  MessageClient(super.client, super.domain, super.apiKey, super.host,
      [super.callback]);
  Future<Response> send(MessageParams params) async {
    _endpoint = 'messages';
    _params = params;
    return await _handleRequest();
  }

  Future<Response> sendMime(MimeMessageParams params) async {
    _endpoint = 'messages.mime';
    _params = params;
    return await _handleRequest();
  }

  http.MultipartRequest _request() {
    return http.MultipartRequest(
      'POST',
      Uri(
          userInfo: 'api:$apiKey',
          scheme: 'https',
          host: host,
          path: '/v3/$domain/$_endpoint'),
    );
  }

  Future<Response> _handleRequest() async {
    var request = _request();
    request = await _params.toRequest(request);
    var response = await client.send(request);
    if (callback != null) {
      callback!(response);
    }
    return Response(response);
  }
}
