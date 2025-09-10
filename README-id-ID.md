# Orkestrator Windows

<p align="center">
  <img src="https://img.shields.io/badge/Lisensi-GPLv3-blue.svg" alt="Lisensi">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="Versi PowerShell">
  <img src="https://img.shields.io/badge/Dukungan-11_Bahasa-orange.svg" alt="Dukungan Multibahasa">
  <img src="https://img.shields.io/badge/OS-Windows_10_|_11-informational" alt="OS yang Didukung">
</p>

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | **🇮🇩 Bahasa Indonesia**

---

Proyek ini mengotomatiskan stasiun kerja Windows sehingga aplikasi dapat berjalan di atasnya tanpa pengawasan.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Kunjungi beranda resmi untuk presentasi lengkap!</strong></a>
</p>

Setelah restart yang tidak terduga (karena pemadaman listrik atau insiden), proyek ini bertugas membuka sesi Windows dan meluncurkan kembali aplikasi Anda secara otomatis, sehingga memastikan kelangsungan layanannya. Ini juga memungkinkan penjadwalan restart harian untuk menjaga stabilitas sistem.

Semua tindakan didorong oleh satu file konfigurasi, yang dibuat saat instalasi.

### **Instalasi**

1.  **Prasyarat (untuk login otomatis):** Jika Anda ingin sesi Windows terbuka dengan sendirinya, gunakan terlebih dahulu alat **[Sysinternals AutoLogon](https://learn.microsoft.com/id-id/sysinternals/downloads/autologon)** untuk menyimpan kata sandi. Ini adalah satu-satunya konfigurasi eksternal yang diperlukan.
2.  **Peluncuran:** Jalankan **`1_install.bat`**. Wizard grafis akan memandu Anda untuk membuat file konfigurasi Anda. Instalasi kemudian akan dilanjutkan dan meminta izin administrator (UAC).

### **Penggunaan**

Setelah diinstal, proyek ini bersifat otonom. Untuk mengubah konfigurasi (mengubah aplikasi yang akan diluncurkan, waktu restart, dll.), cukup edit file `config.ini` yang terletak di direktori proyek.

### **Penghapusan Instalasi**

Jalankan **`2_uninstall.bat`**. Skrip akan menghapus semua otomatisasi dan mengembalikan pengaturan utama Windows ke nilai defaultnya.

*   **Catatan Penting:** Satu-satunya pengaturan yang tidak dipulihkan adalah yang terkait dengan manajemen daya (`powercfg`).
*   Direktori proyek dengan semua filenya tetap ada di disk Anda dan dapat dihapus secara manual.

### **Dokumentasi Teknis**

Untuk deskripsi rinci tentang arsitektur, setiap skrip, dan semua opsi konfigurasi, silakan lihat dokumentasi referensi.

➡️ **[Lihat Dokumentasi Teknis Rinci](./docs/id-ID/PANDUAN_PENGEMBANG.md)**

---
**Lisensi**: Proyek ini didistribusikan di bawah lisensi GPLv3. Lihat file `LICENSE`.
