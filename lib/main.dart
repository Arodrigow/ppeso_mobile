import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/history/pages/history_page.dart';
import 'package:ppeso_mobile/features/login/widgets/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:ppeso_mobile/features/meal/pages/meal_page.dart';
import 'package:ppeso_mobile/features/profile/pages/profile_page.dart';
import 'package:ppeso_mobile/shared/nav_layout.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const MyHomePage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        ShellRoute(
          builder: (context, state, child) {
            return MainLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: '/meal',
              builder: (context, state) => const MealPage(),
            ),
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'PPeso',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('pt', ''), // Portuguese
        Locale('es', ''), // Portuguese
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            // Set intl default locale for formatting
            Intl.defaultLocale = supportedLocale.languageCode;
            return supportedLocale;
          }
        }
        // Fallback
        Intl.defaultLocale = supportedLocales.first.languageCode;
        return supportedLocales.first;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final storage = FlutterSecureStorage();

  void checkLogin() async {
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      if (!mounted) return;
      context.replace('/profile');
    } else {
      if (!mounted) return;
      context.replace('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/svg_base.svg",
              width: 150,
              height: 150,
            ),
            const Text(
              "Bem vindo(a) ao PPeso",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
