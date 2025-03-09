import 'package:flutter/material.dart';

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.tealAccent.shade100,
        title: Text('Select Language', style: TextStyle(color: Colors.teal)),
        content: Container(
          width: double.minPositive,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text('English', style: TextStyle(color: Colors.black87)),
                onTap: () {
                  Navigator.pop(context);
                  // Implement language change to English
                },
              ),
              ListTile(
                title: Text(
                  'Vietnamese',
                  style: TextStyle(color: Colors.black87),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Implement language change to Vietnamese
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
        ],
      );
    },
  );
}
