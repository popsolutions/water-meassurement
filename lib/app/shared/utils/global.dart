import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:water_meassurement/app/config/odoo_api/odoo_api.dart';

final odoo = Odoo();
var isExpired = false.obs;

DateTime? convertStringToDateTime(String? dateTime) {
  //dateTime in Format Example => '2021-12-01 23:59:59'
  if (dateTime == null)
    return null;

  return DateTime.parse(dateTime);
}

DateTime? convertStringToDateTimeMM_DD_YYYY(String? dateTime) {
  //dateTime in Format Example => '31/12/2021'

  if ((dateTime ?? '') == '')
    return null;

  DateFormat format = new DateFormat("MM/dd/yyyy");
  try {
    return format.parse(dateTime!);
  } catch(e){
    throw 'Data "$dateTime" inválida.';

  }
}

String? DateToSql(DateTime? date) {
  return (date == null) ? null : '"${DateFormat('yyyy-MM-dd').format(date)}"';
}

String? DateTimeToSql(DateTime? date) {
  return (date == null) ? null : DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
}