import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import '/models/app_model.dart';
import 'models/harvest_model.dart';
import 'lang/l10n.dart';
import 'models/app_const.dart';
import 'models/company_model.dart';
import 'models/notification.dart';
import 'models/user_model.dart';
import 'models/revision_model.dart';
import 'models/work_model.dart';
import 'screens/splash_screen.dart';
import 'widgets/spin_circle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  runApp(
      MultiProvider(
          providers:[
            ChangeNotifierProvider(create: (_) => AppModel()),
            ChangeNotifierProvider(create: (_) => UserModel()),
            ChangeNotifierProvider(create: (_) => CompanyModel()),
            ChangeNotifierProvider(create: (_) => RevisionModel()),
            ChangeNotifierProvider(create: (_) => NotificationModel()),
            ChangeNotifierProvider(create: (_) => HarvestModel()),
            ChangeNotifierProvider(create: (_) => WorkModel()),
          ],
          child: MyApp()
      )
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      useDefaultLoading: false,
      overlayWidget: SpinKitCircle(color: Colors.white, size: 60,),
      overlayColor: Colors.black.withOpacity(0.6),
      overlayOpacity: 1,
      child: MaterialApp(
        title: 'FacePunch',
        debugShowCheckedModeBanner: context.watch<AppModel>().isDebug,
        theme: ThemeData(
          splashColor: Color(primaryColor),
          primaryColor: Color(primaryColor),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        locale: Locale(context.watch<UserModel>().locale),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: SplashScreen(),
      ),
    );
  }

}


