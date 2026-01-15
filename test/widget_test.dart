import 'dart:io';

import 'package:bloc_test/constant/app_constant.dart';
import 'package:bloc_test/local_storage/hive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_test/run_app.dart';

void main() {
  setUpAll(() async {
    final hiveDir = await Directory.systemTemp.createTemp('widget_test_hive_');
    await HiveHelper.init(path: hiveDir.path);
    await HiveHelper.openBox(AppConstant.studentBox);
    await HiveHelper.clear(AppConstant.studentBox);
  });

  testWidgets('App shows students screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Students'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
