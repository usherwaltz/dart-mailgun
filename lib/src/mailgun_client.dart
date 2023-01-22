import 'package:http/http.dart';

import 'mailgun_defaults.dart';
import 'client/index.dart';
export 'types/index.dart'
    show
        MessageParams,
        MessageContent,
        MessageOptions,
        InvalidPlanException,
        PlanType;

export 'client/index.dart' show MessageClient;

/// Client for communicating with the Mailgun API
///
/// The client currently only supports the `<domain>/messages` endpoint.
class MailgunClient {
  final _client = Client();
  final String _domain;
  final String _apiKey;
  final String _host;

  /// configured instance of the [MessageClient] class
  late final message = MessageClient(_client, _domain, _apiKey, _host);
  MailgunClient._(this._domain, this._apiKey, this._host);

  /// initialise [MailgunClient] with the eu host
  ///
  /// [domain] is the domain of the Mailgun account, and
  /// [apiKey] is the API key of the Mailgun account
  ///
  /// The parameters are passed to all the different clients
  factory MailgunClient.eu(String domain, String apiKey) =>
      MailgunClient._(domain, apiKey, MGDefaults.euHost);

  /// initialise a MailgunClient with the default host
  ///
  /// [domain] is the domain of the Mailgun account, and
  /// [apiKey] is the API key of the Mailgun account
  ///
  /// The parameters are passed to all the different clients
  factory MailgunClient(String domain, String apiKey) =>
      MailgunClient._(domain, apiKey, MGDefaults.defaultHost);

  /// close the client
  void close() => _client.close();
}
