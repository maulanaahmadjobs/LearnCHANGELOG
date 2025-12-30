# Panduan Lengkap: Release-Please untuk Otomasi Versioning & Publishing

Project ini menggunakan [release-please](https://github.com/googleapis/release-please) untuk otomasi versioning, pembaruan changelog, dan publishing package secara otomatis melalui Gitlab/Jenkins Actions.

## 1. Konsep Dasar

Release-please bekerja berdasarkan Conventional Commits:

1. Developer membuat commit dengan format tertentu
2. Release-please menganalisis commit history
3. Sistem menentukan versi berikutnya (major, minor, patch)
4. Secara otomatis membuat PR release dan publish

## 2. Format Commit Message (Conventional Commits)

1. **Commit message** harus ikut format [Conventional Commits](https://www.conventionalcommits.org/)
2. **Release-please** analisis commit-commit kamu dan tentuin nomor versi berikutnya
3. **GitHub Actions** otomatis bikinin PR release dan publish release-nya

### Struktur Dasar

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Penjelasan Setiap Bagian

- `type`: Jenis perubahan (wajib)
- `scope`: Area/modul yang diubah (opsional, dalam kurung kecil)
- `description`: Deskripsi singkat perubahan (wajib, gunakan imperative mood)
- `body`: Penjelasan detail perubahan (opsional, pisahkan dari header dengan 1 baris kosong)
- `footer`: Metadata tambahan seperti issue reference (opsional)

### Contoh Commit yang Benar

```swift
feat(auth): tambah login dengan Google

Menambahkan integrasi Google OAuth untuk memudahkan user login.
Sekarang user bisa login dengan akun Google mereka.

Fixes #123
Closes #456
```

```swift
fix(dashboard): perbaiki crash saat load data kosong
```

```swift
docs: update README dengan instruksi setup
```

### Type yang Tersedia

- `feat`: **Fitur baru** (naik minor version, misal 1.0.0 → 1.1.0)
- `fix`: **Bug fix** (naik patch version, misal 1.0.0 → 1.0.1)
- `docs`: **Dokumentasi**
- `style`: **Perubahan format code** (spacing, formatting, dll) yang ga ngubah logic
- `refactor`: **Refactor code** yang bukan bug fix dan bukan fitur baru
- `perf`: **Performance improvement** Perubahan untuk improve performance
- `test`: **Test updates** Tambah/perbaiki unit test, integration test
- `chore`: **Build & dependencies** Update build tools, dependencies, atau config
- `ci`: **CI/CD changes** Perubahan GitHub Actions / Gitlab / Jenkins, workflow

### Breaking Changes

Breaking change memicu **MAJOR version bump** (1.0.0 → 2.0.0). Ada 2 cara untuk menandainya:

Tambahin `BREAKING CHANGE:` di footer atau pakai `!` setelah type buat trigger major version bump (misal 1.0.0 → 2.0.0):

Cara 1: Gunakan `!` setelah type

```swift
feat!: hapus deprecated API

Fitur lama sudah tidak tersedia lagi dan tidak bisa di-downgrade.
```

Cara 2: Gunakan `BREAKING CHANGE`: di footer

```swift
feat: refactor authentication system

BREAKING CHANGE: Old login method no longer supported. Users must use new OAuth flow.
```
## 3. Alur Lengkap: Dari Commit hingga Release

### Step 1: Buat Commit dengan Conventional Commits

```swift
# Buat perubahan di file
git add .

# Commit dengan format yang benar
git commit -m "feat(payment): add Stripe integration"
```

### Step 2: Buat dan Submit Pull Request / Merge Request

1. Push branch ke GitHub / Merge Request ke Gitlab

```swift
git push origin nama-branch-kamu
```

2. Buka Pull Request / Merge Request

  - Masuk ke tab **Pull Requests di GitHub** / **di Gitlab Merge Request**
  - Klik New **pull request** atau Compare & pull request / **merge request**
  - Pastikan:
    - **From**: branch kamu (contoh: `development` / `feature/payment`)
    - **To**: `main` branch
  - Klik Create pull request / Merge request

3. Isi PR description (gunakan template jika ada)

**Step 3: Tunggu CI Selesai**

Setelah PR dibuat, GitHub Actions / Gitlab Actions akan berjalan otomatis:

  - `Validate PR Title / Validate PR title`
  - `CI / Test (Xcode 16.4)`
  - Build dan testing lainnya

Status CI harus hijau (✓) sebelum melanjutkan. Jika ada yang merah, cek error dan perbaiki.
Step 4: Review dan Merge PR Pertama

1. **Request review** dari team member jika diperlukan
2. **Tunggu approval** dari minimal 1 reviewer
3. **Merge PR** menggunakan "Squash and merge"
   - !Jangan gunakan "`Merge pull request`" biasa
   - Squash merge lebih rapi untuk commit history
4. Klik **Confirm squash and merge**
5. Pilih **Delete branch** untuk membersihkan

**Step 5: Release-Please Bekerja (1-2 Menit)**

Setelah PR di-merge ke `main`, Release-Please akan otomatis:

1. Scan commit history di branch `main`
2. Analisis conventional commits yang sudah masuk
3. Tentukan versi berikutnya:

Ada `feat!` atau `BREAKING CHANGE` → Major (1.0.0 → 2.0.0)
Ada `feat` → Minor (1.0.0 → 1.1.0)
Hanya `fix` → Patch (1.0.0 → 1.0.1)
Hanya `docs`, `style`, `refactor`, `test`, `chore` → Tidak ada release


Buat Release PR otomatis dengan judul: chore(main): release 1.1.0

Step 6: Review Release PR

1. Buka PR release yang baru dibuat (biasanya dari bot release-please)
2. Cek tab Files changed:

   - `CHANGELOG.md` - ada entry baru untuk versi baru
   - `Sources/Helpers/Version.swift` - versi terupdate (contoh: `1.1.0`)
   - Daftar semua perubahan tercatat dengan baik

**Jangan edit PR** ini - biarkan bot yang menangani

Step 7: Merge Release PR

1. Klik Squash and merge (sama seperti PR biasa)
2. Klik Confirm squash and merge
3. Jangan hapus branch release PR

Step 8: GitHub Otomatis Melakukan (2-5 Menit)

Setelah release PR di-merge, GitHub Actions otomatis:

1. Membuat Git tag dengan format v1.1.0
2. Publish GitHub Release di halaman Releases
3. Update CHANGELOG.md di branch main
4. Trigger publish workflow (jika ada untuk npm package, gem, dll)

Step 9: Verifikasi Release

Buka tab Releases di GitHub
Verifikasi release v1.1.0 sudah muncul dengan:
  - Release notes otomatis dari `CHANGELOG`
  - Daftar semua fitur & bug fix
  - Git tag yang benar

Step 10: Update Repository Lokal

```swift
# Pindah ke main branch
git checkout main

# Tarik semua update dari remote termasuk tags
git pull origin main --tags

# Verifikasi versi lokal
git tag -l | tail -5  # Lihat 5 tag terakhir
```

4. Konfigurasi Release-Please
File-File Penting
project-root/
├── release-please-config.json
├── .release-please-manifest.json
└── .github/workflows/
    └── release.yml
release-please-config.json (Contoh)

```swift
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "swift",
  "bump-minor-pre-major": false,
  "changelog-sections": [
    {
      "type": "feat",
      "section": "Features",
      "hidden": false
    },
    {
      "type": "fix",
      "section": "Bug Fixes",
      "hidden": false
    },
    {
      "type": "perf",
      "section": "Performance",
      "hidden": false
    }
  ],
  "github-release": true,
  "draft": false,
  "prerelease": false
}
```

`.release-please-manifest.json` (Tracking Versi)

```swift
{
  ".": "1.0.0"
}
```

**Catatan**: File ini otomatis di-update oleh release-please, jangan edit manual.
.github/workflows/release.yml (Workflow GitHub Actions)
Workflow ini menjalankan release-please secara otomatis setelah push ke main.

5. Tips & Best Practices

**DO's**

  - Gunakan squash and merge untuk PR yang kompleks
  - Tulis commit message yang deskriptif dan jelas
  - Gunakan scope untuk menunjukkan area perubahan: feat(auth): ...
  - Link issue di footer: Fixes `#123`
  - Kelompokkan related changes dalam 1 PR
  - Review CHANGELOG sebelum merge release PR

**DON'Ts**

  - Jangan gunakan "Merge pull request" biasa (tanpa squash)
  - Jangan edit Release PR dari bot secara manual
  - Jangan langsung push ke main tanpa PR
  - Jangan gunakan type yang tidak ada atau custom type
  - Jangan lupa conventional commits format


6. Manual Trigger Release
Jika ingin trigger release-please workflow secara manual:

  - Buka tab Actions di GitHub
  - Pilih workflow "Release" atau "release-please"
  - Klik "Run workflow"
  - Pilih branch main
  - Klik "Run workflow"

Release-please akan scan ulang dan membuat PR release jika ada perubahan yang belum di-release.

7. Troubleshooting
Release PR Tidak Muncul
Penyebab: Tidak ada conventional commits yang semestinya naik versi
Solusi: Cek apakah commit menggunakan format yang benar:

```swift
# Lihat commit terbaru

git log --oneline -10

# Pastikan format: type(scope): description
# Contoh: feat(auth): add login
```

Versi Tidak Naik Sesuai
Penyebab: Breaking change tidak ditandai dengan benar
Solusi: Pastikan menggunakan `!` atau `BREAKING CHANGE`: footer:

```swift
git commit -m "feat!: remove old API"
```

Release PR Merge Gagal
Penyebab: Konflik file atau perubahan di `main` sejak PR dibuat
Solusi:

1. Tutup release PR lama
2. Trigger manual release workflow
3. Release-please akan membuat PR baru yang sudah up-to-date

`CHANGELOG` Format Tidak Benar
Penyebab: Konfigurasi `release-please-config.json` mungkin tidak tepat
Solusi: Verifikasi file konfigurasi sesuai dengan format yang benar

8. Contoh Skenario Lengkap
Skenario: Menambah 3 Fitur dalam 1 Release

```swift
# Day 1: Feature authentication
git commit -m "feat(auth): implement JWT token"

# Day 2: Feature payment
git commit -m "feat(payment): add Stripe integration"

# Day 3: Bug fix performance
git commit -m "fix(database): optimize query performance"
```

Hasil:

  - Merge semua PR ke `main` dengan squash
  - Release-please scan: ada 2 `feat` + 1 `fix`
  - Versi naik: 1.0.0 → 1.1.0 (minor bump, karena ada `feat`)
  - Release PR dibuat otomatis dengan semua 3 perubahan di CHANGELOG


9. Release dengan Multiple Packages
Jika project punya multiple packages/workspaces:

```swift
{
  "packages": {
    "packages/core": {
      "release-type": "npm"
    },
    "packages/cli": {
      "release-type": "npm"
    }
  }
}
```
Setiap package bisa punya versi sendiri dan release terpisah.


10. **Reference & Resource**
  - Conventional Commits: https://www.conventionalcommits.org/
  - Release-Please Docs: https://github.com/googleapis/release-please
  - Semantic Versioning: https://semver.org/
  - GitHub Actions: https://docs.github.com/en/actions
