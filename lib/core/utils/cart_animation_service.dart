import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter/material.dart';

class CartAnimationService {
  static final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  static late Function(GlobalKey) runAddToCartAnimation;
}
