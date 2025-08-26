# Orkestrator Windows

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md)

Orkestrator Windows adalah sekumpulan skrip yang menggunakan Tugas Terjadwal Windows untuk menjalankan skrip PowerShell (`.ps1`). Sebuah asisten grafis (`firstconfig.ps1`) memungkinkan pengguna untuk membuat file konfigurasi `config.ini`. Skrip utama (`config_systeme.ps1`, `config_utilisateur.ps1`) membaca file ini untuk melakukan tindakan spesifik:
*   Modifikasi kunci Registri Windows.
*   Eksekusi perintah sistem (`powercfg`, `shutdown`).
*   Manajemen layanan Windows (mengubah tipe startup dan menghentikan layanan `wuauserv`).
*   Memulai atau menghentikan proses aplikasi yang ditentukan oleh pengguna.
*   Mengirim permintaan HTTP POST ke layanan notifikasi Gotify melalui perintah `Invoke-RestMethod`.

Skrip mendeteksi bahasa sistem operasi pengguna dan memuat string (untuk log, antarmuka grafis, dan notifikasi) dari file `.psd1` yang terletak di direktori `i18n`.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Kunjungi halaman beranda resmi untuk presentasi lengkap!</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Lisensi-GPLv3-blue.svg" alt="Lisensi">
  <img src="https://img.shields.io/badge/Versi_PowerShell-5.1%2B-blue" alt="Versi PowerShell">
  <img src="https://img.shields.io/badge/Status-Beroperasi-brightgreen.svg" alt="Status">
  <img src="https://img.shields.io/badge/Sistem_Operasi-Windows_10_|_11-informational" alt="Sistem Operasi">
  <img src="https://img.shields.io/badge/Dukungan-11_Bahasa-orange.svg" alt="Dukungan">
  <img src="https://img.shields.io/badge/Kontribusi-Selamat_Datang-brightgreen.svg" alt="Kontribusi">
</p>

---

## Aksi Skrip

Skrip `1_install.bat` menjalankan `management\install.ps1`, yang membuat dua Tugas Terjadwal utama.
*   Yang pertama, **`WindowsOrchestrator-SystemStartup`**, menjalankan `config_systeme.ps1` saat Windows dimulai.
*   Yang kedua, **`WindowsOrchestrator-UserLogon`**, menjalankan `config_utilisateur.ps1` saat pengguna masuk (login).

Berdasarkan parameter dalam file `config.ini`, skrip menjalankan tindakan berikut:

*   **Manajemen login otomatis:**
    *   `Aksi skrip:` Skrip menulis nilai `1` ke kunci Registri `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon`.
    *   `Aksi pengguna:` Agar fungsi ini beroperasi, pengguna harus terlebih dahulu menyimpan kata sandi di Registri. Skrip tidak mengelola informasi ini. Utilitas **Sysinternals AutoLogon** adalah alat eksternal yang dapat melakukan tindakan ini.

*   **Modifikasi pengaturan daya:**
    *   Menjalankan perintah `powercfg /change standby-timeout-ac 0` dan `powercfg /change hibernate-timeout-ac 0` untuk menonaktifkan mode tidur (sleep).
    *   Menjalankan perintah `powercfg /change monitor-timeout-ac 0` untuk menonaktifkan mode tidur layar.
    *   Menulis nilai `0` ke kunci Registri `HiberbootEnabled` untuk menonaktifkan Fast Startup.

*   **Manajemen Pembaruan Windows:**
    *   Menulis nilai `1` ke kunci Registri `NoAutoUpdate` dan `NoAutoRebootWithLoggedOnUsers`.
    *   Mengubah tipe startup layanan Windows `wuauserv` menjadi `Disabled` dan menjalankan perintah `Stop-Service` padanya.

*   **Menjadwalkan restart harian:**
    *   Membuat Tugas Terjadwal bernama `WindowsOrchestrator-SystemScheduledReboot` yang menjalankan `shutdown.exe /r /f /t 60` pada waktu yang ditentukan.
    *   Membuat Tugas Terjadwal bernama `WindowsOrchestrator-SystemPreRebootAction` yang menjalankan perintah yang ditentukan pengguna sebelum restart.

