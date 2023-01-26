import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'client_types.dart';

/// Mailgun plan type
///
/// Used to determine which options are available for the plan.
///
/// Only scale and other plans are used as the others all have the same options.
///
/// For further information see the [Mailgun pricing](https://www.mailgun.com/pricing/).
enum PlanType { scale, other }

/// The possible values for the [o:tracking-clicks] option.
///
/// For further information see the [Mailgun documentation](https://documentation.mailgun.com/en/latest/api-sending.html#sending).
enum TrackingClicks { yes, no, htmlonly }

/// The possible extra options in the [MessageParams] class.
class MessageOptions {
  /// used to determine which options are available for your plan.
  PlanType plan;

  /// The [o:testmode] option.
  bool? testMode;

  /// The [o:delivery-time] option.
  DateTime? deliveryTime;

  /// The [o:tag] options.
  List<String>? tags;

  /// The [o:dkim] option.
  bool? dkim;
  String? _deliveryTimeOptimizePeriod;
  set deliveryTimeOptimizePeriod(int? value) {
    if (plan != PlanType.scale) {
      throw InvalidPlanException(
          'o:deliverytime-optimize-period is only available for scale plans');
    }
    if (value == null) {
      _deliveryTimeOptimizePeriod = null;
      return;
    }
    if (value < 24 || value > 72) {
      throw FormatException(
          'deliveryTimeOptimizePeriod must be between 24 and 72 hours', value);
    }
    _deliveryTimeOptimizePeriod = '${value}H';
  }

  /// The [o:deliverytime-optimize-period] option.
  ///
  /// only available for scale plans.
  int? get deliveryTimeOptimizePeriod {
    if (_deliveryTimeOptimizePeriod == null) return null;
    return int.parse(_deliveryTimeOptimizePeriod!
        .substring(0, _deliveryTimeOptimizePeriod!.length - 1));
  }
  String? _timeZoneLocalize;

