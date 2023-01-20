import 'package:http/http.dart';

import '../mailgun_types.dart';

/// The [MGMessageClient] class is the default message client class
/// used for communicating with the `<domain>/messages` endpoint.
///
/// Methods:
/// -------
/// - [MGMessageClient.send] sends an email using the mailgun API.
/// - [MGMessageClient.sendMime] - sends an email using the mailgun API.
class MGMessageClient extends MGBaseClient {
  late String _endpoint;
  late MessageParamsBase _params;

  /// Initialise a [MGMessageClient] instance.
  /// ## Parameters:
  /// - [client] - the http client to use for sending requests.
  /// - [domain] - the domain of the Mailgun account.
  /// - [apiKey] - the API key of the Mailgun account.
  /// - [host] - the host to send requests to.
  /// - [callback] - a callback function that is called after the request is sent.
  MGMessageClient(super.client, super.domain, super.apiKey, super.host,
      [super.callback]);
  Future<MGResponse> send(MessageParams params) async {
    _endpoint = 'messages';
    _params = params;
    return await _handleRequest();
  }

  Future<MGResponse> sendMime(MimeMessageParams params) async {
    _endpoint = 'messages.mime';
    _params = params;
    return await _handleRequest();
  }

  MultipartRequest _request() {
    return MultipartRequest(
      'POST',
      Uri(
          userInfo: 'api:$apiKey',
          scheme: 'https',
          host: host,
          path: '/v3/$domain/$_endpoint'),
    );
  }

  Future<MGResponse> _handleRequest() async {
    var request = _request();
    request = await _params.toRequest(request);
    var response = await client.send(request);
    if (callback != null) {
      callback!(response);
    }
    return MGResponse(response);
  }
}