*   **Pencatatan (Logging) Aksi:**
    *   Menulis baris berstempel waktu ke dalam file `.txt` yang terletak di folder `Logs`.
    *   Sebuah fungsi `Rotate-LogFile` mengganti nama dan mengarsipkan file log yang ada. Jumlah file yang akan disimpan ditentukan oleh kunci `MaxSystemLogsToKeep` dan `MaxUserLogsToKeep` di `config.ini`.

*   **Mengirim notifikasi Gotify:**
    *   Jika kunci `EnableGotify` diatur ke `true` di `config.ini`, skrip akan mengirim permintaan HTTP POST ke URL yang ditentukan.
    *   Permintaan tersebut berisi payload JSON dengan judul dan pesan. Pesan tersebut adalah daftar tindakan yang dilakukan dan kesalahan yang ditemui.

## Prasyarat

- **Sistem Operasi**: Windows 10 atau Windows 11. Kode sumber berisi direktif `#Requires -Version 5.1` untuk skrip PowerShell.
- **Hak Akses**: Pengguna harus menyetujui permintaan peningkatan hak akses (UAC) saat menjalankan `1_install.bat` dan `2_uninstall.bat`. Tindakan ini diperlukan untuk mengizinkan skrip membuat tugas terjadwal dan memodifikasi kunci Registri tingkat sistem.
- **Login Otomatis (Auto-Login)**: Jika pengguna mengaktifkan opsi ini, ia harus menggunakan alat eksternal seperti **Microsoft Sysinternals AutoLogon** untuk menyimpan kata sandinya di Registri.

## Instalasi dan Konfigurasi Awal

Pengguna menjalankan file **`1_install.bat`**.

1.  **Konfigurasi (`firstconfig.ps1`)**
    *   Skrip `management\firstconfig.ps1` berjalan dan menampilkan antarmuka grafis.
    *   Jika file `config.ini` tidak ada, file tersebut akan dibuat dari template `management\defaults\default_config.ini`.
    *   Jika ada, skrip akan bertanya kepada pengguna apakah ingin menggantinya dengan template.
    *   Pengguna memasukkan parameter. Dengan mengklik "Simpan dan Tutup", skrip akan menulis nilai-nilai tersebut ke `config.ini`.

2.  **Instalasi Tugas (`install.ps1`)**
    *   Setelah asisten ditutup, `1_install.bat` menjalankan `management\install.ps1` dengan meminta peningkatan hak akses.
    *   Skrip `install.ps1` membuat dua Tugas Terjadwal:
        *   **`WindowsOrchestrator-SystemStartup`**: Menjalankan `config_systeme.ps1` saat Windows dimulai dengan akun `NT AUTHORITY\SYSTEM`.
        *   **`WindowsOrchestrator-UserLogon`**: Menjalankan `config_utilisateur.ps1` saat pengguna yang meluncurkan instalasi masuk (login).
    *   Untuk menerapkan konfigurasi tanpa menunggu restart, `install.ps1` menjalankan `config_systeme.ps1` lalu `config_utilisateur.ps1` satu kali di akhir proses.

## Penggunaan dan Konfigurasi Pasca-Instalasi

Setiap modifikasi konfigurasi setelah instalasi dilakukan melalui file `config.ini`.

### 1. Modifikasi Manual File `config.ini`

*   **Aksi pengguna:** Pengguna membuka file `config.ini` dengan editor teks dan mengubah nilai yang diinginkan.
*   **Aksi skrip:**
    *   Modifikasi pada bagian `[SystemConfig]` akan dibaca dan diterapkan oleh `config_systeme.ps1` **pada saat komputer di-restart berikutnya**.
    *   Modifikasi pada bagian `[Process]` akan dibaca dan diterapkan oleh `config_utilisateur.ps1` **pada saat pengguna login berikutnya**.

### 2. Menggunakan Asisten Grafis

