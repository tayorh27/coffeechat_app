/*
*  shadows.dart
*  coffee-chat
*
*  Created by Gisanrin Adetayo.
*  Copyright © 2018 CoffeeChat. All rights reserved.
    */

import 'package:flutter/rendering.dart';


class Shadows {
  static const BoxShadow primaryShadow = BoxShadow(
    color: Color.fromARGB(156, 9, 98, 234),
    offset: Offset(0, 3),
    blurRadius: 6,
  );
  static const BoxShadow secondaryShadow = BoxShadow(
    color: Color.fromARGB(41, 0, 0, 0),
    offset: Offset(0, 3),
    blurRadius: 6,
  );
}