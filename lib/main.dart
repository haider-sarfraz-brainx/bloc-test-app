import 'package:flutter/widgets.dart';

import 'constant/app_constant.dart';
import 'local_storage/hive_helper.dart';
import 'run_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  await HiveHelper.openBox(AppConstant.studentBox);
  runApp(const MyApp());
}
