// Created by Tayyab Mughal on 11/07/2023.
// Tayyab Mughal
// tayyabmughal676@gmail.com
// © 2022-2023  - All Rights Reserved

import 'package:flutter_isar_db/collections/Category.dart';
import 'package:isar/isar.dart';
part 'routine.g.dart';


@collection
class Routine {
  Id id = Isar.autoIncrement;

  late String title;

  @Index()
  late DateTime startTime;

  @Index(caseSensitive: false)
  late String day;

  @Index(composite: [CompositeIndex('title')])
  final category = IsarLink<Category>();
}
