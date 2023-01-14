import 'mailgun_types.dart';
import 'mailgun_internal_exports.dart';

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
class IMGSenderParams {
  List<String> from;
  List<String> to;
  String subject;
  MGContent content;
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
      case MGContentType.html:
        request.fields['html'] = content.value;
        break;
      case MGContentType.text:
        request.fields['text'] = content.value;
        break;
      case MGContentType.template:
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
}