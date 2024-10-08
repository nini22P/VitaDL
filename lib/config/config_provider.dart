import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'config.dart';

class ConfigProvider with ChangeNotifier {
  Config _config = Config(
    app: Source(type: 'local', updateTime: '', url: ''),
    dlc: Source(type: 'local', updateTime: '', url: ''),
  );

  Config get config => _config;

  Future<void> loadConfig() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/config/config.json');

    if (await file.exists()) {
      String contents = await file.readAsString();
      _config = Config.fromJson(json.decode(contents));
      notifyListeners();
    }
  }

  Future<void> saveConfig() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/VitaDL/config/config.json');
    await file.writeAsString(json.encode(_config.toJson()));
  }

  void updateConfig(Source? app, Source? dlc) {
    if (app != null) {
      _config.app = app;
    }
    if (dlc != null) {
      _config.dlc = dlc;
    }
    saveConfig();
    notifyListeners();
  }
}