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


/// The `Content` class represents the content of an email.
///
/// Description:
/// -----------
/// The class provides factory constructors for creating instances of the class with different types of content.
/// The three types of content are `html`, `text`, and `template`.
///
/// The class also provides a getter `templateVariables` which returns the `_templateVariables` field as a JSON string,
/// but it will throw an exception if the `type` is not `ContentType.template`.
///
/// Examples:
/// --------
/// using the `Content.html(value)` constructor:
///```dart
/// var htmlContent = Content.html("test");
/// ```
/// using the `Content.text(value)` constructor:
/// ```dart
/// var textContent = Content.text("test");
/// ```
/// using the `Content.template(value, templateVariables)` constructor:
/// ```dart
/// var templateContent = Content.template("test", {"test": "test"});
/// ```
class Content {

  /// The `value` field holds the actual content of the email.
  String value;
  /// The `_templateVariables` field is a map that holds the variables that will be replaced in the template.
  ///
  /// Note:
  /// -------
  /// This field is only set when creating an instance of the class using the `Content.template()` constructor.
  late Map<String, dynamic> _templateVariables;
  /// The private `_type` field holds the type of content.
  ///
  /// The possible values for this field are `ContentType.html`, `ContentType.text`, and `ContentType.template`.
  late ContentType _type;

  /// The `Content.html(value)` constructor
  /// * initialises the class with `value` as html content
  /// * sets the `_type` field to `ContentType.html`.
  Content.html(this.value){
    this.value = value;
    this._type = ContentType.html;
  }
  /// The `Content.text(value)` constructor
  /// * initialises the class with `value` as text content
  /// * sets the `_type` field to `ContentType.text`.
  Content.text(this.value){
    this.value = value;
    this._type = ContentType.text;
  }
  /// The `Content.template(value, templateVariables)` constructor
  /// * initialises the class with `value` as the template name and `_templateVariables` as a map of variables.
  /// * sets the `_type` field to `ContentType.template`.
  Content.template(this.value, this._templateVariables){
    this._type = ContentType.template;
  }

  /// The `templateVariables` getter returns the `_templateVariables` field as a JSON string.
  ///
  /// Throws:
  /// --------
  /// * `Exception` if `type` is not `ContentType.template`
  String get templateVariables {
    if (type != ContentType.template) throw Exception('Not a template');
    return jsonEncode(_templateVariables);
  }

  /// The `type` getter returns the type of content.
  ContentType get type => _type;
}

/// The `IMailgunSender` interface is a base class for sending emails with the mailgun API.
///
/// Methods:
/// -------
/// * `send()` - sends an email using the mailgun API.
///
/// Example:
/// -------
/// ```dart
/// class MyMailgunSender extends IMailgunSender {
///  @override
///   Future<MGResponse> send(
///     ...
///    ) async {
///     ...
///  }
/// }
/// ```
abstract class IMailgunSender {

  /// The `send()` method sends an email using the mailgun API.
  ///
  /// Parameters:
  /// -----------
  /// * `from` - the email address of the sender.
  /// * `to` - a list of email addresses of the recipients.
  /// * `subject` - the subject of the email.
  /// * `content` - the content of the email.
  /// * `cc` - a list of email addresses of the recipients to be copied.
  /// * `bcc` - a list of email addresses of the recipients to be blind copied.
  /// * `attachments` - a list of attachments to be sent with the email.
  /// * `options` - an instance of the `MailgunOptions` class.
  /// * `useDifferentFromDomain` - a boolean value indicating whether to use a different domain for the sender.
  ///
  /// Returns:
  /// --------
  /// * `Future<MGResponse>` - an instance of the `MGResponse` class.
  ///   * `MGResponse.status` - the status of the request.
  ///   * `MGResponse.message` - the message returned by the mailgun API.
  Future<MGResponse> send(
      {String from = 'mailgun',
      required List<String> to,
      required String subject,
      required Content content,
      List<String>? cc,
      List<String>? bcc,
      List<dynamic> attachments = const [],
      MailgunOptions? options,
      bool? useDifferentFromDomain});
}