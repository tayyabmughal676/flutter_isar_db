// Created by Tayyab Mughal on 11/07/2023.
// Tayyab Mughal
// tayyabmughal676@gmail.com
// © 2022-2023  - All Rights Reserved


import 'package:isar/isar.dart';

part 'Category.g.dart';

@collection
class Category{
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String name;
}