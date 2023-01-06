import 'dart:convert';

class RazorpayOptions {
  RazorpayOptions({
    required this.key,
    required this.amount,
    required this.businessName,
    required this.orderId,
    this.description,
    this.timeout,
    this.prefill,
    this.retry,
    this.theme,
  });

  final String key;
  final int amount;
  final String businessName;
  final String orderId;
  final String? description;
  final int? timeout;
  final Prefill? prefill;
  final Retry? retry;
  final Theme? theme;

  RazorpayOptions copyWith({
    String? key,
    int? amount,
    String? businessName,
    String? orderId,
    String? description,
    int? timeout,
    Prefill? prefill,
    Retry? retry,
    Theme? theme,
  }) =>
      RazorpayOptions(
        key: key ?? this.key,
        amount: amount ?? this.amount,
        businessName: businessName ?? this.businessName,
        orderId: orderId ?? this.orderId,
        description: description ?? this.description,
        timeout: timeout ?? this.timeout,
        prefill: prefill ?? this.prefill,
        retry: retry ?? this.retry,
        theme: theme ?? this.theme,
      );

  factory RazorpayOptions.fromJson(String str) =>
      RazorpayOptions.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RazorpayOptions.fromMap(Map<String, dynamic> json) => RazorpayOptions(
        key: json["key"],
        amount: json["amount"],
        businessName: json["name"],
        orderId: json["order_id"],
        description: json["description"],
        timeout: json["timeout"],
        prefill: Prefill.fromMap(json["prefill"]),
        retry: Retry.fromMap(json["retry"]),
        theme: Theme.fromMap(json["theme"]),
      );

  Map<String, dynamic> toMap() => {
        "key": key,
        "amount": amount,
        "name": businessName,
        "order_id": orderId,
        "description": description,
        "timeout": timeout,
        "prefill": prefill?.toMap(),
        "retry": retry?.toMap(),
        "theme": theme?.toMap(),
      };
}

class Prefill {
  Prefill({
    this.userName,
    this.userEmail,
    this.userContact,
  });

  final String? userName;
  final String? userEmail;
  final String? userContact;

  Prefill copyWith({
    String? userName,
    String? userEmail,
    String? userContact,
  }) =>
      Prefill(
        userName: userName ?? this.userName,
        userEmail: userEmail ?? this.userEmail,
        userContact: userContact ?? this.userContact,
      );

  factory Prefill.fromJson(String str) => Prefill.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Prefill.fromMap(Map<String, dynamic> json) => Prefill(
        userName: json["name"],
        userEmail: json["email"],
        userContact: json["contact"],
      );

  Map<String, dynamic> toMap() => {
        "name": userName,
        "email": userEmail,
        "contact": userContact,
      };
}

class Retry {
  Retry({
    required this.enabled,
  });

  final bool enabled;

  Retry copyWith({
    bool? enabled,
  }) =>
      Retry(
        enabled: enabled ?? this.enabled,
      );

  factory Retry.fromJson(String str) => Retry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Retry.fromMap(Map<String, dynamic> json) => Retry(
        enabled: json["enabled"],
      );

  Map<String, dynamic> toMap() => {
        "enabled": enabled,
      };
}

class Theme {
  Theme({
    this.hideTopbar,
    this.color,
    this.backdropColor,
  });

  final bool? hideTopbar;
  final String? color;
  final String? backdropColor;

  Theme copyWith({
    bool? hideTopbar,
    String? color,
    String? backdropColor,
  }) =>
      Theme(
        hideTopbar: hideTopbar ?? this.hideTopbar,
        color: color ?? this.color,
        backdropColor: backdropColor ?? this.backdropColor,
      );

  factory Theme.fromJson(String str) => Theme.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Theme.fromMap(Map<String, dynamic> json) => Theme(
        hideTopbar: json["hide_topbar"],
        color: json["color"],
        backdropColor: json["backdrop_color"],
      );

  Map<String, dynamic> toMap() => {
        "hide_topbar": hideTopbar,
        "color": color,
        "backdrop_color": backdropColor,
      };
}
