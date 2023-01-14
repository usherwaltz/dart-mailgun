import 'dart:convert';

import 'package:http/http.dart';
import 'package:intl/intl.dart';

class DeliveryTimeOptimizePeriod {
  int min;
  int max;
  DeliveryTimeOptimizePeriod(this.min, this.max);
  get value => '$min-$max';
}

enum MGPlanType { scale, other }

enum TrackingClicks { yes, no, htmlonly }

class MGCustomHeader {
  final String _value;
  MGCustomHeader._(this._value);
  factory MGCustomHeader.fromString(String value) {
    final headerRegex = RegExp(r'^h:X-[a-zA-Z-]+$', caseSensitive: false);
    if (!headerRegex.hasMatch(value))
      throw FormatException(
          "String must be in format 'h:X-my-header' where my-header is the custom header name");
    return MGCustomHeader._(value);
  }
  String get value => _value;
}

class MGOptions {
  MGPlanType planType;
  bool? testMode;
  DateTime? deliveryTime;
  List<String>? tags;
  bool? dkim;
  String? _deliveryTimeOptimizePeriod;
  set deliveryTimeOptimizePeriod(int? value) {
    if (planType != MGPlanType.scale) {
      throw Exception(
          'o:deliverytime-optimize-period is only available for scale plans');
    }
    if (value == null) {
      _deliveryTimeOptimizePeriod = null;
      return;
    }
    if (value < 24 || value > 72) {
      throw Exception('deliveryTimeOptimizePeriod must be between 24 and 72');
    }
    _deliveryTimeOptimizePeriod = '${value}H';
  }

  int? get deliveryTimeOptimizePeriod => _deliveryTimeOptimizePeriod == null
      ? null
      : int.parse(_deliveryTimeOptimizePeriod!
          .substring(0, _deliveryTimeOptimizePeriod!.length - 1));
  DateTime? _timeZoneLocalize;
  set timeZoneLocalize(String? value) {
    if (value == null) {
      _timeZoneLocalize = null;
      return;
    }
    if (planType != MGPlanType.scale) {
      throw Exception('o:time-zone-localize is only available for scale plans');
    }
    _timeZoneLocalize = DateFormat('j:m').parse(value);
  }

  String? get timeZoneLocalize => _timeZoneLocalize?.toString();
  bool? tracking;
  String? _trackingClicks;
  set trackingClicks(TrackingClicks? value) {
    if (value == null) {
      _trackingClicks = null;
      return;
    }
    _trackingClicks = value.toString().split('.').last;
  }

  TrackingClicks? get trackingClicks => _trackingClicks == null
      ? null
      : TrackingClicks.values.firstWhere(
          (element) => element.toString().split('.').last == _trackingClicks);
  bool? trackingOpens;
  bool? requireTLS;
  bool? skipVerification;
  Map<String, String>? _customHeaders;
  set customHeaders(Map<String, String>? value) {
    if (value == null) {
      _customHeaders = null;
      return;
    }
    _customHeaders = value.map((key, value) {
      key = key.toLowerCase().startsWith('h:x-') ? key : 'h:X-$key';
      return MapEntry(key, value);
    });
  }

  Map<String, String>? get customHeaders =>
      _customHeaders == null ? null : _customHeaders;
  Map<String, String>? _customVars;
  set customVars(Map<String, String>? value) {
    if (value == null) {
      _customVars = null;
      return;
    }
    _customVars = value.map((key, value) {
      key = key.toLowerCase().startsWith('v:') ? key : 'v:$key';
      return MapEntry(key, value);
    });
  }

  Map<String, String>? get customVars => _customVars;
  Map<String, String>? recipientVars;
  MGOptions(
      int? deliveryTimeOptimizePeriod,
      String? timeZoneLocalize,
      TrackingClicks? trackingClicks,
      Map<String, String>? customHeaders,
      Map<String, String>? customVars,
      {this.planType = MGPlanType.other,
      this.testMode,
      this.deliveryTime,
      this.tags,
      this.dkim,
      this.tracking,
      this.trackingOpens,
      this.requireTLS,
      this.skipVerification,
      this.recipientVars}) {
    this.deliveryTimeOptimizePeriod = deliveryTimeOptimizePeriod;
    this.timeZoneLocalize = timeZoneLocalize;
    this.trackingClicks = trackingClicks;
    this.customHeaders = customHeaders;
    this.customVars = customVars;
  }
  MultipartRequest configureRequest(MultipartRequest request) {
    if (planType == MGPlanType.scale) {
      request.fields['o:deliverytime-optimize-period'] =
          _deliveryTimeOptimizePeriod ?? '';
      request.fields['o:time-zone-localize'] =
          _timeZoneLocalize?.toIso8601String() ?? '';
    }
    request.fields['o:testmode'] = testMode?.toString() ?? '';
    request.fields['o:deliverytime'] = deliveryTime?.toIso8601String() ?? '';
    request.fields['o:tag'] = tags?.join(',') ?? '';
    request.fields['o:dkim'] = dkim?.toString() ?? '';
    request.fields['o:tracking'] = tracking?.toString() ?? '';
    request.fields['o:tracking-clicks'] = _trackingClicks ?? '';
    request.fields['o:tracking-opens'] = trackingOpens?.toString() ?? '';
    request.fields['o:require-tls'] = requireTLS?.toString() ?? '';
    request.fields['o:skip-verification'] = skipVerification?.toString() ?? '';
    _customHeaders?.forEach((key, value) {
      request.fields[key] = value;
    });
    _customVars?.forEach((key, value) {
      request.fields[key] = value;
    });
    request.fields['recipient-variables'] = json.encode(recipientVars ?? {});
    return request;
  }

