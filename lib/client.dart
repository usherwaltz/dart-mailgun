/// Mailgun client library
///
/// This is the library you should import to use the Mailgun client without any customisation.
///
/// ## Usage
/// ```dart
/// import 'package:dart_mailgun/client.dart';
///
/// void main() async {
///
///   // initialise a MailgunClient with the eu host
///   final client = MailgunClient.eu('domain', 'your-api-key');
///   // message client is found in the client.message property
///   final messageClient = client.message;
///   // create a message params object
///   final params = MessageParams(
///     // the sender name and email address
///     'Sender Name <your@email.com>',
///     // list of recipient emails
///     ['recipient1@email.com', 'recipient2@email.com'],
///      // the subject of the email
///     'Subject',
///     // the html content of the email created using the MessageContent.html constructor
///     MessageContent.html('<h1>HTML Content</h1>'),
///    );
///   // all async methods on the client return Future<MGResponse>
///   final response = await messageClient.send(params);
///   // MGResponse has two useful methods: ok() and status()
///   // ok() returns true if 200 <= status code < 300
///   if (!response.ok()) {
///     // handle error
///   }
///   // status() returns a ResponseStatus object containing the status code and reason phrase
///   // if the the object in the request isn't a valid response,
///   // it will return 500 and the .toString() of the object, or 'Unknown Error'
///   final status = response.status();
///   print(status.code); // 200
///   print(status.message); // OK
///   // close the client when done
///   client.close();
/// }
/// ```
library client;

export 'src/mailgun_client.dart';