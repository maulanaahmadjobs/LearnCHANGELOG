# Setup Release-Please

Project ini pakai [release-please](https://github.com/googleapis/release-please) untuk otomasi versioning dan publishing package secara otomatis.

## Cara Kerjanya

1. **Commit message** harus ikut format [Conventional Commits](https://www.conventionalcommits.org/)
2. **Release-please** analisis commit-commit kamu dan tentuin nomor versi berikutnya
3. **GitHub Actions** otomatis bikinin PR release dan publish release-nya

## Format Commit Message

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Type yang Tersedia

- `feat`: Fitur baru (naik minor version, misal 1.0.0 → 1.1.0)
- `fix`: Bug fix (naik patch version, misal 1.0.0 → 1.0.1)
- `docs`: Cuma ubah dokumentasi
- `style`: Perubahan format code (spacing, formatting, dll) yang ga ngubah logic
- `refactor`: Refactor code yang bukan bug fix dan bukan fitur baru
- `perf`: Perubahan untuk improve performance
- `test`: Nambahin atau benerin test
- `chore`: Update build tools, dependencies, atau config

### Breaking Changes

Tambahin `BREAKING CHANGE:` di footer atau pakai `!` setelah type buat trigger major version bump (misal 1.0.0 → 2.0.0):

```
feat!: remove deprecated API
```

atau

```
feat: add new feature

BREAKING CHANGE: This removes the old API
```

## Proses Release

### Automated Release Flow

1. **Push commit** ke branch main dengan conventional commit message
2. **Release-please** bakal analisis dan bikin release PR kalau ada perubahan
3. **Review dan merge** release PR tersebut, nanti otomatis:
   - Version di-update di `Sources/Helpers/Version.swift`
   - `CHANGELOG.md` otomatis di-generate
   - Git tag dibuat (contoh: `v2.33.0`)
   - GitHub release dipublish
   
### Release Branches

Release-please juga support `release/*` branches kalau kamu mau manage release dari feature branch.

## Manual Release

Buat trigger release-please workflow secara manual:

1. Masuk ke tab Actions di GitHub
2. Pilih workflow "Release"
3. Klik "Run workflow"

## File Konfigurasi

- `release-please-config.json`: Config release-please
- `.release-please-manifest.json`: Tracking versi saat ini
- `.github/workflows/release.yml`: Workflow GitHub Actions untuk release

# Membuat Pull Request


### **Branch `featur` PR ke `main` branch (trigger release):**

- Begitu merge ke `main`, release-please mulai kerja
- Dia scan semua commit yang masuk
- Tentuin versi berikutnya berdasarkan type commit:

### **Release-please bikin PR otomatis**:

- Judul PR: `chore(main): release 1.1.0`
- Isi PR:
   - Update `CHANGELOG.md` dengan semua perubahan
   - Update versi di `Version.swift` jadi `1.1.0`
PR ini belum bikin `tag`, baru proposal

### **Merge release PR**:

- Begitu kamu merge release PR ini
- Baru bikin **tag** `v1.1.0`
- Baru publish GitHub Release

## Prioritas Version Bump

Kalau dalam 1 batch ada banyak type:

- Ada `feat!` atau `BREAKING CHANGE` → **MAJOR** (1.0.0 → 2.0.0) ← menang
- Ada `feat` → **MINOR** (1.0.0 → 1.1.0)
- Cuma `fix` → **PATCH** (1.0.0 → 1.0.1)
- Cuma `docs`, `style`, `refactor`, `test`, `chore` → **ga naik versi**, ga ada release
