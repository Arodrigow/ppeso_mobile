import 'package:flutter/material.dart';
import 'package:ppeso_mobile/shared/content.dart';

class MealItemModel {
  TextEditingController name;
  TextEditingController quantity;
  Measurements unit;

  MealItemModel({
    required this.name,
    required this.quantity,
    this.unit = Measurements.grams,
  });
}

