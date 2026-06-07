# MINFY — Personal Life OS

**Tagline:** *Simplify Your Life* — Satu tempat untuk mengelola uang, waktu, pekerjaan, dan tujuan hidup.

Aplikasi mobile Flutter berbasis SQLite. Saat ini berstatus **MVP modul Tasks** untuk skema sertifikasi BNSP SKKTI012017 (Pembuatan Aplikasi Mobile Berbasis Database). Roadmap MINFY: berkembang menjadi Personal Life OS dengan 3 pilar (Action, Insight, Growth) + integrasi AI agent.

---

## Status Saat Ini (Current State)

**Scope aktif:** Modul Tasks (todo list) saja. Bukan finance, bukan AI agent, bukan multi-modul.

### Fitur yang sudah ada

- Autentikasi lokal: SharedPreferences + SHA-256 (bukan biometrik/PIN)
- CRUD tugas: insert, list, toggle done, delete via long-press
- Kategori tugas: Penting (merah) / Biasa (hijau)
- Statistik: count selesai / belum selesai
- Grafik mingguan: bar chart Sen-Min (`fl_chart`)
- Ganti password + halaman developer info
- Logout dari AppBar Home + Settings
- Toggle visibility password di Login
- Lokalisasi Indonesia (locale `id_ID`)
- Material 3 + Inter font
- Env-driven default credential (`.env` + `flutter_dotenv`)

### Halaman aktif

1. Login (`lib/pages/login.dart`)
2. Home (`lib/pages/home.dart`) — greeting, stat cards, weekly chart, 4 navigation tiles
3. Add Task (`lib/pages/add_task.dart`) — form dengan kategori
4. Task List (`lib/pages/task_list.dart`) — daftar + toggle + long-press delete
5. Settings (`lib/pages/settings.dart`) — ganti password, info developer, logout

---

## Vision MINFY (Roadmap, BELUM DIIMPLEMENTASIKAN)

Direktif strategis untuk pengembangan jangka panjang. Saat menambah fitur baru, ikuti arah ini.

### 3 Pilar Navigasi (Future)

Bottom navigation 3 pilar menggantikan tile grid:

| Pilar | Pertanyaan | Modul |
|-------|------------|-------|
| **Action** | "Apa yang ingin kamu lakukan sekarang?" | Chat-like input universal: tugas, expense, notes, AI command |
| **Insight** | "Apa yang terjadi dalam hidupmu?" | Dashboard: cash flow, spending analysis, productivity score, weekly review |
| **Growth** | "Ke mana kamu ingin pergi?" | Goals: dana nikah, dana rumah, target investasi, milestone proyek |

### Modul Roadmap

- **Finance** — pencatatan pemasukan/pengeluaran, kategorisasi otomatis, donut chart
- **Tasks** — sudah ada (modul aktif sekarang)
- **Notes** — catatan bebas
- **Goals** — target jangka panjang dengan progress bar
- **AI Assistant (Hermes)** — NLP parser untuk input bahasa alami ("Beli makan siang 25rb")
- **Telegram Sync** — sinkronisasi data via bot Telegram saat tidak pegang HP
- **Habit Tracker** — kebiasaan harian
- **Calendar** — agregasi event tugas + meeting

### AI & Sync Layer (Hermes)

- **Hermes Agent** = backend Python (terpisah dari repo Flutter ini)
- **NLP parser** untuk Action bar: bahasa alami → struktur data
- **Offline fallback** = regex pola lokal
- **Online** = call Hermes API
- **Sync protocol** = flag `is_synced` + `updated_at` per row, background worker push/pull

---

## Tech Stack

| Komponen | Saat Ini | Roadmap |
|----------|----------|---------|
| Framework | Flutter ≥ 3.32.0 | sama |
| State management | `setState` | **Riverpod + riverpod_generator** (saat scope tumbuh) |
| Database lokal | sqflite | sama atau migrate ke Isar (kalau butuh schema-less + faster) |
| Key-value | SharedPreferences | flutter_secure_storage untuk token sensitif |
| Auth | SHA-256 password lokal | + Local Auth (biometrik / PIN) |
| Font | Inter (via `google_fonts`) | Inter atau Plus Jakarta Sans |
| Charts | `fl_chart` | sama |
| Env | `flutter_dotenv` | sama |
| Lokalisasi | `intl` locale `id_ID` | sama |
| HTTP (future) | — | `dio` untuk Hermes API |
| Background worker (future) | — | `workmanager` untuk sync |