*   **Aksi pengguna:** Pengguna menjalankan kembali `1_install.bat`. Antarmuka grafis akan terbuka, terisi dengan nilai-nilai saat ini dari `config.ini`. Pengguna mengubah parameter dan mengklik "Simpan dan Tutup".
*   **Aksi skrip:** Skrip `firstconfig.ps1` menulis nilai-nilai baru ke `config.ini`.
*   **Konteks penggunaan:** Setelah asisten ditutup, command prompt akan menawarkan untuk melanjutkan ke instalasi tugas. Pengguna dapat menutup jendela ini untuk hanya memperbarui konfigurasi.

## Uninstalasi

Pengguna menjalankan file **`2_uninstall.bat`**. File ini menjalankan `management\uninstall.ps1` setelah permintaan peningkatan hak akses (UAC).

Skrip `uninstall.ps1` melakukan tindakan berikut:

1.  **Login Otomatis:** Skrip menampilkan prompt yang menanyakan apakah login otomatis harus dinonaktifkan. Jika pengguna menjawab `y` (yes/ya), skrip akan menulis nilai `0` ke kunci Registri `AutoAdminLogon`.
2.  **Pemulihan beberapa pengaturan sistem:**
    *   **Pembaruan:** Mengatur nilai Registri `NoAutoUpdate` menjadi `0` dan mengonfigurasi tipe startup layanan `wuauserv` menjadi `Automatic`.
    *   **Fast Startup:** Mengatur nilai Registri `HiberbootEnabled` menjadi `1`.
    *   **OneDrive:** Menghapus nilai Registri `DisableFileSyncNGSC`.
3.  **Penghapusan Tugas Terjadwal:** Skrip mencari dan menghapus tugas `WindowsOrchestrator-SystemStartup`, `WindowsOrchestrator-UserLogon`, `WindowsOrchestrator-SystemScheduledReboot`, dan `WindowsOrchestrator-SystemPreRebootAction`.

### Catatan tentang Pemulihan Pengaturan

**Skrip uninstalasi tidak memulihkan pengaturan daya** yang telah diubah oleh perintah `powercfg`.
*   **Konsekuensi bagi pengguna:** Jika mode tidur mesin atau layar telah dinonaktifkan oleh skrip, mode tersebut akan tetap nonaktif setelah uninstalasi.
*   **Tindakan yang diperlukan dari pengguna:** Untuk mengaktifkan kembali mode tidur, pengguna harus mengonfigurasi ulang opsi ini secara manual di "Pengaturan daya & tidur" Windows.

Proses uninstalasi **tidak menghapus file apa pun**. Direktori proyek dan isinya tetap ada di disk.

## Struktur Proyek

```
WindowsOrchestrator/
├── 1_install.bat                # Menjalankan konfigurasi grafis lalu instalasi tugas.
├── 2_uninstall.bat              # Menjalankan skrip uninstalasi.
├── Close-App.bat                # Menjalankan skrip PowerShell Close-AppByTitle.ps1.
├── Close-AppByTitle.ps1         # Skrip yang menemukan jendela berdasarkan judulnya dan mengirimkan urutan tombol.
├── config.ini                   # File konfigurasi yang dibaca oleh skrip utama.
├── config_systeme.ps1           # Skrip untuk pengaturan mesin, dieksekusi saat startup.
├── config_utilisateur.ps1       # Skrip untuk manajemen proses, dieksekusi saat login.
├── Fix-Encoding.ps1             # Alat untuk mengonversi file skrip ke encoding UTF-8 with BOM.
├── LaunchApp.bat                # Contoh skrip batch untuk meluncurkan aplikasi eksternal.
├── List-VisibleWindows.ps1      # Utilitas yang mendaftar jendela yang terlihat dan prosesnya.
├── i18n/
│   ├── en-US/
│   │   └── strings.psd1         # File string untuk bahasa Inggris.
│   └── ... (bahasa lain)
└── management/
    ├── firstconfig.ps1          # Menampilkan asisten konfigurasi grafis.
    ├── install.ps1              # Membuat tugas terjadwal dan menjalankan skrip satu kali.
    ├── uninstall.ps1            # Menghapus tugas dan memulihkan pengaturan sistem.
    └── defaults/
        └── default_config.ini   # Template untuk membuat file config.ini awal.
```

