import 'dart:convert';

import 'package:are_mart/models/user_address_model.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final List<UserAddressModel> address;
  String name;
  final String number;
  final String role;
  final String userId;
  String? currentAddress;
  String status;

  UserModel({
    required this.address,
    required this.name,
    required this.number,
    required this.role,
    required this.userId,
    this.currentAddress,
    this.status = "active",
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    address: List<UserAddressModel>.from(
      json["address"].map((x) => UserAddressModel.fromJson(x)),
    ),
    name: json["name"],
    number: json["number"],
    role: json["role"],
    userId: json["userId"],
    status: json["status"],
    currentAddress: json["current_address"],
  );

  Map<String, dynamic> toJson() => {
    "address": List<dynamic>.from(address.map((x) => x.toJson())),
    "name": name,
    "number": number,
    "role": role,
    "userId": userId,
    "status": status,
    "current_address": currentAddress,
  };
}
