import 'package:flutter/cupertino.dart';
import 'package:userapp/Controllers/controllers.dart';

class PassProvider with ChangeNotifier{
  bool _pass = true;
  bool _pass2 = true;

  String? _imagePath;


  String? get imagePath => _imagePath;

  bool get pass => _pass;
  bool get pass2 => _pass2;

  void togglepass()
  {
    _pass = !_pass;
    notifyListeners();
  }
  void togglepass2()
  {
    _pass2 = !_pass2;
    notifyListeners();
  }




    void updatePfpImage(String path) {

      _imagePath = path;

      notifyListeners(); // Notify listeners to rebuild the UI

    }


    void clearPfpImage() {

      _imagePath = null;

      notifyListeners();

    }

    void showEmoji(bool emojiShow)
    {
      emojiShow = !emojiShow;

      notifyListeners();
    }

  }