  Map<String, String> toMap() {
    return {
      'o:testmode': testMode?.toString() ?? '',
      'o:deliverytime': deliveryTime?.toIso8601String() ?? '',
      'o:tag': tags?.join(',') ?? '',
      'o:dkim': dkim?.toString() ?? '',
      'o:tracking': tracking?.toString() ?? '',
      'o:tracking-clicks': _trackingClicks ?? '',
      'o:tracking-opens': trackingOpens?.toString() ?? '',
      'o:require-tls': requireTLS?.toString() ?? '',
      'o:skip-verification': skipVerification?.toString() ?? '',
      if (planType == MGPlanType.scale)
        'o:deliverytime-optimize-period':
            _deliveryTimeOptimizePeriod?.toString() ?? '',
      if (planType == MGPlanType.scale)
        'o:time-zone-localize': _timeZoneLocalize?.toIso8601String() ?? '',
      'recipient-variables': json.encode(recipientVars ?? {}),
      ...?_customHeaders,
      ...?_customVars
    };
  }
}

class IMGSenderParams {
  List<String> from;
  List<String> to;
  String subject;
  Content content;
  List<String>? cc;
  List<String>? bcc;
  List<String>? tags;
  List<String>? attachments;
  List<String>? inline;
  MGOptions? options;
  IMGSenderParams(this.from, this.to, this.subject, this.content,
      {this.cc,
      this.bcc,
      this.tags,
      this.attachments,
      this.inline,
      this.options});
  MultipartRequest configureRequest(MultipartRequest request) {
    request.fields['from'] = from.join(',');
    request.fields['to'] = to.join(',');
    request.fields['subject'] = subject;
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
        throw FormatException('Invalid content type given', content.type);
    }
    request.fields['cc'] = cc?.join(',') ?? '';
    request.fields['bcc'] = bcc?.join(',') ?? '';
    request.fields['o:tag'] = tags?.join(',') ?? '';
    request.fields['attachment'] = attachments?.join(',') ?? '';
    request.fields['inline'] = inline?.join(',') ?? '';
    options?.configureRequest(request);
    return request;
  }

  Map<String, String> toMap() {
    return {
      'from': from.join(','),
      'to': to.join(','),
      'subject': subject,
      'cc': cc?.join(',') ?? '',
      'bcc': bcc?.join(',') ?? '',
      'o:tag': tags?.join(',') ?? '',
      'attachment': attachments?.join(',') ?? '',
      'inline': inline?.join(',') ?? '',
      ...content.toMap(),
      ...?options?.toMap()
    };
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
  Content.html(this.value) {
    this.value = value;
    this._type = ContentType.html;
  }

  /// The `Content.text(value)` constructor
  /// * initialises the class with `value` as text content
  /// * sets the `_type` field to `ContentType.text`.
  Content.text(this.value) {
    this.value = value;
    this._type = ContentType.text;
  }

  /// The `Content.template(value, templateVariables)` constructor
  /// * initialises the class with `value` as the template name and `_templateVariables` as a map of variables.
  /// * sets the `_type` field to `ContentType.template`.
  Content.template(this.value, this._templateVariables) {
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
  Map<String, dynamic> toMap() {
    switch (_type) {
      case ContentType.html:
        return {'html': value};
      case ContentType.text:
        return {'text': value};
      case ContentType.template:
        return {'template': value, 'h:X-Mailgun-Variables': templateVariables};
      default:
        throw FormatException('Invalid content type given', _type);
    }
  }
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
  /// * `options` - an instance of the `MGOptions` class.
  /// * `useDifferentFromDomain` - a boolean value indicating whether to use a different domain for the sender.
  ///
  /// Returns:
  /// --------
  /// * `Future<MGResponse>` - an instance of the `MGResponse` class.
  ///   * `MGResponse.status` - the status of the request.
  ///   * `MGResponse.message` - the message returned by the mailgun API.
  Future<MGResponse> send(IMGSenderParams params);
}
