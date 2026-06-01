import 'sqlite_setup_stub.dart'
    if (dart.library.io) 'sqlite_setup_io.dart' as impl;

Future<void> setupSqlite() async {
  impl.setupDatabaseFactory();
}
