import 'dart:convert';

import 'package:water_meassurement/app/shared/enums/enums.dart';
import 'package:water_meassurement/app/shared/utils/global.dart';

class WaterConsumptionModel {
  int? landId;
  String? landName;
  int? id;
  String? date;
  String? photo;
  double? lastRead;
  double? currentRead;
  int? readerId;
  String? state;
  int? statesendserver; //StateSendServerEnum
  DateTime? datetimeSend;

  int? route_custom_id;
  int? route_sequence;
  int? route_realreadsequence;
  DateTime? read_datetime;

  DateTime? get date_ToDate => convertStringToDateTimeMM_DD_YYYY(date);

  WaterConsumptionModel({
    this.id,
    this.landId,
    this.landName,
    this.date,
    this.photo,
    this.lastRead,
    this.currentRead,
    this.readerId,
    this.state = 'draft',
    this.statesendserver = StateSendServerEnum.unread_1,
    this.datetimeSend,
    this.route_custom_id,
    this.route_realreadsequence,
    this.route_sequence,
    this.read_datetime
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'land_id': landId,
      // 'land_name': landName,
      'date': DateToSql(date_ToDate),
      'photo': photo,
      'last_read': lastRead,
      'current_read': currentRead,
      'reader_id': readerId,
      'state': state,
      'route_custom_id': route_custom_id,
      'route_sequence': route_sequence,
      'route_realreadsequence': route_realreadsequence,
      'read_datetime': DateTimeToSql(read_datetime),
    };
  }

  Map<String, dynamic> toMapDao() {
    return {
      'id': id,
      'land_id': landId,
      'land_name': landName,
      'date': date,
      'photo': photo,
      'last_read': lastRead,
      'current_read': currentRead,
      'reader_id': readerId,
      'state': state,
      'statesendserver': statesendserver,
      'datetime_send': DateTimeToSql(datetimeSend),
      'route_custom_id': route_custom_id,
      'route_sequence': route_sequence,
      'route_realreadsequence': route_realreadsequence,
      'read_datetime': DateTimeToSql(read_datetime),
    };
  }

  factory WaterConsumptionModel.fromMap(Map<String, dynamic> map) {
    return WaterConsumptionModel(
      id: map['id'],
      landId: map['land_id'][0],
      landName: map['land_id'][1],
      date: map['date'],
      photo: map['photo'],
      lastRead: double.parse(map['last_read'].toString()),
      currentRead: double.parse(map['current_read'].toString()),
      readerId: (map['reader_id'] is bool ? 0 : map['reader_id'][0]),
      state: map['state'],
      statesendserver: double.parse(map['current_read'].toString()) == 0 ? StateSendServerEnum.unread_1 : StateSendServerEnum.send_5,
    );
  }

  factory WaterConsumptionModel.fromDao(Map<String, dynamic> map) {
    return WaterConsumptionModel(
      id: map['id'],
      landId: map['land_id'],
      landName: map['land_name'],
      date: map['date'],
      photo: map['photo'],
      lastRead: map['last_read'],
      currentRead: map['current_read'],
      readerId: map['reader_id'],
      state: map['state'],
      statesendserver: map['statesendserver'],
      datetimeSend: (map['datetime_send'] == null)
          ? null
          : DateTime.parse(map['datetime_send']),
      route_custom_id: map['route_custom_id'] == 'null' ? null : map['route_custom_id'],
      route_sequence: map['route_sequence'] == 'null' ? null : map['route_sequence'] ,
      route_realreadsequence: map['route_realreadsequence'] == 'null' ? null : map['route_realreadsequence'],
      read_datetime: convertStringToDateTime(map['read_datetime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory WaterConsumptionModel.fromJson(dynamic source) =>
      WaterConsumptionModel.fromMap(source);

  get statesendserverText =>
      StateSendServerEnum.convertIntToText(this.statesendserver);
}
