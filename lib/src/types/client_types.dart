import 'dart:convert';

import 'package:http/http.dart';

/// [InvalidPlanException] is thrown when a plan is invalid for a given operation.
class InvalidPlanException implements Exception {
  final String message;
  const InvalidPlanException(this.message);
}

class ResponseStatus {
  int code;
  String? reason;
  ResponseStatus(this.code, this.reason);
}

class MGResponse {
  Object result;
  Map<String, dynamic>? _body;

  MGResponse(this.result);
  bool ok() {
    if (result is BaseResponse) {
      var result = this.result as BaseResponse;
      if (result.statusCode >= 200 && result.statusCode < 300) {
        return true;
      }
    }
    return false;
  }

  ResponseStatus status() {
    if (result is BaseResponse) {
      var result = this.result as BaseResponse;
      return ResponseStatus(result.statusCode, result.reasonPhrase);
    }
    if (result is Exception) {
      return ResponseStatus(500, result.toString());
    }
    return ResponseStatus(500, "Unknown Error");
  }

  Future<Map<String, dynamic>>? get body async {
    if (_body != null) return Future.value(_body);
    if (!(result is StreamedResponse) && !(result is Response)) {
      _body = {};
      return Future.value(_body);
    }
    try {
      if (result is StreamedResponse) {
        var result = this.result as StreamedResponse;
        var body = await result.stream.bytesToString();
        _body = json.decode(body);
      } else if (result is Response) {
        var result = this.result as Response;
        _body = json.decode(result.body);
      }
    } catch (e) {
      if (e is FormatException) {
        // if format exception, try to parse as string
        if (result is StreamedResponse) {
          var result = this.result as StreamedResponse;
          var body = await result.stream.bytesToString();
          _body = {'message': body};
        } else if (result is Response) {
          var result = this.result as Response;
          _body = {'message': result.body};
        }
      } else {
        rethrow;
      }
    } finally {
      if (_body == null) {
        _body = {};
      }
    }
    return Future.value(_body);
  }
}

/// [MGBaseClient] is the base class for all clients.
///
/// Any custom clients should extend this class
/// to ensure that any methods in other classes work correctly.
class MGBaseClient {
  /// [client] is the http client used to make requests
  final Client client;

  /// [domain] is the domain of the Mailgun account
  final String domain;

  /// [apiKey] is the API key of the Mailgun account used to authenticate requests
  final String apiKey;

  /// [host] is the host of the Mailgun API, either `api.eu.mailgun.net` or `api.mailgun.net`
  final String host;

  /// [callback] is a callback function that is called after every request
  final Callback? callback;
  const MGBaseClient(
      this.client, this.domain, this.apiKey, this.host, this.callback);
}

/// [Callback] is a typedef for a callback function used in all clients.
typedef Callback = void Function(BaseResponse response);
