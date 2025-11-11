enum Flavour{
  dev,
  staging,
  production
}

class FlavourConfig{
  final Flavour flavour;
  final String baseUrl;
  final String name;

  static FlavourConfig? _instance;

  FlavourConfig._({required this.flavour, required this.name, required this.baseUrl});

 factory FlavourConfig({required flavour, required baseUrl, required name}){
    _instance ??= FlavourConfig._(flavour: flavour, baseUrl: baseUrl, name: name);
    return _instance!;
 }
  static FlavourConfig get instance {
   if(_instance==null){
     throw Exception("Not initialized");
   }
   return _instance!;
  }

  static bool isDev()=> instance.flavour == Flavour.dev;
  static bool isStaging()=> instance.flavour == Flavour.staging;
  static bool isProduction()=> instance.flavour == Flavour.production;
}

