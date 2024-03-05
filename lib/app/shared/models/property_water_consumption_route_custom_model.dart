import 'dart:convert';

class Property_water_consumption_route_custom {
  int id = 0;
  String name = '';
  int route_id = 0;
  String descricao = '';

  Property_water_consumption_route_custom({
    required this.id,
    required this.name,
    required this.route_id,
    required this.descricao
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'route_id': route_id,
      'descricao': descricao,
    };
  }

  factory Property_water_consumption_route_custom.fromMap(Map<String, dynamic> map) {
    return Property_water_consumption_route_custom(
      id: map['id'],
      name: map['name'],
      route_id: map['route_id'][0],
      descricao: map['route_id'][1],
    );
  }

  factory Property_water_consumption_route_custom.fromDao(Map<String, dynamic> map) {
    return Property_water_consumption_route_custom(
      id: map['id'],
      name: map['name'],
      route_id: map['route_id'],
      descricao: map['descricao'],
    );
  }


  String toJson() => json.encode(toMap());
  factory Property_water_consumption_route_custom.fromJson(dynamic source) => Property_water_consumption_route_custom.fromMap(source);
}