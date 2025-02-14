import 'package:flutter/services.dart';
import 'package:vita_dl/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vita_dl/hive/hive_box_names.dart';
import 'package:vita_dl/hive_registrar.g.dart';
import 'package:vita_dl/models/download_item.dart';
import 'package:vita_dl/provider/config_provider.dart';
import 'package:vita_dl/models/content.dart';
import 'package:vita_dl/pages/content_page/content_page.dart';
import 'package:vita_dl/pages/home_page.dart';
import 'package:vita_dl/downloader/downloader.dart';
import 'package:vita_dl/utils/path.dart';
import 'package:vita_dl/utils/platform.dart';
import 'package:vita_dl/utils/request_storage_permission.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  final configPath = await getConfigPath();

  await Hive.initFlutter(pathJoin(configPath));

  Hive.registerAdapters();

  await Hive.openBox<DownloadItem>(downloadBoxName);
  await Hive.openBox<Content>(psvBoxName);
  await Hive.openBox<Content>(pspBoxName);

  await Downloader.instance.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ConfigProvider()..loadConfig(),
      child: const VitaDL(),
    ),
  );
}

class VitaDL extends HookWidget {
  const VitaDL({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      () async {
        globals.storagePermissionStatus = isAndroid
            ? await isAndroid11OrHigher()
                ? await Permission.manageExternalStorage.status
                : await Permission.storage.status
            : PermissionStatus.granted;
      }();
      return null;
    }, []);

    useEffect(() {
      if (isAndroid || isIOS) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ));
      }
      return null;
    }, []);

    return MaterialApp(
      title: 'VitaDL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(title: 'VitaDL'),
      onGenerateRoute: (settings) {
        if (settings.name == '/content') {
          final props = settings.arguments as ContentPageProps;
          return MaterialPageRoute(
            builder: (context) {
              return ContentPage(props: props);
            },
          );
        }
        return null;
      },
    );
  }
}
