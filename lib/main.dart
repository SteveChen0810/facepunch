import 'package:facepunch/models/harvest_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'lang/l10n.dart';
import 'models/app_const.dart';
import 'models/company_model.dart';
import 'package:provider/provider.dart';
import 'models/notification.dart';
import 'models/user_model.dart';
import 'models/revision_model.dart';
import 'models/work_model.dart';
import 'screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            ChangeNotifierProvider(create: (_) => UserModel()),
            ChangeNotifierProvider(create: (_) => CompanyModel()),
            ChangeNotifierProvider(create: (_) => RevisionModel()),
            ChangeNotifierProvider(create: (_) => NotificationModel(),lazy: false,),
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
    return MaterialApp(
      title: 'Facepunch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Color(primaryColor),
        accentColor: Color(primaryColor),
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
    );
  }

}


