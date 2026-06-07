import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../theme.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _auth = AuthRepository();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _userCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final u = _userCtl.text.trim();
    final p = _passCtl.text;
    if (u.isEmpty || p.isEmpty) {
      _showSnack('Username dan password wajib diisi', error: true);
      return;
    }
    setState(() => _loading = true);
    final ok = await _auth.verify(u, p);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      _showSnack('Username atau password salah', error: true);
      return;
    }
    await _auth.setLoggedIn(true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.accentDanger : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'MINFY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kelola tugasmu, raih harimu',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),
              const _Label('USERNAME'),
              TextField(
                controller: _userCtl,
                decoration: const InputDecoration(hintText: 'user'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              const _Label('PASSWORD'),
              TextField(
                controller: _passCtl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: _obscure
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('LOGIN'),
              ),
            ],
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
