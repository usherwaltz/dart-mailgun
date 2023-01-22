[![Unit Tests](https://github.com/beccauwu/dart-mailgun/actions/workflows/unit_tests.yml/badge.svg)](https://github.com/beccauwu/dart-mailgun/actions/workflows/unit_tests.yml)
[![Integration](https://github.com/beccauwu/dart-mailgun/actions/workflows/integration_test.yml/badge.svg)](https://github.com/beccauwu/dart-mailgun/actions/workflows/integration_test.yml)

# dart-mailgun
Mailgun API client written in dart

Forked from [dotronglong](https://github.com/dotronglong/flutter-mailgun "forked repo link")'s repo as it had been unmaintaned for a while.

## Functionality

* Send messages with any parameters supported by the API

## Getting Started

- Add dependency

```yaml
dependencies:
  dart_mailgun: ^1.0.1
```

- Initialise client instance

```dart
import 'package:dart_mailgun/client.dart';


var client = MailgunClient(domain: "my-mailgun-domain", apiKey: "my-mailgun-api-key");
```

- Initialise client with eu host

```dart
import 'package:dart_mailgun/client.dart';

var client = MailgunClient.eu(domain: "my-mailgun-domain", apiKey: "my-mailgun-api-key");

```

- Send plain text email

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.text('hello'),
  )
```

- Send HTML email

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.html('<h1>hello</h1>'),
  )
```

- Send email using template and template variables

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.template('mytemplate', {'var1': 'val1'}),
  )
```

- Send email with attachments

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.text('hello'),
  attachments: [File('myfile.txt')],
```

## Response

Responses from any clients will be an instance of the Response class.

The response contains two methods: ok(), and status().
ok() returns a boolean indicating a successful response,
status() returns an instance of ResponseStatus, which contains the statuscode `status().code` and reasonphrase `status().reason`.

The body is found in response.body and will parse both text responses and json responses.
In the case of text, the response is found under body['message'].

```dart
var response = await client.send(params)
if(!response.ok()){
  //handle error
  print(response.status().reason)
} else {
  var body = await response.body
  print(body['message'])
  // handle result
}
```
