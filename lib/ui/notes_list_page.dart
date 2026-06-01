import 'package:flutter/material.dart';

import '../auth/auth_store.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';
import 'note_create_page.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({
    super.key,
    required this.repo,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final NotesRepository repo;
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  List<Note> _notes = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final notes = await widget.repo.listNotes();
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _notes = const [];
        _error = 'Não foi possível acessar os dados salvos.';
      });
    }
  }

  Future<void> _delete(Note note) async {
    final id = note.id;
    if (id == null) return;
    await widget.repo.deleteNote(id);
    await _refresh();
  }

  Future<void> _edit(Note note) async {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Conteúdo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final newTitle = titleController.text.trim();
    final newContent = contentController.text.trim();
    if (newTitle.isEmpty || newContent.isEmpty) return;

    await widget.repo.updateNote(
      note.copyWith(title: newTitle, content: newContent),
    );
    await _refresh();
  }

  Future<void> _goCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteCreatePage(repo: widget.repo),
      ),
    );
    if (created == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Notas'),
        actions: [
          PopupMenuButton<AppThemeMode>(
            tooltip: 'Tema',
            initialValue: widget.themeMode,
            onSelected: widget.onThemeChanged,
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
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () async {
              await AuthStore.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: _goCreate,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Minhas notas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_notes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Nenhuma nota ainda.'),
                )
              else
                ..._notes.map(
                  (n) => Dismissible(
                    key: ValueKey('note_${n.id ?? n.createdAt.millisecondsSinceEpoch}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      return showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Excluir nota?'),
                          content: Text('Tem certeza que deseja excluir "${n.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) async {
                      await _delete(n);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nota excluída.')),
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(n.title),
                        subtitle: Text(
                          n.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _edit(n),
                        trailing: IconButton(
                          tooltip: 'Excluir',
                          onPressed: () async => _delete(n),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

