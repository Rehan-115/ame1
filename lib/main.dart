import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/chat_service.dart';
import 'services/database_service.dart';
import 'services/documentation_service.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/maintenance_history_screen.dart';
import 'ui/screens/maintenance_start_screen.dart';
import 'ui/screens/smart_manual_screen.dart';
import 'ui/screens/navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AeroAssistAIApp());
}

class AeroAssistAIApp extends StatelessWidget {
  const AeroAssistAIApp({super.key});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(1200, 812),
        builder: (context, child) => MultiProvider(
          providers: [
            Provider<DatabaseService>(
              create: (_) {
                final db = DatabaseService();
                db.init().ignore(); // Initialize in background
                return db;
              },
            ),
            ProxyProvider<DatabaseService, ChatService>(
              create: (_) => ChatService(),
              update: (_, db, service) {
                service ??= ChatService();
                service.initSync(db);
                return service;
              },
            ),
            Provider<DocumentationService>(
              create: (_) => DocumentationService(),
            ),
          ],
          child: MaterialApp(
            title: 'AeroAssist AI',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            home: const NavigationShell(),
            routes: {
              '/home': (c) => const HomeScreen(),
              '/chat': (c) => const ChatScreen(),
              '/maintenance': (c) => const MaintenanceStartScreen(),
              '/manual': (c) => const SmartManualScreen(),
              '/history': (c) => const MaintenanceHistoryScreen(),
            },
          ),
        ),
      );
}
