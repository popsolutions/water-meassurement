import 'dart:convert';

class WaterConsumptionModel {
  int? landId;
  String? date;
  double? lastRead;
  double? currentRead;
  double? consumption;
  int? readerId;
  String? total;
  String? state;

  WaterConsumptionModel({
    this.landId,
    this.date,
    this.lastRead,
    this.currentRead,
    this.consumption,
    this.readerId = 8083,
    this.total,
    this.state = 'draft',
  });

  Map<String, dynamic> toMap() {
    return {
      'land_id': landId,
      'date': date,
      'last_read': lastRead,
      'current_read': currentRead,
      'consumption': consumption,
      'reader_id': readerId,
      'total': total,
      'state': state,
    };
  }

  factory WaterConsumptionModel.fromMap(Map<String, dynamic> map) {
    return WaterConsumptionModel(
      landId: map['land_id'],
      date: map['date'],
      lastRead: map['last_read'],
      currentRead: map['current_read'],
      consumption: map['consumption'],
      readerId: map['reader_id'],
      total: map['total'],
      state: map['state'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WaterConsumptionModel.fromJson(String source) =>
      WaterConsumptionModel.fromMap(json.decode(source));
}
