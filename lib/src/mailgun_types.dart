import 'dart:convert';

class MailgunOptions {
  Map<String, dynamic>? templateVariables;
  @override
  String toString() {
    return jsonEncode(templateVariables);
  }
}

enum ContentType { html, text, template }

enum MGResponseStatus { SUCCESS, FAIL, QUEUED }

class MGResponse {
  MGResponseStatus status;
  String message;

  MGResponse(this.status, this.message);
}

class Content {
  ContentType type;
  String value;

  Content(this.type, this.value);
}