---

## Arsitektur

### Saat Ini (Layered sederhana)

```
lib/
├── main.dart                       # Entry point
├── theme.dart                      # Design system
├── models/                         # Domain models
├── data/                           # Repository pattern
├── pages/                          # StatefulWidget screens
├── widgets/                        # Reusable UI
└── utils/                          # Helpers (crypto, date, dev info)
```

State management: `StatefulWidget` + `setState`. Cocok skala saat ini (5 page).

### Target (Feature-Driven + Riverpod)

```
lib/
├── core/                           # Pondasi sistem
│   ├── database/                   # SQLite + migrations
│   ├── network/                    # Dio + Hermes client
│   ├── theme/                      # Design system
│   └── local_auth/                 # Biometric/PIN
├── features/                       # Pisah per fitur, bukan per tipe file
│   ├── action/                     # Universal input chat UI
│   ├── insight/                    # Dashboard agregasi
│   ├── growth/                     # Goal tracking
│   ├── finance/                    # Finance CRUD
│   ├── tasks/                      # Tasks CRUD (refactor dari current state)
│   └── notes/                      # Notes CRUD
├── shared/                         # Widget reusable lintas feature
└── main.dart
```

Tiap `features/<name>/` berisi:
```
features/tasks/
├── data/
│   ├── task_model.dart
│   └── task_repository.dart
├── domain/
│   └── task_providers.dart         # Riverpod providers
└── presentation/
    ├── pages/
    └── widgets/
```

---

## Coding Conventions

### File & Naming

- **File**: `snake_case.dart`
- **Class**: `PascalCase`
- **Variabel/method**: `camelCase`
- **Konstanta**: `lowerCamelCase` di class (`AppColors.primary`)
- **Private**: prefix `_`
- **Identifier kode**: **English** (familiar)
- **String UI**: **Indonesia** (user-facing)
- Tidak pakai `halaman_` prefix untuk file (lebih dari satu kata aja gak perlu prefix domain)

### Code Style

- Tidak ada komentar di source code (`///` atau `//`). Penjelasan dipindah ke `docs/`.
- Nama identifier deskriptif → kode self-documenting.
- Validasi hanya di system boundary (user input, API). Trust internal call.
- Tidak ada error handling untuk skenario yang tidak mungkin terjadi.
- Tidak ada feature flag / backward-compat shim.
- Tidak ada placeholder / TODO comment.

### State Pattern

Saat ini (`setState`):
```dart
@override
void initState() {
  super.initState();
  _refresh();
}

Future<void> _refresh() async {
  final data = await _repo.getAll();
  if (!mounted) return;
  setState(() => _data = data);
}
```

Future (Riverpod) — saat scope tumbuh:
```dart
final tasksProvider = FutureProvider((ref) => ref.read(taskRepoProvider).getAll());

class TasksPage extends ConsumerWidget {
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    return ref.watch(tasksProvider).when(...);
  }
}
```

---

## Branding & Design System

### Palette Saat Ini

```dart
primary       = #1976D2   // Material Blue
accentDanger  = #DC2626   // merah (penting)
accentSuccess = #16A34A   // hijau (biasa)
surface       = #FFFFFF
background    = #F5F7FA
textPrimary   = #0F172A
textSecondary = #64748B
border        = #E2E8F0
```

### Palette Target (Premium "MINFY")

```
Deep Navy        — primary (premium, profesional, aman)
Electric Blue    — secondary (digital, AI, modern)
Off-White        — background (clean, low eye strain)
+ semantic       — success/danger/warning seperti sekarang
```

### Typography

- **Font**: Inter via `google_fonts` (sudah aktif).
- **Hierarchy**: AppBar 18 w600, body 14-15, label 11-12 uppercase w600.
- **Letter spacing**: tight di heading (-0.2), normal di body, sedikit lebar di button (0.2).

### Radius

```dart
AppRadius.card   = 12
AppRadius.input  = 10
AppRadius.button = 10
```

---

## Database Schema

### Saat Ini

```sql
-- SQLite (sqflite), version 1
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  due_date TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('penting','biasa')),
  is_done INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL
);
CREATE INDEX idx_tasks_category ON tasks(category);
CREATE INDEX idx_tasks_is_done  ON tasks(is_done);
```

