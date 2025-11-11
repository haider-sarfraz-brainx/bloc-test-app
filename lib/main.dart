import 'package:bloc_test/flavour/flavour_config.dart';
import 'package:bloc_test/main_common.dart';

/// Default main entry point - uses dev flavor
/// For other flavors, use:
/// - main_dev.dart (Development)
/// - main_staging.dart (Staging) 
/// - main_production.dart (Production)
void main() {
  mainCommon(
    flavour: Flavour.dev,
    baseUrl: "https://www.dev_example.come",
    name: "Dev",
  );
}


