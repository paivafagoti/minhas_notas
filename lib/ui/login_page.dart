import 'package:flutter/material.dart';

import '../auth/auth_store.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final user = _userController.text.trim();
    final pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha usuário e senha.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthStore.login(username: user, password: pass);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/notes');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          _ThemeMenu(
            value: widget.themeMode,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _userController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Usuário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              obscureText: true,
              onSubmitted: (_) => _loading ? null : _doLogin(),
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _doLogin,
              child: Text(_loading ? 'Entrando...' : 'Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeMenu extends StatelessWidget {
  const _ThemeMenu({required this.value, required this.onChanged});

  final AppThemeMode value;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppThemeMode>(
      tooltip: 'Tema',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: AppThemeMode.light,
          child: Text('Modo claro'),
        ),
        PopupMenuItem(
          value: AppThemeMode.dark,
          child: Text('Modo escuro'),
        ),
        PopupMenuItem(
          value: AppThemeMode.comfort,
          child: Text('Conforto ocular'),
        ),
      ],
      icon: const Icon(Icons.color_lens_outlined),
    );
  }
}

