class StateSendServerEnum{
  static const String unreadText = 'unread';
  static const String readText = 'read';
  static const String sendingText = 'sending';
  static const String sendingErrorText = 'sendingError';
  static const String sendText= 'send';

  static const int unread_1 = 1;
  static const int read_2 = 2;
  static const int sending_3 = 3;
  static const int sendingError_4 = 4;
  static const int send_5= 5;

  static String convertIntToText(int? value){
    if (value == unread_1) return unreadText;
    if (value == read_2) return readText;
    if (value == sending_3) return sendingText;
    if (value == sendingError_4) return sendingErrorText;
    if (value == send_5) return sendText;
    return '';
  }

  static int convertTextToInt(String? value){
    if (value == unreadText) return unread_1;
    if (value == readText) return read_2;
    if (value == sendingText) return sending_3;
    if (value == sendingErrorText) return sendingError_4;
    if (value == sendText) return send_5;
    return -1;
  }
}

class typeLogEnum{
  static const int processWaterSend_1 = 1;
  static const int DaoToStateSend_2 = 2;
  static const int SendDraftToOdoo_3 = 3;
  static const int SendPendingToOdoo_4 = 4;
  static const int SendDaoToStateSend_5 = 5; //Normal Process
  static const int processWaterError_6 = 6; //Error Process
}