  /// The [o:time-zone-localize] option.
  ///
  /// format: `HH:mm`, `hh:mmaa` - eg. `13:00`, `1:00pm`
  ///
  /// throws [FormatException] if the format is incorrect.
  ///
  /// throws [InvalidPlanException] if the plan is not a scale plan.
  set timeZoneLocalize(String? value) {
    if (plan != PlanType.scale) {
      throw InvalidPlanException(
          'o:time-zone-localize is only available for scale plans');
    }
    //check format
    if (value != null) {
      if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value) &&
          !RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9][ap]m$').hasMatch(value)) {
        throw FormatException(
            'timeZoneLocalize must be in the format HH:mm or hh:mmaa', value);
      }
    }
    _timeZoneLocalize = value;
  }

  /// The [o:time-zone-localize] option.
  ///
  /// only available for scale plans.
  String? get timeZoneLocalize => _timeZoneLocalize;

  /// The [o:tracking] option.
  bool? tracking;
  String? _trackingClicks;
  set trackingClicks(TrackingClicks? value) {
    if (value == null) {
      _trackingClicks = null;
      return;
    }
    _trackingClicks = value.toString().split('.').last;
  }

  /// The [o:tracking-clicks] option.
  TrackingClicks? get trackingClicks {
    if (_trackingClicks != null) {
      return TrackingClicks.values.firstWhere(
          (element) => element.toString().split('.').last == _trackingClicks);
    }
    return null;
  }

  /// The [o:tracking-opens] option.
  bool? trackingOpens;

  /// The [o:require-tls] option.
  bool? requireTLS;

  /// The [o:skip-verification] option.
  bool? skipVerification;
  Map<String, String>? _customHeaders;
  set customHeaders(Map<String, String>? value) {
    if (value == null) {
      _customHeaders = null;
      return;
    }
    _customHeaders = value.map((key, value) {
      key = key.toLowerCase().trim();
      key = key.startsWith('h:x-') ? key : 'h:X-$key';
      return MapEntry(key, value);
    });
  }

  /// Your custom headers.
  Map<String, String>? get customHeaders => _customHeaders;
  Map<String, String>? _customVars;
  set customVars(Map<String, String>? value) {
    if (value == null) {
      _customVars = null;
      return;
    }
    _customVars = value.map((key, value) {
      key = key.toLowerCase().trim();
      key = key.startsWith('v:') ? key : 'v:$key';
      return MapEntry(key, value);
    });
  }

  /// Your custom variables.
  Map<String, String>? get customVars => _customVars;

  /// The [recipient-variables] option.
  Map<String, String>? recipientVars;
  MessageOptions(
      {int? deliveryTimeOptimizePeriod,
      String? timeZoneLocalize,
      TrackingClicks? trackingClicks,
      Map<String, String>? customHeaders,
      Map<String, String>? customVars,
      this.plan = PlanType.other,
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

  /// Writes options to a [http.MultipartRequest]. Returns the request.
  http.MultipartRequest toRequest(http.MultipartRequest request) {
    var fields = {...?_customHeaders, ...?_customVars, ..._asMap()};
    request.fields.addAll(fields);
    return request;
  }

  Map<String, String> _asMap() {
    return {
      if (testMode != null) 'o:testmode': testMode!.toString(),
      if (deliveryTime != null)
        'o:deliverytime': deliveryTime!.toIso8601String(),
      if (tags != null) 'o:tag': tags!.join(','),
      if (dkim != null) 'o:dkim': dkim!.toString(),
      if (tracking != null) 'o:tracking': tracking!.toString(),
      if (_trackingClicks != null) 'o:tracking-clicks': _trackingClicks!,
      if (trackingOpens != null) 'o:tracking-opens': trackingOpens!.toString(),
      if (requireTLS != null) 'o:require-tls': requireTLS!.toString(),
      if (skipVerification != null)
        'o:skip-verification': skipVerification!.toString(),
      if (plan == PlanType.scale && _deliveryTimeOptimizePeriod != null)
        'o:deliverytime-optimize-period': _deliveryTimeOptimizePeriod!,
      if (plan == PlanType.scale && _timeZoneLocalize != null)
        'o:time-zone-localize': _timeZoneLocalize!,
      if (recipientVars != null)
        'recipient-variables': json.encode(recipientVars),
    };
  }
}

/// Possible types of content for sending emails.
enum MessageContentType { html, text, template }

/// The [MessageContent] class represents the content of an email.
///
/// The class provides factory constructors for creating instances of the class with different types of content.
/// The three types of content are [html], [text], and [template].
///
/// The class also provides a getter [templateVariables] which returns the [_templateVariables] field as a JSON string,
/// but it will throw an exception if the [type] is not [MessageContentType.template].
///
/// ## Examples:
/// using the [MessageContent.html] constructor:
///```dart
/// var htmlContent = MessageContent.html("test");
/// ```
/// using the [MessageContent.text] constructor:
/// ```dart
/// var textContent = MessageContent.text("test");
/// ```
/// using the [MessageContent.template] constructor:
/// ```dart
/// var templateContent = MessageContent.template("test", {"test": "test"});
/// ```
class MessageContent {
  /// Holds the actual content of the email.
  String value;

  /// Map that holds the variables that will be replaced in the template.
  ///
  /// _This field is only set when creating an instance of the class using the [MessageContent.template()] constructor._
  late Map<String, Object> _templateVariables;

  /// Holds the type of content to be sent.
  ///
  /// Possible values are [MessageContentType.html], [MessageContentType.text], and [MessageContentType.template].
  late MessageContentType _type;

  /// Initialises the class with [value] as html content, and sets [_type] to [MessageContentType.html].
  MessageContent.html(this.value) {
    this.value = value;
    this._type = MessageContentType.html;
  }

  /// Initialises the class with [value] as text content, and sets [_type] to [MessageContentType.text].
  MessageContent.text(this.value) {
    this.value = value;
    this._type = MessageContentType.text;
  }

  /// Initialises the class with [value] as the template name,
  /// and [_templateVariables] as a map of variables. Sets [_type] to [MessageContentType.template].
  MessageContent.template(this.value, Map<String, Object> templateVariables) {
    this._type = MessageContentType.template;
    this._templateVariables = templateVariables;
  }

  /// Returns the [_templateVariables] field as a JSON string.
  /// Throws [FormatException] if [type] is not [MessageContentType.template].
  ///
  /// _This shouldn't happen if the class is initialised correctly._
  String get templateVariables {
    if (type != MessageContentType.template) {
      throw FormatException('Not a template', type);
    }
    return json.encode(_templateVariables);
  }

  /// The [type] getter returns the type of content.
  MessageContentType get type => _type;

  /// Returns a map of the content.
  Map<String, String> asMap() {
    switch (_type) {
      case MessageContentType.html:
        return {'html': value};
      case MessageContentType.text:
        return {'text': value};
      case MessageContentType.template:
        return {'template': value, 'h:X-Mailgun-Variables': templateVariables};
    }
  }
}

/// The base interface for message parameter classes.
abstract class BaseMessageParams {
  Future<http.MultipartRequest> toRequest(http.MultipartRequest request);
}

/// The [MessageParams] class is used to configure the request to the `messages` endpoint.
class MessageParams implements BaseMessageParams {
  /// The name and email address of the sender.
  ///
  /// format is `name <email>`
  String from;

  /// List of recipients.
  List<String> to;
  String subject;

  /// Instance of the [MessageContent] class.
  MessageContent content;
  List<String>? cc;
  List<String>? bcc;
  List<String>? tags;
  List<File>? attachments;
  List<String>? inline;
  MessageOptions? options;
  MessageParams(this.from, this.to, this.subject, this.content,
      {this.cc,
      this.bcc,
      this.tags,
      this.attachments,
      this.inline,
      this.options});
  Future<http.MultipartRequest> toRequest(http.MultipartRequest request) async {
    var fields = <String, String>{};
    fields['from'] = from;
    fields['to'] = to.join(',');
    fields['subject'] = subject;
    if (cc != null) fields['cc'] = cc!.join(',');
    if (bcc != null) fields['bcc'] = bcc!.join(',');
    if (tags != null) fields['o:tag'] = tags!.join(',');
    if (attachments != null) {
      for (var attachment in attachments!) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment', attachment.path),
        );
      }
    }
    if (inline != null) fields['inline'] = inline!.join(',');
    options?.toRequest(request);
    request.fields.addAll({...content.asMap(), ...fields});
    return request;
  }
}

