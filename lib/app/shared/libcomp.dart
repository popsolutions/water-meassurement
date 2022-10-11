import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

int dialogProcessIndex = 0;

class LibComp {
  static void showMessage(
      BuildContext context, String title, String message) async {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctxt) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              title,
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Ok",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctxt) {
          return CupertinoAlertDialog(
            title: Text(
              title,
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Ok",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  static Future<bool> showQuestion(
      BuildContext context, String _titulo, String _corpo,
      [Function? _functionConfirmar,
        String labelConfirmar = 'CONFIRMAR',
        String labelCancelar = 'CANCELAR']) async {
    bool confirmSelect = false;

    //Botões
    Widget _btnConfirmar = FlatButton(
      child: Text(
        labelConfirmar,
        style: TextStyle(color: Colors.green, fontSize: 18),
      ),
      onPressed: () {
        confirmSelect = true;

        if (_functionConfirmar != null) _functionConfirmar();

        Navigator.of(context).pop();
      },
    );

    Widget _btnCancelar = FlatButton(
      child: Text(
        labelCancelar,
        style: TextStyle(color: Colors.redAccent, fontSize: 18),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
      title: Text(
        _titulo,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      content: Text(_corpo),
      actions: [
        _btnConfirmar,
        _btnCancelar,
      ],
    );
    // Exibindo
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return confirmSelect;
  }

}
