# AGENTS.md — SIP-Warga + FigCraft

## Konteks

- `lib/` — aplikasi SIP-Warga berbasis **Flutter** (Material 3, font Inter lokal, animasi). Layar: `dashboard_screen.dart`, `detail_screen.dart`; tema `app_theme.dart`; data `models.dart`; animasi `widgets.dart`.
- `assets/fonts/` — Inter 400/500/600/700 yang dibundel.
- `desain.figcraft` — file desain FigCraft, **sumber kebenaran UI**. Ini arsip zip; jangan diedit manual.
- `opencode.json` — MCP server `figcraft` yang attach ke aplikasi FigCraft di `127.0.0.1:8765`.
- `tools/figcraft.mjs` — klien MCP cadangan bila tool MCP tidak tersedia.
- `buka-figcraft.ps1` — menjalankan FigCraft dengan control server + izin folder project.

## Dua mode kerja

### 1. Mode desain — "buatkan / ubah UI ..."

Ubah **kanvas FigCraft**, bukan kode Flutter di `lib/`.

1. Baca kondisi terkini dengan `figcraft.inspect_document` (`outline: true`, `depth` secukupnya) dan `figcraft.screenshot` untuk melihat hasil.
2. Ubah lewat tool MCP `figcraft`:
   - `batch` untuk beberapa langkah sebagai satu undo step (paling aman),
   - `create_node`, `set_properties`, `type_text`, `select`,
   - `run_command` / `list_commands` untuk perintah FigCraft lain.
3. Cek hasil dengan `screenshot` (render frame) sebelum menyimpan.
4. Simpan dengan `figcraft.save_file` ke `desain.figcraft`.

Aturan desain:

- Layar utama: frame **`Dashboard Warga • Mobile`** (`id: 3`) dan **`Detail Warga • Mobile`** (`id: 52`), ukuran **390×844**, halaman `Page 1`.
- Koordinat `x/y` relatif ke parent; `y` ke bawah. Di dalam frame auto-layout, posisi diatur layout.
- Palet tema **BCA blue**: primary `#0060AF`, dark `#004E92`, text `#0A2A4A`, canvas `#F4F8FD`, line `#DCE8F5`, muted `#6E86A6`, light `#E3F0FF`, page `#E8F0FA`.
- Font: Inter. Sudut kartu 16–20 px. Layar memakai bottom navigation 4 item.
- Motion prototype: kartu warga → Detail (slide up 320 ms, ease-out); tombol kembali/tutup → slide down 280 ms, ease-in.
- Motion untuk implementasi Flutter: entrance fade + rise 12 px dengan stagger; count-up angka statistik; kartu terangkat saat hover (`translateY(-2px)`) dan mengecil saat ditekan (`scale(.99)`); status dot berdenyut halus; transisi halaman slide 320 ms. Hormati pengaturan *reduce motion* (`MediaQuery.disableAnimations`).
- Jangan menghapus layer yang tidak diminta. Jangan mengubah frame utama jadi ukuran lain tanpa permintaan.
- Setelah perubahan, `dirty` harus kembali `false` (sudah disimpan).

### 2. Mode terapkan — "terapkan / implementasikan / samakan kode"

Sinkronkan `lib/` dengan desain FigCraft. **Jangan mengubah `desain.figcraft`** pada mode ini.

1. Ambil desain final: `screenshot` (frame `3` dan `52`) + `inspect_document` dengan `depth` 3–5, atau `get_node` per bagian.
2. Petakan properti desain ke kode: warna hex, ukuran font, line-height, padding/gap, corner radius, border, shadow, teks, urutan section, ikon.
3. Edit file di `lib/` sambil mempertahankan fungsi yang ada (pencarian, filter, edit data, animasi).
4. Verifikasi: `flutter analyze`, `flutter test`, lalu render web (`flutter build web` / `flutter run -d chrome`) dan bandingkan dengan screenshot desain. Jika ada perbedaan, perbaiki sampai cocok.

## Menjalankan aplikasi Flutter

Flutter SDK: `C:\Users\Pc One\flutter` (sudah ditambahkan ke PATH user).

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web --release      # preview: build/web/index.html
flutter run -d chrome            # preview langsung
flutter build apk --release      # perlu Android SDK
```

## Menjalankan FigCraft

Cara termudah: klik dua kali `mulai.bat` (menyalakan FigCraft lalu OpenCode).

Jika hanya ingin menyalakan FigCraft, atau menjalankannya dari terminal:

```powershell
powershell -ExecutionPolicy Bypass -File .\buka-figcraft.ps1
```

FigCraft harus terbuka dengan control server dan izin ke folder ini.

Jika FigCraft sudah terbuka tetapi MCP gagal, tutup aplikasinya dulu lalu jalankan script tersebut.

Urutan yang disarankan: jalankan FigCraft lebih dulu, baru buka OpenCode. Jika FigCraft baru dinyalakan setelah OpenCode, jalankan `/reload` atau sambungkan ulang lewat `/mcps`.

## Cadangan tanpa MCP

```powershell
node tools/figcraft.mjs status
node tools/figcraft.mjs call inspect_document --params '{\"depth\":2,\"outline\":true}'
node tools/figcraft.mjs shot preview.png --params '{\"ids\":[3]}'
node tools/figcraft.mjs call batch --params @langkah.json
```

Gunakan `document` id `6` atau path file bila ada beberapa tab.
