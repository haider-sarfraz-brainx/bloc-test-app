import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static final HiveHelper _instance = HiveHelper._internal();
  factory HiveHelper() => _instance;
  HiveHelper._internal();

  static Future<void> init({String? path}) async {
    if (path != null && path.isNotEmpty) {
      Hive.init(path);
      return;
    }
    try {
      await Hive.initFlutter();
    } on PlatformException {
      final dir = await Directory.systemTemp.createTemp('hive_');
      Hive.init(dir.path);
    }
  }

  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  static Future<Box> _getOrOpenBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    final box = await Hive.openBox(boxName);
    await box.flush();
    return box;
  }

  static Future<void> put(String boxName, String key, dynamic value) async {
    final box = await _getOrOpenBox(boxName);
    await box.put(key, value);
    await box.flush();
  }

  static Future<void> update(
    String boxName,
    String key,
    dynamic newValue,
  ) async {
    final box = await _getOrOpenBox(boxName);
    if (box.containsKey(key)) {
      await box.put(key, newValue);
      await box.flush();
    }
  }

  static Future<dynamic> get(
    String boxName,
    String key, {
    dynamic defaultValue,
  }) async {
    final box = await _getOrOpenBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  static Future<List<dynamic>> getAll(String boxName) async {
    final box = await _getOrOpenBox(boxName);
    final List<dynamic> allValues = [];
    try {
      for (var key in box.keys) {
        final value = box.get(key);
        if (value != null) {
          allValues.add(value);
        }
      }
    } catch (e) {
      return [];
    }
    return allValues;
  }

  static Future<int> getCount(String boxName) async {
    final box = await _getOrOpenBox(boxName);
    return box.length;
  }

  static Future<void> delete(String boxName, String key) async {
    final box = await _getOrOpenBox(boxName);
    await box.delete(key);
    await box.flush();
  }

  static Future<void> clear(String boxName) async {
    final box = await _getOrOpenBox(boxName);
    await box.clear();
  }

  static ValueListenable<Box> listenable(String boxName) {
    return Hive.box(boxName).listenable();
  }

  static Future<bool> containsKey(String boxName, String key) async {
    final box = await _getOrOpenBox(boxName);
    return box.containsKey(key);
  }
}
