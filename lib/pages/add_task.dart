import 'package:flutter/material.dart';
import '../data/task_repository.dart';
import '../models/task.dart';
import '../theme.dart';
import '../utils/date_format.dart';

class AddTaskPage extends StatefulWidget {
  final Category category;
  const AddTaskPage({super.key, required this.category});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _repo = TaskRepository();

  DateTime _dueDate = DateTime.now();
  bool _saving = false;

  Color get _accent => widget.category == Category.penting
      ? AppColors.accentDanger
      : AppColors.accentSuccess;

  String get _title => widget.category == Category.penting
      ? 'Tambah Tugas Penting'
      : 'Tambah Tugas Biasa';

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final task = Task(
      title: _titleCtl.text.trim(),
      description: _descCtl.text.trim().isEmpty ? null : _descCtl.text.trim(),
      dueDate: _dueDate,
      category: widget.category,
      isDone: false,
      createdAt: DateTime.now(),
    );
    await _repo.insert(task);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tugas tersimpan')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accent,
        title: Text(_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CategoryChip(category: widget.category),
              const SizedBox(height: 16),
              const _Label('TANGGAL JATUH TEMPO'),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(formatTanggalIndo(_dueDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _Label('JUDUL TUGAS'),
              TextFormField(
                controller: _titleCtl,
                decoration: InputDecoration(
                  hintText: widget.category == Category.penting
                      ? 'Contoh: Submit laporan'
                      : 'Contoh: Beli buah',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Judul wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              const _Label('DESKRIPSI'),
              TextFormField(
                controller: _descCtl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan tugas...',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _accent),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('SIMPAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = category == Category.penting
        ? AppColors.accentDanger
        : AppColors.accentSuccess;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          category.label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    ),
  );
}