`SharedPreferences` keys: `username`, `password_hash`, `is_logged_in`.

### Tabel yang Direncanakan (Future)

- `transactions` — finance entries (`amount`, `type`, `category_id`, `note`, `occurred_at`)
- `categories` — finance/task categories (extract dari enum hardcoded)
- `goals` — target jangka panjang
- `notes` — catatan
- `habits` + `habit_logs`
- `sync_queue` — pending push ke Hermes (flag `is_synced`, `updated_at`)

Tabel future tambahkan kolom audit standar:
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL
- `is_synced` INTEGER NOT NULL DEFAULT 0

---

## Testing

```powershell
flutter test
flutter analyze
```

Coverage saat ini:
- `test/data/auth_repository_test.dart`
- `test/data/task_repository_test.dart` (in-memory SQLite via `sqflite_common_ffi`)
- `test/models/task_test.dart`
- `test/utils/crypto_test.dart`
- `test/utils/date_format_test.dart`

Pola test repository: pakai constructor injection untuk lewatkan dependency (mis. `AuthRepository(defaultUsername: ..., defaultPassword: ...)`) supaya test tidak bergantung pada dotenv yang belum di-load di lingkungan test.

---

## Guidelines untuk Claude (Sesi Berikutnya)

### Prioritas

1. **User instructions selalu menang.** Kalau user minta sesuatu yang bertentangan dengan dokumen ini, ikuti user.
2. **Jangan refactor di luar scope task.** Vision MINFY bukan license untuk migrasi total ke Riverpod / 3 pilar dalam sekali sesi.
3. **Sebelum mengubah arsitektur (state management, folder layout), tanya user dulu.** Karena impact luas.
4. **Demo BNSP prioritas dekat.** Sampai sertifikasi selesai, jaga stabilitas fitur Tasks. Jangan break flow login → home → add → list → settings.

### Behavior Rules

- **No commit/push tanpa diminta.** User handle git sendiri.
- **No AI co-author lines, no emoji, no gradient.**
- **Identifier kode English, string UI Indonesia.**
- **Tidak ada `halaman_` prefix.**
- **Comment dihindari** — pindah penjelasan ke `docs/`.
- **Test setiap kali repository / model berubah.**
- **`flutter analyze` harus clean** sebelum tugas dianggap selesai.

### Saat Tambah Fitur Baru

1. Cek apakah fitur masuk salah satu pilar (Action / Insight / Growth). Kalau ya, lokasi target = `features/<modul>/`. Saat ini boleh tetap di `pages/` sambil refactor bertahap.
2. Buat repository sesuai pola `StorageInterface<T>` di [lib/data/storage_interface.dart](lib/data/storage_interface.dart).
3. Tambah migration kalau ada perubahan skema DB (bump `version` di [lib/data/database.dart](lib/data/database.dart) + `onUpgrade` callback).
4. Tulis test repository pakai in-memory SQLite.
5. Update [docs/asesor/12-code-explanations.md](docs/asesor/12-code-explanations.md) — penjelasan WHY untuk file baru.

### Saat Refactor Arsitektur (Future Effort)

1. Migrasi `setState` → Riverpod harus per-feature, satu PR satu feature.
2. Folder restructure ke `core/` + `features/` dilakukan sebelum tambah fitur kedua.
3. Pertahankan green test suite di tiap step.

---

## Identitas Project

| Field | Value |
|-------|-------|
| Nama aplikasi | MINFY |
| Package name (pubspec) | `minfy` |
| applicationId Android | `id.minh.minfy` |
| Versi | `1.0.0+1` |
| Developer | Muhammad Irfan Nur Hakim (NIM 2241720230) |

---

## Dokumentasi Tambahan

- [docs/asesor/](docs/asesor/) — dokumentasi demo sertifikasi BNSP (gitignored)
- [docs/asesor/diagrams/](docs/asesor/diagrams/) — ER diagram, class diagram, sequence diagram
- [docs/asesor/11-mapping-unit-kompetensi.md](docs/asesor/11-mapping-unit-kompetensi.md) — mapping kode ke unit kompetensi BNSP
- [docs/asesor/12-code-explanations.md](docs/asesor/12-code-explanations.md) — penjelasan kode per file (replaces in-code comments)
- [README.md](README.md) — pengantar publik + screenshot
