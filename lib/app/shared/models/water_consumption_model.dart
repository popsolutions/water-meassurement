import 'dart:convert';

import 'package:water_meassurement/app/shared/enums/enums.dart';

class WaterConsumptionModel {
  int? landId;
  String? landName;
  int? id;
  String? date;
  double? lastRead;
  double? currentRead;
  int? readerId;
  String? state;
  int? statesendserver; //StateSendServerEnum
  DateTime? datetimeSend;

  WaterConsumptionModel({
    this.id,
    this.landId,
    this.landName,
    this.date,
    this.lastRead,
    this.currentRead,
    this.readerId,
    this.state = 'draft',
    this.statesendserver = StateSendServerEnum.unread_1,
    this.datetimeSend
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'land_id': landId,
      'land_name': landName,
      'date': date,
      'last_read': lastRead,
      'current_read': currentRead,
      'reader_id': readerId,
      'state': state,
    };
  }

  Map<String, dynamic> toMapDao() {
    return {
      'id': id,
      'land_id': landId,
      'land_name': landName,
      'date': date,
      'last_read': lastRead,
      'current_read': currentRead,
      'reader_id': readerId,
      'state': state,
      'statesendserver': statesendserver,
      'datetime_send': datetimeSend.toString()
    };
  }

  factory WaterConsumptionModel.fromMap(Map<String, dynamic> map) {
    return WaterConsumptionModel(
      id: map['id'],
      landId: map['land_id'][0],
      landName: map['land_id'][1],
      date: map['date'],
      lastRead: double.parse(map['last_read'].toString()),
      currentRead: double.parse(map['current_read'].toString()),
      readerId: (map['reader_id'] is bool ? 0 : map['reader_id'][0]),
      state: map['state'],
    );
  }

  factory WaterConsumptionModel.fromDao(Map<String, dynamic> map) {
    return WaterConsumptionModel(
      id: map['id'],
      landId: map['land_id'],
      landName: map['land_name'],
      date: map['date'],
      lastRead: map['last_read'],
      currentRead: map['current_read'],
      readerId: map['reader_id'],
      state: map['state'],
      statesendserver: map['statesendserver'],
      datetimeSend: (map['datetime_send'] == 'null') ? null : DateTime.parse(map['datetime_send']),
    );
  }

  String toJson() => json.encode(toMap());

  factory WaterConsumptionModel.fromJson(dynamic source) =>
      WaterConsumptionModel.fromMap(source);

  get statesendserverText => StateSendServerEnum.convertIntToText(this.statesendserver);
}
