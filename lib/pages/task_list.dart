import 'package:flutter/material.dart';
import '../data/task_repository.dart';
import '../models/task.dart';
import '../theme.dart';
import '../widgets/task_item.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _repo = TaskRepository();
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = await _repo.getAll();
    if (!mounted) return;
    setState(() {
      _tasks = list;
      _loading = false;
    });
  }

  Future<void> _toggle(Task t) async {
    await _repo.toggleDone(t.id!, !t.isDone);
    _refresh();
  }

  Future<void> _confirmDelete(Task t) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Hapus "${t.title}"? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.accentDanger),
            ),
          ),
        ],
      ),
    );
    if (yes == true) {
      await _repo.delete(t.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas dihapus')),
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? const _Empty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (_, i) => TaskItem(
                task: _tasks[i],
                onToggle: () => _toggle(_tasks[i]),
                onLongPress: () => _confirmDelete(_tasks[i]),
              ),
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'Belum ada tugas. Tambahkan dari Beranda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
