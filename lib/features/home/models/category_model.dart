import 'package:flutter/material.dart';

class CategoryModel {

  final String title;
  final Widget preview;
  final List<String> tags;

  CategoryModel({

    required this.title,
    required this.preview,
    required this.tags,
  });
}