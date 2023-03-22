import 'package:hive/hive.dart';

class ProfileBox {
  static late Box box;

  static Future<void> init() async {
    box = await Hive.openBox('profileBox');
  }
}
