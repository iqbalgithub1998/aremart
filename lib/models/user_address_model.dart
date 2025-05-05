class UserAddressModel {
  final String userId;
  final String name;
  final String phoneNo;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String id;
  final String type;

  UserAddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNo,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.type,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic> json) =>
      UserAddressModel(
        id: json["id"],
        userId: json["userId"],
        name: json["name"],
        phoneNo: json["phoneNo"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        pincode: json["pincode"],
        type: json["type"] ?? "Home",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "name": name,
    "phoneNo": phoneNo,
    "address": address,
    "city": city,
    "state": state,
    "pincode": pincode,
    "type": type,
  };
}
