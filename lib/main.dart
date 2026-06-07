import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/auth_repository.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('id_ID');
  final auth = AuthRepository();
  await auth.seedDefaultUserIfMissing();
  final loggedIn = await auth.isLoggedIn();
  runApp(MinfyApp(initialLoggedIn: loggedIn));
}

class MinfyApp extends StatelessWidget {
  final bool initialLoggedIn;
  const MinfyApp({super.key, required this.initialLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MINFY',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: initialLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
