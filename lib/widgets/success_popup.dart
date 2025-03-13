import 'dart:async';
import 'package:flutter/material.dart';

class SuccessPopup extends StatelessWidget {
  final String message;
  final BuildContext outerContext;

  SuccessPopup({required this.message, required this.outerContext});

  void show({bool success = true}) {
    // Using outerContext which is passed down to ensure we have the correct context
    showDialog(
      context: outerContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Ensure the pop happens on the dialog's context directly.
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true); // Close the dialog after 2 seconds
          }
        });

        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: Colors.green.shade50,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                success ? Icon(Icons.check_circle, color: Colors.green, size: 60) : Icon(Icons.close_outlined, color: Colors.red, size: 60),
                SizedBox(height: 10),
                Text(message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is not used since the popup is handled via the showDialog method
    throw UnimplementedError('SuccessPopup is not intended to be used in the widget tree.');
  }
}
