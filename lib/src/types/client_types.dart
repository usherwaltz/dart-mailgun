import 'dart:convert';

import 'package:http/http.dart' as http;

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

/// [Response] is the class returned by all the clients.
///
/// It contains the result of the request and some helper methods.
class Response {
  Object result;
  Map<String, dynamic>? _body;
  ResponseStatus? _status;
  int get statusCode => _status != null ? _status!.code : status().code;
  String? get reasonPhrase =>
      _status != null ? _status!.reason : status().reason;

  Response(this.result);
  bool ok() {
    if (result is http.BaseResponse) {
      var result = this.result as http.BaseResponse;
      if (result.statusCode >= 200 && result.statusCode < 300) {
        return true;
      }
    }
    return false;
  }

  /// [status] returns the status code and reason phrase of the response as a [ResponseStatus] object.
  ///
  /// If the response is an [Exception], the status code will be 500 and the reason phrase will be the exception message.
  ///
  /// If the response is not an [Exception] or [http.BaseResponse],
  /// the status code will be 500 and the reason phrase will be "Unknown Error".
  ResponseStatus status() {
    if (_status != null) return _status!;
    if (result is http.BaseResponse) {
      var result = this.result as http.BaseResponse;
      _status = ResponseStatus(result.statusCode, result.reasonPhrase);
    } else if (result is Exception) {
      _status = ResponseStatus(500, result.toString());
    } else {
      _status = ResponseStatus(500, "Unknown Error");
    }
    return _status!;
  }

  /// [body] returns the body of the response as a [Map<String, dynamic>].
  ///
  /// It handles both [http.Response] and [http.StreamedResponse] types.
  ///
  /// Response bodies that are a string will be parsed into a map with a key of "message" and the value of the string.
  Future<Map<String, dynamic>>? get body async {
    if (_body != null) return Future.value(_body);
    if (!(result is http.StreamedResponse) && !(result is http.Response)) {
      _body = {};
      return Future.value(_body);
    }
    try {
      if (result is http.StreamedResponse) {
        var result = this.result as http.StreamedResponse;
        var body = await result.stream.bytesToString();
        _body = json.decode(body);
      } else if (result is http.Response) {
        var result = this.result as http.Response;
        _body = json.decode(result.body);
      }
    } catch (e) {
      if (e is FormatException) {
        // if format exception, try to parse as string
        if (result is http.StreamedResponse) {
          var result = this.result as http.StreamedResponse;
          var body = await result.stream.bytesToString();
          _body = {'message': body};
        } else if (result is http.Response) {
          var result = this.result as http.Response;
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
class BaseClient {
  /// [client] is the http client used to make requests
  final http.Client client;

  /// [domain] is the domain of the Mailgun account
  final String domain;

  /// [apiKey] is the API key of the Mailgun account used to authenticate requests
  final String apiKey;

  /// [host] is the host of the Mailgun API, either `api.eu.mailgun.net` or `api.mailgun.net`
  final String host;

  /// [callback] is a callback function that is called after every request
  final Callback? callback;
  const BaseClient(
      this.client, this.domain, this.apiKey, this.host, this.callback);
}

/// [Callback] is a typedef for a callback function used in all clients.
typedef Callback = void Function(http.BaseResponse response);
