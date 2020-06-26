import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitle = false, String strTitle, disappearedBackButton=false}) {
  return AppBar(
    
    automaticallyImplyLeading: isAppTitle ? disappearedBackButton : true,
    title: Text(
      isAppTitle ? "Social App" : strTitle, style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 40.0 : 22.0,
      ),
      // overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.purple,
  );
}
