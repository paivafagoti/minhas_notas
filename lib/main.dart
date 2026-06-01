import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'db/app_database.dart';
import 'db/sqlite_setup.dart';
import 'data/notes_repository.dart';
import 'data/prefs_notes_repository.dart';
import 'data/sqlite_notes_repository.dart';
import 'auth/auth_store.dart';
import 'ui/login_page.dart';
import 'ui/notes_list_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupSqlite();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final NotesRepository repo = kIsWeb
        ? PrefsNotesRepository()
        : SqliteNotesRepository(AppDatabase.instance);

    return FutureBuilder<AppThemeMode>(
      future: ThemeController.load(),
      builder: (context, snap) {
        final initialMode = snap.data ?? AppThemeMode.dark;
        return _ThemedApp(repo: repo, initialMode: initialMode);
      },
    );
  }
}

class _ThemedApp extends StatefulWidget {
  const _ThemedApp({required this.repo, required this.initialMode});

  final NotesRepository repo;
  final AppThemeMode initialMode;

  @override
  State<_ThemedApp> createState() => _ThemedAppState();
}

class _ThemedAppState extends State<_ThemedApp> {
  late AppThemeMode _mode = widget.initialMode;

  Future<void> _setMode(AppThemeMode mode) async {
    setState(() => _mode = mode);
    await ThemeController.save(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = switch (_mode) {
      AppThemeMode.light => AppTheme.light(),
      AppThemeMode.dark => AppTheme.dark(),
      AppThemeMode.comfort => AppTheme.comfort(),
    };

    return MaterialApp(
      title: 'Minhas Notas',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routes: {
        '/login': (_) => LoginPage(
              themeMode: _mode,
              onThemeChanged: _setMode,
            ),
        '/notes': (_) => NotesListPage(
              repo: widget.repo,
              themeMode: _mode,
              onThemeChanged: _setMode,
            ),
      },
      home: FutureBuilder<bool>(
        future: AuthStore.isLoggedIn(),
        builder: (context, snapshot) {
          final loggedIn = snapshot.data ?? false;
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return loggedIn
              ? NotesListPage(
                  repo: widget.repo,
                  themeMode: _mode,
                  onThemeChanged: _setMode,
                )
              : LoginPage(
                  themeMode: _mode,
                  onThemeChanged: _setMode,
                );
        },
      ),
    );
  }
}
