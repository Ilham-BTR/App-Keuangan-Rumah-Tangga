# Aplikasi Keuangan Rumah Tangga 🏠💰

Aplikasi Android untuk mencatat **pemasukan & pengeluaran bulanan rumah tangga**.
Dibangun dengan **Flutter** (gratis) + **Supabase** (backend gratis: Postgres, Auth, API otomatis).

## Fitur

- 🔐 **Login & daftar** (email/password) — tiap keluarga punya akunnya sendiri.
- ➕ **Catat transaksi** pemasukan & pengeluaran (jumlah, kategori, tanggal, catatan).
- 📊 **Ringkasan bulanan** — total pemasukan, pengeluaran, saldo, + grafik pie per kategori.
- 🎯 **Anggaran (budget)** per kategori dengan progress terpakai vs sisa.
- 📤 **Ekspor CSV** untuk backup/laporan (dibagikan ke WhatsApp, email, Drive, dll).
- 🔒 Data aman: **Row Level Security** — setiap user hanya bisa melihat datanya sendiri.

---

## Cara Setup

### 1. Buat project Supabase (gratis)

1. Daftar di <https://supabase.com> → **New Project** (pilih region terdekat, mis. Singapore).
2. Buka **SQL Editor** → tempel seluruh isi [`supabase/schema.sql`](supabase/schema.sql) → **Run**.
   Ini membuat tabel, keamanan (RLS), dan otomatis mengisi kategori default saat user mendaftar.
3. Buka **Project Settings → API**, salin **Project URL** dan **anon public key**.

### 2. Siapkan kunci di aplikasi

```bash
cp .env.example .env
```

Edit `.env` dan isi:

```
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

> `anon key` aman disimpan di aplikasi klien karena data tetap dilindungi RLS.
> File `.env` sudah masuk `.gitignore` sehingga tidak ikut ter-commit.

### 3. Generate folder platform Android

Repo ini berisi kode Dart (`lib/`), konfigurasi, dan skema database — folder platform
(`android/`) dibuat sekali dengan perintah Flutter berikut (tidak menimpa `lib/`):

```bash
flutter create --platforms=android .
flutter pub get
```

### 4. Jalankan

```bash
flutter run          # ke emulator / HP Android yang terhubung
```

### 5. Build APK (untuk dipasang di HP)

```bash
flutter build apk --release
# hasilnya: build/app/outputs/flutter-apk/app-release.apk
```

Salin file APK ke HP dan pasang (aktifkan "Install from unknown sources").

---

## Cara Pakai

1. **Daftar** akun (nama, email, password) → **Masuk**.
2. Tab **Transaksi**: tekan tombol **+ Transaksi** untuk mencatat pemasukan/pengeluaran.
   Tap sebuah transaksi untuk mengedit, tekan lama untuk menghapus.
3. Tab **Ringkasan**: lihat total & grafik; ganti bulan dengan panah ‹ ›.
4. Tab **Anggaran**: tetapkan batas pengeluaran per kategori, pantau progресnya.
5. Ekspor: ikon **share** di tab Transaksi → file CSV bulan terpilih.

---

## Struktur Kode

```
lib/
  core/         koneksi Supabase, tema, format Rupiah/tanggal
  models/       Category, TxRecord, Budget
  services/     akses data (auth, transaksi, kategori, budget, ekspor)
  providers/    state management (Riverpod)
  features/     layar: auth, dashboard, transactions, budgets
  widgets/      komponen reusable (kartu ringkasan, pemilih bulan)
supabase/
  schema.sql    skema database + RLS + kategori default
```

## Teknologi

| Lapisan | Teknologi |
|---------|-----------|
| Mobile | Flutter (Dart) |
| Backend | Supabase (Postgres + Auth) |
| State | Riverpod |
| Grafik | fl_chart |
| Ekspor | csv + share_plus |

Semua komponen gratis. Supabase free tier cukup untuk penggunaan rumah tangga.
