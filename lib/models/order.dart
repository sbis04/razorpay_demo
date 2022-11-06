// To parse this JSON data, do
//
//     final order = orderFromMap(jsonString);

import 'dart:convert';

class Order {
  Order({
    this.amount,
    this.amountPaid,
    this.notes,
    this.createdAt,
    this.amountDue,
    this.currency,
    this.receipt,
    this.id,
    this.entity,
    this.status,
    this.attempts,
  });

  final int? amount;
  final int? amountPaid;
  final Notes? notes;
  final int? createdAt;
  final int? amountDue;
  final String? currency;
  final String? receipt;
  final String? id;
  final String? entity;
  final String? status;
  final int? attempts;

  Order copyWith({
    int? amount,
    int? amountPaid,
    Notes? notes,
    int? createdAt,
    int? amountDue,
    String? currency,
    String? receipt,
    String? id,
    String? entity,
    String? status,
    int? attempts,
  }) =>
      Order(
        amount: amount ?? this.amount,
        amountPaid: amountPaid ?? this.amountPaid,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        amountDue: amountDue ?? this.amountDue,
        currency: currency ?? this.currency,
        receipt: receipt ?? this.receipt,
        id: id ?? this.id,
        entity: entity ?? this.entity,
        status: status ?? this.status,
        attempts: attempts ?? this.attempts,
      );

  factory Order.fromJson(String str) => Order.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Order.fromMap(Map<String, dynamic> json) => Order(
        amount: json["amount"],
        amountPaid: json["amount_paid"],
        notes: Notes.fromMap(Map<String, dynamic>.from(json["notes"])),
        createdAt: json["created_at"],
        amountDue: json["amount_due"],
        currency: json["currency"],
        receipt: json["receipt"],
        id: json["id"],
        entity: json["entity"],
        status: json["status"],
        attempts: json["attempts"],
      );

  Map<String, dynamic> toMap() => {
        "amount": amount,
        "amount_paid": amountPaid,
        "notes": notes != null ? notes!.toMap() : null,
        "created_at": createdAt,
        "amount_due": amountDue,
        "currency": currency,
        "receipt": receipt,
        "id": id,
        "entity": entity,
        "status": status,
        "attempts": attempts,
      };
}

class Notes {
  Notes({this.info});

  final String? info;

  Notes copyWith({String? info}) => Notes(info: info ?? this.info);

  factory Notes.fromJson(String str) => Notes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Notes.fromMap(Map<String, dynamic> json) => Notes(info: json["info"]);

  Map<String, dynamic> toMap() => {"info": info};
}
