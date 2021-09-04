import 'dart:convert';

class LandModel {
  int? id;
  String? name;

  LandModel({
    this.id,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory LandModel.fromMap(Map<String, dynamic> map) {
    return LandModel(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory LandModel.fromJson(dynamic source) => LandModel.fromMap(source);
}
