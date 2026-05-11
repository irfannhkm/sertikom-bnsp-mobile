import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/task_repository.dart';
import '../models/task.dart';
import '../theme.dart';
import '../utils/date_format.dart';
import '../widgets/nav_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_chart.dart';
import 'add_task.dart';
import 'login.dart';
import 'settings.dart';
import 'task_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _taskRepo = TaskRepository();
  final _authRepo = AuthRepository();

  int _done = 0;
  int _undone = 0;
  String _username = 'User';
  List<int> _weekly = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final done = await _taskRepo.countDone();
    final undone = await _taskRepo.countUndone();
    final user = await _authRepo.getUsername() ?? 'User';
    final weekly = await _taskRepo.weeklyDoneCounts(DateTime.now());
    if (!mounted) return;
    setState(() {
      _done = done;
      _undone = undone;
      _username = user;
      _weekly = weekly;
    });
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _greetingCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'TUGAS SELESAI',
                    value: _done,
                    valueColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'BELUM SELESAI',
                    value: _undone,
                    valueColor: AppColors.accentDanger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            WeeklyChart(counts: _weekly),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                NavButton(
                  icon: Icons.priority_high,
                  label: 'Tambah Tugas Penting',
                  iconColor: AppColors.accentDanger,
                  onTap: () =>
                      _open(const AddTaskPage(category: Category.penting)),
                ),
                NavButton(
                  icon: Icons.add_task,
                  label: 'Tambah Tugas Biasa',
                  iconColor: AppColors.accentSuccess,
                  onTap: () =>
                      _open(const AddTaskPage(category: Category.biasa)),
                ),
                NavButton(
                  icon: Icons.list_alt,
                  label: 'Daftar Tugas',
                  iconColor: AppColors.primary,
                  onTap: () => _open(const TaskListPage()),
                ),
                NavButton(
                  icon: Icons.settings,
                  label: 'Pengaturan',
                  iconColor: AppColors.textSecondary,
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    final loggedOut = await navigator.push<bool>(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                    if (!mounted) return;
                    if (loggedOut == true) {
                      navigator.pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    } else {
                      _refresh();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _greetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $_username',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            formatTanggalLengkap(DateTime.now()),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
