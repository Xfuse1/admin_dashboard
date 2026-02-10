import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import 'config/di/injection_container.dart';
import 'config/routes/app_router.dart';
import 'core/firebase/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent Google Fonts from downloading fonts at runtime (saves ~100+ requests)
  GoogleFonts.config.allowRuntimeFetching = false;

  // Setup global error handling
  _setupErrorHandling();

  // Use path URL strategy for cleaner URLs (no hash)
  usePathUrlStrategy();

  // Initialize Firebase before dependencies
  try {
    await FirebaseService.instance.initialize();
  } catch (e, stack) {
    logger.error('Firebase initialization failed', e, stack);
  }

  // Initialize dependencies
  try {
    await initDependencies();
  } catch (e, stack) {
    logger.error('Dependency injection failed', e, stack);
  }

  logger.info('App started successfully');
  runApp(const AdminDashboardApp());
}

/// Sets up global error handling for the app.
void _setupErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.error('Flutter Error', details.exception, details.stack);
    // In release mode, report to crash analytics
    if (kReleaseMode) {
      // TODO: Send to Firebase Crashlytics or similar service
    }
  };

  // Handle errors not caught by Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Platform Error', error, stack);
    return true;
  };
}

/// Root application widget.
class AdminDashboardApp extends StatefulWidget {
  const AdminDashboardApp({super.key});

  @override
  State<AdminDashboardApp> createState() => _AdminDashboardAppState();
}

class _AdminDashboardAppState extends State<AdminDashboardApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckStatus());
    _router = AppRouter.createRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
      ],
      child: ToastificationWrapper(
        child: MaterialApp.router(
          title: 'لوحة تحكم التوصيل',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,

          // Localization
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Router
          routerConfig: _router,
        ),
      ),
    );
  }
}
