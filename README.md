# dart-mailgun

[![Unit Tests](https://github.com/beccauwu/dart-mailgun/actions/workflows/unit_tests.yml/badge.svg)](https://github.com/beccauwu/dart-mailgun/actions/workflows/unit_tests.yml)
[![Integration](https://github.com/beccauwu/dart-mailgun/actions/workflows/integration_test.yml/badge.svg?branch=develop)](https://github.com/beccauwu/dart-mailgun/actions/workflows/integration_test.yml)

Mailgun API client written in dart

Forked from [dotronglong](https://github.com/dotronglong/flutter-mailgun "forked repo link")'s repo as it had been unmaintaned for a while.

- [dart-mailgun](#dart-mailgun)
  - [Functionality](#functionality)
  - [Getting Started](#getting-started)
    - [Pubspec](#pubspec)
    - [Initialising client](#initialising-client)
    - [Sending messages](#sending-messages)
      - [Examples](#examples)
  - [Response](#response)
  - [Plan type safety](#plan-type-safety)

## Functionality

- Send messages with any parameters supported by the API

## Getting Started

### Pubspec

```yaml
dependencies:
  dart_mailgun: ^1.0.2
```

### Initialising client

- With default host (api.mailgun.net)

```dart
import 'package:dart_mailgun/client.dart';


var client = MailgunClient(domain: "my-mailgun-domain", apiKey: "my-mailgun-api-key");
```

- With EU host (api.eu.mailgun.net)

```dart
import 'package:dart_mailgun/client.dart';

var client = MailgunClient.eu(domain: "my-mailgun-domain", apiKey: "my-mailgun-api-key");

```

### Sending messages

Messages are sent using [MessageClient], which comes preconfigured under [MailgunClient.message].

To send a message using the [MessageClient.send] method, you first configure parameters through [MessageParams].
It accepts all parameters that are listed in the Mailgun API docs, and will also handle passing the parameters to a [http.MultipartRequest] object.

The actual content of the email is under [MessageParams.content] and is an instance of [MessageContent], configured using one of the factory constructors:

- [MessageContent.text] - adds the content under `request.fields['text']`
- [MessageContent.html] - adds the content under `request.fields['html']`, and
- [MessageContent.template] - lets you send an email using a configured template. It has two parameters; one for the template name and one for a map of the different variables that you want to use.

#### Examples

- Plaintext

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.text('hello'),
  )
var response = await messageClient.send(params)
```

- HTML

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.html('<h1>hello</h1>'),
  )
var response = await messageClient.send(params)
```

- Template

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.template('mytemplate', {'var1': 'val1'}),
  )
var response = await messageClient.send(params)
```

[MessageParams] also accepts attachments as a list of [io.File] objects:

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.text('hello'),
  attachments: [File('$path/myfile.txt')],
  )
var response = await messageClient.send(params)
```

If you can't find the parameter you're looking for it might be configurable under [MessageParams.options] - as an instance of [MessageOptions]:

```dart
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.text('hello'),
  options: MessageOptions(
    tracking: true,
    requireTLS: false,
    customHeaders: {
      'My-Header': 'myheadervalue'
    },
    dkim: false,
    testMode: true
  ),
)
```

[MessageOptions] automatically parses the keys of [MessageOptions.customHeaders] to `h:X-$key`, and [MessageOptions.customVars] to `v:$key`, so unless you want to you don't need to include the prefix.

## Response

Responses from any clients will be instances of the [Response] class.

The response contains two methods:

- [Response.ok]returns a boolean indicating a successful response, and
- [Response.status] returns an instance of [ResponseStatus], which contains the statuscode under [ResponseStatus.code] as well as the reasonphrase under [ResponseStatus.reason].

You can also directly access both of these from [Response.statusCode], and [Response.reasonPhrase] respectively.

The body is found in [Response.body]. It parses both text responses and json responses into [Map<String, String>] and supports both [http.Response]s and [http.StreamedResponse]s. [Response.body] returns a [Future<Map<String, dynamic>>] to be able to read bytes from the body of an [http.StreamedResponse].

Text bodies are added under `Response.body['message']`.

```dart
var response = await client.send(params)
if(!response.ok()){
  //handle error
  print(response.reasonPhrase)
} else {
  var body = await response.body
  print(body['message'])
  // handle result
}
```

## Plan type safety

In order to mitigate the risk of errors, the [MessageOptions] class checks if you have the required Mailgun plan to use certain options.

From what I could find in their documentation there are two options that aren't available on plans other than scale:

- `o: deliverytime-optimize-period`, and
- `o: timezone-localize`

To use these options, when configuring your parameters, under [MessageParams.options], set [MessageOptions.plan] to [PlanType.scale].
