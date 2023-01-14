import 'mailgun_internal_exports.dart';

enum MGContentType { html, text, template }

/// The `MGContent` class represents the content of an email.
///
/// Description:
/// -----------
/// The class provides factory constructors for creating instances of the class with different types of content.
/// The three types of content are `html`, `text`, and `template`.
///
/// The class also provides a getter `templateVariables` which returns the `_templateVariables` field as a JSON string,
/// but it will throw an exception if the `type` is not `MGContentType.template`.
///
/// Examples:
/// --------
/// using the `MGContent.html(value)` constructor:
///```dart
/// var htmlContent = MGContent.html("test");
/// ```
/// using the `MGContent.text(value)` constructor:
/// ```dart
/// var textContent = MGContent.text("test");
/// ```
/// using the `MGContent.template(value, templateVariables)` constructor:
/// ```dart
/// var templateContent = MGContent.template("test", {"test": "test"});
/// ```
class MGContent {
  /// The `value` field holds the actual content of the email.
  String value;

  /// The `_templateVariables` field is a map that holds the variables that will be replaced in the template.
  ///
  /// Note:
  /// -------
  /// This field is only set when creating an instance of the class using the `MGContent.template()` constructor.
  late Map<String, dynamic> _templateVariables;

  /// The private `_type` field holds the type of content.
  ///
  /// The possible values for this field are `MGContentType.html`, `MGContentType.text`, and `MGContentType.template`.
  late MGContentType _type;

  /// The `MGContent.html(value)` constructor
  /// * initialises the class with `value` as html content
  /// * sets the `_type` field to `MGContentType.html`.
  MGContent.html(this.value) {
    this.value = value;
    this._type = MGContentType.html;
  }

  /// The `MGContent.text(value)` constructor
  /// * initialises the class with `value` as text content
  /// * sets the `_type` field to `MGContentType.text`.
  MGContent.text(this.value) {
    this.value = value;
    this._type = MGContentType.text;
  }

  /// The `MGContent.template(value, templateVariables)` constructor
  /// * initialises the class with `value` as the template name and `_templateVariables` as a map of variables.
  /// * sets the `_type` field to `MGContentType.template`.
  MGContent.template(this.value, this._templateVariables) {
    this._type = MGContentType.template;
  }

  /// The `templateVariables` getter returns the `_templateVariables` field as a JSON string.
  ///
  /// Throws:
  /// --------
  /// * `Exception` if `type` is not `MGContentType.template`
  String get templateVariables {
    if (type != MGContentType.template) throw Exception('Not a template');
    return json.encode(_templateVariables);
  }

  /// The `type` getter returns the type of content.
  MGContentType get type => _type;
  Map<String, dynamic> toMap() {
    switch (_type) {
      case MGContentType.html:
        return {'html': value};
      case MGContentType.text:
        return {'text': value};
      case MGContentType.template:
        return {'template': value, 'h:X-Mailgun-Variables': templateVariables};
      default:
        throw FormatException('Invalid content type given', _type);
    }
  }
}
