import 'dart:convert';

List<PincodeModel> pincodeModelFromJson(String str) => List<PincodeModel>.from(
  json.decode(str).map((x) => PincodeModel.fromJson(x)),
);

String pincodeModelToJson(List<PincodeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PincodeModel {
  final String id;
  int pin;
  String status;
  final String docId;

  PincodeModel({
    required this.id,
    required this.pin,
    required this.status,
    required this.docId,
  });

  factory PincodeModel.fromJson(Map<String, dynamic> json) => PincodeModel(
    id: json["id"],
    pin: json["pin"],
    status: json["status"],
    docId: json["docId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pin": pin,
    "status": status,
    "docId": docId,
  };
}
