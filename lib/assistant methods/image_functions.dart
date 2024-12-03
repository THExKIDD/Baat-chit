import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageFunctions {

 static pickImage(BuildContext context) async{

   final ImagePicker picker = ImagePicker();

   final XFile? image =
   await picker.pickImage(source: ImageSource.gallery);

   if(image != null)
     {
       log('Image path = ${image.path} and --MIMETYPE = ${image.mimeType}');
     }


}
}