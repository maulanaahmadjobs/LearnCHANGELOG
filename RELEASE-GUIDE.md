# Panduan Lengkap: Release-Please untuk iOS Project

Project ini menggunakan [release-please](https://github.com/googleapis/release-please) untuk otomasi versioning, pembaruan changelog, dan publishing release secara otomatis melalui **GitHub Actions**.

---

## Daftar Isi

1. [Konsep Dasar](#1-konsep-dasar)
2. [Format Commit Message](#2-format-commit-message-conventional-commits)
3. [Alur Lengkap: Dari Commit hingga Release](#3-alur-lengkap-dari-commit-hingga-release)
4. [Develop Changelog (CHANGELOG-DEVELOP.md)](#4-develop-changelog-changelog-developmd)
5. [Konfigurasi File](#5-konfigurasi-file)
6. [Tips & Best Practices](#6-tips--best-practices)
7. [Manual Trigger Release](#7-manual-trigger-release)
8. [Troubleshooting](#8-troubleshooting)
9. [Contoh Skenario Lengkap](#9-contoh-skenario-lengkap)
10. [Reference & Resource](#10-reference--resource)

---

## 1. Konsep Dasar

Release-please bekerja berdasarkan **Conventional Commits**:

1. Developer membuat commit dengan format tertentu
2. Release-please menganalisis commit history di branch `main`
3. Sistem menentukan versi berikutnya (major, minor, patch)
4. Secara otomatis membuat Release PR dan GitHub Release

> **Penting**: Release-please hanya berjalan di branch `main`. Branch `develop` punya workflow terpisah (`release-develop.yml`) yang mengupdate `CHANGELOG-DEVELOP.md`.

---

## 2. Format Commit Message (Conventional Commits)

### Struktur Dasar

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Penjelasan Setiap Bagian

- `type`: Jenis perubahan (wajib)
- `scope`: Area/modul yang diubah (opsional, dalam kurung kecil)
- `description`: Deskripsi singkat perubahan (wajib, huruf kecil, imperative mood)
- `body`: Penjelasan detail perubahan (opsional, pisahkan dari header dengan 1 baris kosong)
- `footer`: Metadata tambahan seperti issue reference (opsional)

### Contoh Commit yang Benar

```
feat(auth): tambah login dengan Google

Menambahkan integrasi Google OAuth untuk memudahkan user login.
Sekarang user bisa login dengan akun Google mereka.

Fixes #123
Closes #456
```

```
fix(dashboard): perbaiki crash saat load data kosong
```

```
docs: update README dengan instruksi setup
```

### Type yang Tersedia

| Type       | Efek Versi          | Muncul di CHANGELOG      | Keterangan                        |
|------------|---------------------|--------------------------|-----------------------------------|
| `feat`     | Minor (1.0 → 1.1)   | ✅ Ya                    | Fitur baru                        |
| `fix`      | Patch (1.0 → 1.0.1) | ✅ Ya                    | Bug fix                           |
| `perf`     | Patch               | ✅ Ya                    | Performance improvement           |
| `refactor` | Patch               | ✅ Ya                    | Refactor tanpa fitur/fix baru     |
| `docs`     | Patch               | ✅ Ya                    | Perubahan dokumentasi             |
| `style`    | ❌ Tidak naik       | ❌ Tidak                 | Format code, spacing              |
| `test`     | ❌ Tidak naik       | ❌ Tidak                 | Tambah/perbaiki unit test         |
| `chore`    | ❌ Tidak naik       | ❌ Tidak                 | Update build tools, dependencies  |
| `ci`       | ❌ Tidak naik       | ❌ Tidak                 | Perubahan GitHub Actions, workflow|

> 💡 `chore`, `ci`, `test`, `style` tidak muncul di CHANGELOG manapun — baik `CHANGELOG.md` maupun `CHANGELOG-DEVELOP.md`. Gunakan ini untuk perubahan internal yang tidak perlu diketahui pengguna.

### Breaking Changes

Breaking change memicu **MAJOR version bump** (1.0.0 → 2.0.0). Ada 2 cara:

**Cara 1: Gunakan `!` setelah type**

Cara 1: Gunakan `!` setelah type

```swift
feat!: hapus deprecated API

Fitur lama sudah tidak tersedia lagi dan tidak bisa di-downgrade.
```
feat!: hapus deprecated API

Fitur lama sudah tidak tersedia lagi dan tidak bisa di-downgrade.
```
## 3. Alur Lengkap: Dari Commit hingga Release

### Step 1: Buat Commit dengan Conventional Commits

**Cara 2: Gunakan `BREAKING CHANGE:` di footer**

# Commit dengan format yang benar
git commit -m "feat(payment): add Stripe integration"
```
feat: refactor authentication system

BREAKING CHANGE: Old login method no longer supported. Users must use new OAuth flow.
```

---

## 3. Alur Lengkap: Dari Commit hingga Release

### Step 1: Buat Commit dengan Conventional Commits

```bash
# Buat perubahan di file
git add .

# Commit dengan format yang benar
git commit -m "feat(payment): add GoPay integration"
```

### Step 2: Push dan Buat Pull Request

```bash
git push origin nama-branch-kamu
```

Buka Pull Request di GitHub:
- **From**: branch kamu (contoh: `feature/payment` atau `develop`)
- **To**: `main`
- Pastikan **judul PR** juga ikut format Conventional Commits — divalidasi otomatis oleh `conventional-commits.yml`

### Step 3: Tunggu CI Selesai

Setelah PR dibuat, GitHub Actions berjalan otomatis:
- `Validate PR title` — cek format judul PR
- `CI / Unit Testing (Xcode 16.4)` — build dan test
- `CI / Release Build` — khusus merge ke main

Status CI harus hijau sebelum melanjutkan.

### Step 4: Review dan Merge PR

1. Request review dari team member jika diperlukan
2. Tunggu approval dari minimal 1 reviewer
3. Merge PR menggunakan **"Squash and merge"**
   - Jangan gunakan "Merge pull request" biasa — commit history jadi kotor
   - Jangan gunakan "Rebase and merge" — bisa bikin release-please salah baca history
4. Klik **Confirm squash and merge**
5. Pilih **Delete branch** untuk membersihkan

### Step 5: Release-Please Bekerja (1-2 Menit)

Setelah PR di-merge ke `main`, Release-Please otomatis:

1. Scan commit history di branch `main`
2. Analisis conventional commits yang sudah masuk
3. Tentukan versi berikutnya:

| Kondisi                                 | Bump                  |
|-----------------------------------------|-----------------------|
| Ada `feat!` atau `BREAKING CHANGE`      | Major (1.0.0 → 2.0.0) |
| Ada `feat`                              | Minor (1.0.0 → 1.1.0) |
| Hanya `fix`, `perf`, `refactor`, `docs` | Patch (1.0.0 → 1.0.1) |
| Hanya `chore`, `ci`, `test`, `style`    | Tidak ada release     |

4. Buat Release PR otomatis dengan judul: `chore(main): release 1.1.0`

### Step 6: Review Release PR

1. Buka PR release yang dibuat bot `release-please[bot]`
2. Cek tab **Files changed**:
   - `CHANGELOG.md` — ada entry baru untuk versi baru
   - `LearnCHANGELOG/Sources/Version.swift` — versi terupdate
   - `.release-please-manifest.json` — versi manifest terupdate
3. **Jangan edit PR ini** — biarkan bot yang menangani

### Step 7: Merge Release PR

1. Klik **Squash and merge**
2. Klik **Confirm squash and merge**
3. **Jangan hapus branch** release PR — release-please butuh branch ini sebagai referensi

### Step 8: GitHub Actions Otomatis Melakukan (2-5 Menit)

Setelah release PR di-merge:

1. Membuat Git tag dengan format `v1.1.0`
2. Publish GitHub Release di halaman Releases
3. Update `Info.plist` dengan versi baru (via `release.yml`)
4. Update `Version.swift` dengan versi baru

### Step 9: Verifikasi Release

Buka tab **Releases** di GitHub. Verifikasi release `v1.1.0` sudah muncul dengan:
- Release notes otomatis dari CHANGELOG
- Daftar semua fitur & bug fix
- Git tag yang benar (`v1.1.0`)

### Step 10: Update Repository Lokal

```bash
# Pindah ke main branch
git checkout main

# Tarik semua update dari remote termasuk tags
git pull origin main --tags

# Verifikasi versi lokal
git tag -l | tail -5  # Lihat 5 tag terakhir

# Sync ke develop agar tidak ketinggalan
git checkout develop
git merge main
git push origin develop
```

1. Membuat Git tag dengan format v1.1.0
2. Publish GitHub Release di halaman Releases
3. Update CHANGELOG.md di branch main
4. Trigger publish workflow (jika ada untuk npm package, gem, dll)

## 4. Develop Changelog (CHANGELOG-DEVELOP.md)

`CHANGELOG-DEVELOP.md` adalah changelog untuk branch `develop` — preview dari perubahan yang belum dirilis ke production.

### Cara Kerjanya

Setiap push ke branch `develop`, workflow `release-develop.yml` otomatis:
1. Scan commits sejak tag release terakhir
2. Parse `feat`, `fix`, `perf` commits
3. Hitung versi berikutnya (preview)
4. Generate `CHANGELOG-DEVELOP.md` dan commit ke develop

### Perbedaan dengan CHANGELOG.md

|               | `CHANGELOG.md`           | `CHANGELOG-DEVELOP.md`         |
|---------------|--------------------------|--------------------------------|
| Branch        | `main`                   | `develop`                      |
| Dikelola oleh | release-please (resmi)   | `release-develop.yml` (custom) |
| Trigger       | Merge ke main            | Setiap push ke develop         |
| Berisi        | Release yang sudah resmi | Preview perubahan belum rilis  |
| Versi         | `1.1.0`                  | `1.1.0-dev`                    |
| Untuk         | Pengguna/publik          | Tim internal                   |

>  `chore`, `ci`, `test`, `style` juga tidak muncul di `CHANGELOG-DEVELOP.md`. Konsisten dengan `CHANGELOG.md`.

# Tarik semua update dari remote termasuk tags
git pull origin main --tags

## 5. Konfigurasi File

### Struktur File Penting

```
LearnCHANGELOG/
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Unit test & build validation
│       ├── release.yml               # Release-please (main branch)
│       ├── release-develop.yml       # Develop changelog generator
│       └── conventional-commits.yml  # Validasi PR title
├── release-please-config.json        # Konfigurasi release-please
├── .release-please-manifest.json     # Tracking versi (jangan edit manual)
├── CHANGELOG.md                      # Changelog production
├── CHANGELOG-DEVELOP.md              # Changelog develop (preview)
└── LearnCHANGELOG/
    ├── Info.plist                    # Auto-update versi oleh release.yml
    └── Sources/Version.swift         # Auto-update versi oleh release-please
```

### release-please-config.json

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "packages": {
    ".": {
      "release-type": "simple",
      "bump-minor-pre-major": false,
      "extra-files": [
        "LearnCHANGELOG/Info.plist",
        "LearnCHANGELOG/Sources/Version.swift"
      ],
      "changelog-sections": [
        { "type": "feat",     "section": "✨ Features",         "hidden": false },
        { "type": "fix",      "section": "🐛 Bug Fixes",        "hidden": false },
        { "type": "perf",     "section": "⚡ Performance",      "hidden": false },
        { "type": "refactor", "section": "♻️ Code Refactoring", "hidden": false },
        { "type": "docs",     "section": "📝 Documentation",    "hidden": false },
        { "type": "chore",    "section": "🔧 Maintenance",      "hidden": true  },
        { "type": "ci",       "section": "👷 CI/CD",            "hidden": true  },
        { "type": "test",     "section": "✅ Tests",            "hidden": true  },
        { "type": "style",    "section": "💅 Style",            "hidden": true  }
      ]
    }
  }
}
```

### .release-please-manifest.json

```json
{
  ".": "0.8.1"
}
```

> File ini otomatis di-update oleh release-please. **Jangan edit manual.**

`.release-please-manifest.json` (Tracking Versi)

## 6. Tips & Best Practices

### DO's

- Gunakan **squash and merge** untuk semua PR
- Tulis commit message yang deskriptif dan jelas
- Gunakan `scope` untuk menunjukkan area perubahan: `feat(auth): ...`
- Link issue di footer: `Fixes #123`
- Kelompokkan related changes dalam 1 PR
- Review `CHANGELOG.md` di Release PR sebelum merge
- Sync `develop` dari `main` setelah setiap release

### DON'Ts

- Jangan gunakan **"Merge pull request"** biasa (tanpa squash)
- Jangan gunakan **"Rebase and merge"** — bisa bikin release-please salah baca history
- Jangan edit Release PR dari bot secara manual
- Jangan langsung push ke `main` tanpa PR
- Jangan edit `.release-please-manifest.json` secara manual
- Jangan hapus branch Release PR setelah merge

5. Tips & Best Practices

## 7. Manual Trigger Release

Jika ingin trigger release-please workflow secara manual (misal setelah fix bug di workflow):

1. Buka tab **Actions** di GitHub
2. Pilih workflow **"Release Changelog"**
3. Klik **"Run workflow"**
4. Pilih branch `main`
5. Klik **"Run workflow"**

Release-please akan scan ulang dan membuat Release PR jika ada perubahan yang belum di-release.


## 8. Troubleshooting

### Release PR Tidak Muncul

**Penyebab**: Tidak ada `feat`, `fix`, `perf`, `refactor`, atau `docs` commits sejak release terakhir.

**Solusi**: Cek commit history:

```bash
# Lihat commit terbaru
git log --oneline -10

# Pastikan format: type(scope): description
# Contoh yang benar: feat(auth): add login
# Contoh yang salah: Add login feature (tidak ada type)
```

### Versi Tidak Naik Sesuai Ekspektasi

**Penyebab**: Breaking change tidak ditandai dengan benar, atau tipe commit salah.

**Solusi**:

```bash
# Untuk major bump, pastikan pakai ! atau BREAKING CHANGE:
git commit -m "feat!: remove old API"

# Untuk minor bump, pastikan pakai feat:
git commit -m "feat(ui): add dark mode"

# Untuk patch bump, pastikan pakai fix: atau perf:
git commit -m "fix(crash): handle nil response"
```

### CHANGELOG-DEVELOP.md Tidak Terupdate

**Penyebab**: Workflow `release-develop.yml` tidak berjalan, atau commit tidak menggunakan format yang benar.

**Solusi**:
1. Cek tab **Actions** → pilih workflow **"Release Develop Changelog"**
2. Pastikan file `release-develop.yml` ada di `.github/workflows/`
3. Pastikan ada commit `feat:` atau `fix:` yang di-push ke develop — commit `ci:` atau `chore:` tidak akan trigger update versi

### Release PR Merge Gagal / Konflik

**Penyebab**: Ada perubahan di `main` sejak Release PR dibuat, menyebabkan konflik di `CHANGELOG.md` atau manifest.

**Solusi**:
1. Tutup Release PR lama
2. Trigger manual release workflow (lihat bagian 7)
3. Release-please akan membuat PR baru yang sudah up-to-date

### Info.plist Tidak Terupdate Setelah Release

**Penyebab**: Step "Update Info.plist" di `release.yml` gagal, biasanya karena permission issue.

**Solusi**: Pastikan `GITHUB_TOKEN` punya permission `contents: write` di `release.yml`:

```yaml
permissions:
  contents: write
  pull-requests: write
```

---

## 9. Contoh Skenario Lengkap

### Skenario A: Sprint Normal (feat + fix)

```bash
# Week 1: Feature baru
git commit -m "feat(payment): add GoPay integration"
git commit -m "feat(auth): implement Face ID login"

# Week 2: Bug fix
git commit -m "fix(crash): handle nil response dari server"
git commit -m "ci: update xcode version to 16.4"  # tidak naik versi
```

**Hasil setelah semua PR merge ke main:**
- Release-please scan: ada 2 `feat` + 1 `fix` (ci tidak dihitung)
- Versi naik: `1.0.0` → `1.1.0` (minor bump karena ada `feat`)
- CHANGELOG.md entry baru dengan 2 features + 1 bug fix

### Skenario B: Hotfix Darurat

```bash
# Ada crash di production, perlu fix cepat
git checkout -b hotfix/crash-payment main
git commit -m "fix(payment): perbaiki crash saat amount null"
# Buat PR langsung ke main (bypass develop)
```

**Hasil:**
- Versi naik: `1.1.0` → `1.1.1` (patch bump)
- Setelah release, sync ke develop: `git merge main`

### Skenario C: Breaking Change

```bash
git commit -m "feat!: migrasi ke SwiftUI, hapus UIKit ViewControllers"
```

**Hasil:**
- Versi naik: `1.1.1` → `2.0.0` (major bump)
- CHANGELOG.md menampilkan section Breaking Changes

---

## 10. Reference & Resource

- [Conventional Commits](https://www.conventionalcommits.org/) — spesifikasi format commit
- [Release-Please Docs](https://github.com/googleapis/release-please) — dokumentasi resmi
- [Semantic Versioning](https://semver.org/) — standar versioning (major.minor.patch)
- [GitHub Actions](https://docs.github.com/en/actions) — dokumentasi GitHub Actions
- [git-cliff](https://git-cliff.org/) — alternatif changelog generator yang lebih powerful
