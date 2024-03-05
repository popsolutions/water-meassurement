import 'dart:convert';

class Property_water_consumption_route_lands {
  int id = 0;
  int routecustom_id = 0;
  int land_id = 0;
  String land_id_module_id_code = '';
  String land_id_block_id_code = '';
  String land_id_lot_id_code = '';
  int sequence = 0;

  Property_water_consumption_route_lands({
    required this.id,
    required this.routecustom_id,
    required this.land_id,
    required this.land_id_module_id_code,
    required this.land_id_block_id_code,
    required this.land_id_lot_id_code,
    required this.sequence
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routecustom_id': routecustom_id,
      'land_id': land_id,
      'land_id_module_id_code': land_id_module_id_code,
      'land_id_block_id_code': land_id_block_id_code,
      'land_id_lot_id_code': land_id_lot_id_code,
      'sequence': sequence,
    };
  }

  factory Property_water_consumption_route_lands.fromMap(Map<String, dynamic> map) {
    return Property_water_consumption_route_lands(
      id: map['id'],
      routecustom_id: map['routecustom_id'][0],
      land_id: map['land_id'][0],
      land_id_module_id_code: map['land_id_module_id_code'],
      land_id_block_id_code: map['land_id_block_id_code'],
      land_id_lot_id_code: map['land_id_lot_id_code'],
      sequence: map['sequence'],
    );
  }

  String toJson() => json.encode(toMap());
  factory Property_water_consumption_route_lands.fromJson(dynamic source) => Property_water_consumption_route_lands.fromMap(source);
}