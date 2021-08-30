import 'dart:convert';

class UserModel {
  String? sessionId;
  int? uid;
  String? name;
  String? username;
  String? password;
  String? partnerDisplayName;
  int? companyId;
  int? partnerId;

  UserModel({
    this.sessionId,
    this.uid,
    this.name,
    this.username,
    this.password,
    this.partnerDisplayName,
    this.companyId,
    this.partnerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'uid': uid,
      'name': name,
      'username': username,
      'password': password,
      'partner_display_name': partnerDisplayName,
      'company_id': companyId,
      'partner_id': partnerId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      sessionId: map['session_id'],
      uid: map['uid'],
      name: map['name'],
      username: map['username'],
      password: map['password'],
      partnerDisplayName: map['partner_display_name'],
      companyId: map['company_id'],
      partnerId: map['partner_id'],
    );
  }

  String toJson() => json.encode(toMap());
  factory UserModel.fromJson(dynamic source) => UserModel.fromMap(source);
}
