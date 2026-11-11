# SIP-Warga — Aplikasi Data Warga (Flutter)

Aplikasi mobile pendataan warga RT/RW dengan tema **BCA blue**, dibangun dengan Flutter untuk Android, iOS, dan web (preview).

Desain sumber kebenaran ada di `desain.figcraft` (FigCraft): frame **Dashboard Warga • Mobile** (`id: 3`) dan **Detail Warga • Mobile** (`id: 52`), 390×844.

## Fitur

- **Dashboard**: total warga, kepala keluarga, warga tetap; pencarian nama/NIK/alamat; filter Semua / Tetap / Kontrak; daftar warga dengan status dot berdenyut.
- **Detail warga**: kartu profil gradient, data kependudukan 2 kolom, alamat, tombol **Edit Data** dan **Tutup**.
- **Edit data**: bottom sheet untuk mengubah nama, pekerjaan, usia, dan alamat (tersimpan di memori sesi).
- **Animasi**: entrance fade + rise berurutan, count-up angka statistik, kartu terangkat saat hover dan mengecil saat ditekan, status dot berdenyut, transisi detail slide up 320 ms / turun 280 ms. Semua menghormati pengaturan *reduce motion*.

## Menjalankan

Flutter SDK terpasang di `C:\Users\Pc One\flutter`. Buka terminal di folder ini:

```powershell
flutter pub get
flutter run -d chrome     # preview cepat di browser
flutter run               # HP/emulator yang terhubung
```

Build:

```powershell
flutter build apk --release
flutter build web --release
```

> Untuk build/run di Android perlu Android SDK + emulator/HP dengan USB debugging. Cek dengan `flutter doctor`.

## Struktur

```
lib/
  main.dart              # MaterialApp + tema
  app_theme.dart         # palet BCA blue, shadow, ThemeData
  models.dart            # model Resident + 128 data contoh
  widgets.dart           # Entrance, CountUpText, PulseDot, PressableScale
  dashboard_screen.dart  # layar dashboard
  detail_screen.dart     # layar detail + bottom sheet edit
assets/fonts/            # Inter 400/500/600/700 (lokal)
test/widget_test.dart    # test dashboard, pencarian, navigasi detail
```

## Integrasi OpenCode + FigCraft (MCP)

Proyek ini terhubung ke FigCraft lewat MCP, sehingga desain bisa diubah langsung dari chat OpenCode.

1. **Cara termudah:** klik dua kali `mulai.bat`. Launcher menyalakan FigCraft (control server `127.0.0.1:8765`, izin hanya folder proyek, membuka `desain.figcraft`), menunggu siap, lalu membuka OpenCode.
2. Jika hanya ingin menyalakan FigCraft:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\buka-figcraft.ps1
   ```
3. Alur prompt:
   - **Mode desain**: `Ubah tampilan detail ...` → asisten mengubah kanvas, cek screenshot, lalu menyimpan `desain.figcraft`.
   - **Mode terapkan**: `Terapkan desain FigCraft ke aplikasi` → asisten menyesuaikan `lib/` (warna, ukuran, jarak, teks, animasi) dengan kanvas.

Aturan kerja lengkap ada di `AGENTS.md`. Klien cadangan bila MCP tidak tersedia:

```powershell
node tools/figcraft.mjs status
node tools/figcraft.mjs shot preview.png --params '{\"ids\":[3]}'
```
