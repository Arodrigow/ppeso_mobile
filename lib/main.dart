import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/history/pages/history_page.dart';
import 'package:ppeso_mobile/features/login/widgets/login_page.dart';
import 'package:ppeso_mobile/features/login/widgets/register_page.dart';
import 'package:go_router/go_router.dart';
import 'package:ppeso_mobile/features/meal/pages/meal_page.dart';
import 'package:ppeso_mobile/features/profile/pages/profile_page.dart';
import 'package:ppeso_mobile/shared/nav_layout.dart';
import 'package:ppeso_mobile/shared/requests/daily_requests.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter router;

  @override
  void initState() {
    super.initState();

    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const MyHomePage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
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
  }

  @override
  Widget build(BuildContext context) {
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
        Locale('en', ''),
        Locale('pt', ''),
        Locale('es', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            Intl.defaultLocale = supportedLocale.languageCode;
            return supportedLocale;
          }
        }
        Intl.defaultLocale = supportedLocales.first.languageCode;
        return supportedLocales.first;
      },
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      await loadSession(ref);

      final token = ref.read(authTokenProvider);
      if (!mounted) return;

      if (token != null) {
        final user = ref.read(userProvider);
        final userId = _parseUserId(user?['id']);
        if (userId != null) {
          try {
            await ensureDailyForToday(userId: userId, token: token);
          } catch (_) {
            // Don't block app entry on daily ensure.
          }
        }
        if (!mounted) return;
        context.replace('/meal');
      } else {
        context.replace('/login');
      }
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
              'assets/svg/svg_base.svg',
              width: 150,
              height: 150,
            ),
            const Text(
              'Bem vindo(a) ao PPeso',
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

  int? _parseUserId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
