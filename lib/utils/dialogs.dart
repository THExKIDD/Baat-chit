import 'package:flutter/material.dart';

class Dialogs {

  static void showSnackbar(BuildContext context, String msg)
  {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue.withOpacity(0.8),
      behavior: SnackBarBehavior.floating,
    )
    );
  }

  static void showProgress(BuildContext context){
    showDialog(context: context, builder:(_) => Center(child: CircularProgressIndicator()) );
  }
}