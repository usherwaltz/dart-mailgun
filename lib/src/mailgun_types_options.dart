import 'mailgun_internal_exports.dart';

enum MGPlanType { scale, other }

enum TrackingClicks { yes, no, htmlonly }

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
      key = key.toLowerCase().trim();
      key = key.startsWith('h:x-') ? key : 'h:X-$key';
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
      key = key.toLowerCase().trim();
      key = key.startsWith('v:') ? key : 'v:$key';
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
    _toMap().forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });
    _customHeaders?.forEach((key, value) {
      request.fields[key] = value;
    });
    _customVars?.forEach((key, value) {
      request.fields[key] = value;
    });
    return request;
  }

  Map<String, dynamic> _toMap() {
    return {
      'o:testmode': testMode,
      'o:deliverytime': deliveryTime?.toIso8601String(),
      'o:tag': tags?.join(','),
      'o:dkim': dkim,
      'o:tracking': tracking,
      'o:tracking-clicks': _trackingClicks,
      'o:tracking-opens': trackingOpens,
      'o:require-tls': requireTLS,
      'o:skip-verification': skipVerification,
      if (planType == MGPlanType.scale)
        'o:deliverytime-optimize-period': _deliveryTimeOptimizePeriod,
      if (planType == MGPlanType.scale)
        'o:time-zone-localize': _timeZoneLocalize?.toIso8601String(),
      if (recipientVars != null)
        'recipient-variables': json.encode(recipientVars),
    };
  }
}