## Prinsip Teknis

*   **Perintah Bawaan (Native)**: Proyek ini secara eksklusif menggunakan perintah bawaan Windows dan PowerShell. Tidak ada dependensi eksternal yang perlu diinstal.
*   **Pustaka Sistem**: Interaksi tingkat lanjut dengan sistem hanya mengandalkan pustaka yang terintegrasi dengan Windows (misalnya: `user32.dll`).

## Deskripsi File Kunci

### `1_install.bat`
File batch ini adalah titik masuk untuk proses instalasi. Ini menjalankan `management\firstconfig.ps1` untuk konfigurasi, kemudian menjalankan `management\install.ps1` dengan hak akses yang lebih tinggi.

### `2_uninstall.bat`
File batch ini adalah titik masuk untuk uninstalasi. Ini menjalankan `management\uninstall.ps1` dengan hak akses yang lebih tinggi.

### `config.ini`
Ini adalah file konfigurasi pusat. Ini berisi instruksi (kunci dan nilai) yang dibaca oleh skrip `config_systeme.ps1` dan `config_utilisateur.ps1` untuk menentukan tindakan apa yang harus dilakukan.

### `config_systeme.ps1`
Dijalankan saat komputer dinyalakan oleh Tugas Terjadwal, skrip ini membaca bagian `[SystemConfig]` dari file `config.ini`. Ini menerapkan pengaturan dengan memodifikasi Registri Windows, menjalankan perintah sistem (`powercfg`), dan mengelola layanan (`wuauserv`).

### `config_utilisateur.ps1`
Dijalankan saat pengguna masuk oleh Tugas Terjadwal, skrip ini membaca bagian `[Process]` dari file `config.ini`. Perannya adalah untuk menghentikan setiap instance yang ada dari proses target, kemudian memulainya kembali menggunakan parameter yang disediakan.

### `management\firstconfig.ps1`
Skrip PowerShell ini menampilkan antarmuka grafis yang memungkinkan untuk membaca dan menulis parameter ke file `config.ini`.

### `management\install.ps1`
Skrip ini berisi logika untuk membuat Tugas Terjadwal `WindowsOrchestrator-SystemStartup` dan `WindowsOrchestrator-UserLogon`.

### `management\uninstall.ps1`
Skrip ini berisi logika untuk menghapus Tugas Terjadwal dan memulihkan kunci Registri sistem ke nilai defaultnya.

## Manajemen oleh Tugas Terjadwal

Otomatisasi ini bergantung pada Penjadwal Tugas Windows (`taskschd.msc`). Tugas-tugas berikut dibuat oleh skrip:

*   **`WindowsOrchestrator-SystemStartup`**: Memicu saat PC dinyalakan dan menjalankan `config_systeme.ps1`.
*   **`WindowsOrchestrator-UserLogon`**: Memicu saat pengguna masuk dan menjalankan `config_utilisateur.ps1`.
*   **`WindowsOrchestrator-SystemScheduledReboot`**: Dibuat oleh `config_systeme.ps1` jika `ScheduledRebootTime` didefinisikan di `config.ini`.
*   **`WindowsOrchestrator-SystemPreRebootAction`**: Dibuat oleh `config_systeme.ps1` jika `PreRebootActionCommand` didefinisikan di `config.ini`.

**Penting**: Menghapus tugas-tugas ini secara manual melalui penjadwal tugas akan menghentikan otomatisasi tetapi tidak akan memulihkan pengaturan sistem. Pengguna harus menggunakan `2_uninstall.bat` untuk uninstalasi yang lengkap dan terkontrol.

## Lisensi dan Kontribusi

Proyek ini didistribusikan di bawah lisensi **GPLv3**. Teks lengkap tersedia di file `LICENSE`.

Kontribusi, baik itu laporan bug, saran perbaikan, atau pull request, sangat diterima.