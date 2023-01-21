[![Dart](https://github.com/beccauwu/dart-mailgun/actions/workflows/dart.yml/badge.svg)](https://github.com/beccauwu/dart-mailgun/actions/workflows/dart.yml)

# dart-mailgun

Mailgun API client written in dart

Forked from [dotronglong](https://github.com/dotronglong/flutter-mailgun "forked repo link")'s repo as it had been unmaintaned for a while.

This is still heavily in development so do keep that in mind. I'll publish the package on pub as soon as I've properly tested it. If you want to add it to your project you'll therefore have to import it from github as shown below.

## Endpoint Support

### `/v3/<domain>`

|   | |
|---|---|
| `/messages`   | :white_check_mark:  |
| `/messages.mime`   |:white_check_mark:  |

### `/v4`

none of the v4 endpoints are currently supported but this is definitely something i will work on.

## Getting Started

- Add dependency

```yaml
dependencies:
  flutter_mailgun:
    git: https://github.com/beccauwu/flutter-mailgun.git
```

- Initialize mailer instance

```dart
import 'package:flutter_mailgun/mailgun.dart';


var mailgun = MailgunSender(domain: "my-mailgun-domain", apiKey: "my-mailgun-api-key", regionIsEU: true);
```

- Send plain text email

```dart
var response = await mailgun.send(
  from: from,
  to: to,
  subject: "Test email",
  content: Content.text("your text"));
```

- Send HTML email

```dart
var response = await mailgun.send(
  from: from,
  to: to,
  subject: "Test email",
  content: Content.html("<strong>Hello World</strong>"));
```

- Send email using template and template's variables

```dart
var response = await mailgun.send({
  from: from,
  to: to,
  subject: "Test email",
  content: Content.template("my-template", {
      'author': 'John'
    });
  });
```

- Send email with attachments

```dart
var file = new File('photo.jpg');
var response = await mailgun.send(
  from: from,
  to: to,
  subject: "Test email",
  html: "Please check my <strong>attachment</strong>",
  attachments: [file]);
```

## Response

Below are possible statuses of `response.status`:

- `SendResponseStatus.OK`: mail is sent successfully
- `SendResponseStatus.QUEUED`: mail is added to queue, for example, mailgun is not delivered mail immediately
- `SendResponseStatus.FAIL`: failed to send email

In case of failure, error's message is under `response.message`

## Roadmap

- [ ] Add support for other endpoints:
  - [x] `/messages.mime`
  - [ ] `/events`
  - [ ] `/stats`
  - [ ] `/tags`
  - [ ] `/bounces`
  - [ ] `/routes`
  - [ ] `/domains/<domain>/webhooks`
  - [ ] `/lists`
  - [ ] `/templates`
- [x] Move tests to dart tests (remove flutter sdk as a dependency)