/// The [MimeMessageParams] class is used to configure the request to the `messages.mime` endpoint.
class MimeMessageParams extends BaseMessageParams {
  List<String> to;
  File content;
  MimeMessageParams(this.to, this.content);
  Future<http.MultipartRequest> toRequest(http.MultipartRequest request) async {
    request.fields['to'] = to.join(',');
    request.files.add(
      await http.MultipartFile.fromPath('message', content.path),
    );
    return request;
  }
}

/// The [IMessageClient] interface defines methods for sending emails with the mailgun API.
///
/// Implement this interface to create a custom message client.
///
/// The [IMessageClient.send] should be implemented to send a message using the mailgun API,
/// and the [IMessageClient.sendMime] method should be implemented to send MIME messages.
///
/// Example:
/// -------
/// ```dart
/// class MyMailgunSender extends IMessageClient {
///  @override
///   Future<dynamic> send(
///     ...
///    ) async {
///     ...
///  }
/// }
/// ```
abstract class IMessageClient {
  /// Sends an email using the mailgun API.
  ///
  /// Takes [params] - an instance of [MessageParams]. Returns [Response].
  Future<Response> send(MessageParams params);

  /// Optional method for sending MIME messages.
  ///
  /// Takes [params] - an instance of [MimeMessageParams]. Returns [Response].
  Future<Response>? sendMime(MimeMessageParams params);
}
