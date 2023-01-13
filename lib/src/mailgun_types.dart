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
/// ```dart
/// var templateContent = Content.template("test", {"test": "test"});
/// ```
/// ```dart
/// var htmlContent = Content.html("test");
/// ```
/// ```dart
/// var textContent = Content.text("test");
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

  /// The Content.html(value) constructor
  /// * initialises the class with `value` as html content
  /// * sets the `_type` field to `ContentType.html`.
  Content.html(this.value){
    this.value = value;
    this._type = ContentType.html;
  }
  /// The Content.text(value) constructor
  /// * initialises the class with `value` as text content
  /// * sets the `_type` field to `ContentType.text`.
  Content.text(this.value){
    this.value = value;
    this._type = ContentType.text;
  }
  /// The Content.template(value, templateVariables) constructor
  /// * initialises the class with `value` as the template name and `templateVariables` as a map of variables.
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