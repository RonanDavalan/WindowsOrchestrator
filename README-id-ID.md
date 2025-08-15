# WindowsAutoConfig ⚙️

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md)

**Autopilot Anda untuk stasiun kerja Windows khusus. Konfigurasikan sekali, dan biarkan sistem mengelola dirinya sendiri dengan andal.**

![License](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Status](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Support](https://img.shields.io/badge/Support-11_Langues-orange.svg)![Contributions](https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg)

---

## 🎯 Misi Kami

Bayangkan sebuah stasiun kerja Windows yang andal dan otonom. Sebuah mesin yang Anda konfigurasikan sekali untuk misinya—apakah itu mengendalikan perangkat yang terhubung, menyalakan layar digital, atau berfungsi sebagai stasiun pemantauan—dan kemudian dapat dilupakan. Sebuah sistem yang memastikan aplikasi Anda tetap **beroperasi secara permanen**, tanpa gangguan.

Inilah tujuan yang dibantu oleh **WindowsAutoConfig** untuk Anda capai. Tantangannya adalah PC Windows standar tidak dirancang secara asli untuk jenis daya tahan ini. Ini dibuat untuk interaksi manusia: ia tidur untuk menghemat daya, menginstal pembaruan saat dianggap sesuai, dan tidak secara otomatis memulai ulang aplikasi setelah reboot.

**WindowsAutoConfig** adalah solusinya: seperangkat skrip yang bertindak sebagai pengawas cerdas dan permanen. Ini mengubah PC apa pun menjadi otomat yang andal, memastikan bahwa aplikasi penting Anda selalu beroperasi, tanpa intervensi manual.

### Di Luar Antarmuka: Kontrol Sistem Langsung

WindowsAutoConfig bertindak sebagai panel kontrol canggih, membuat konfigurasi yang kuat dapat diakses yang tidak tersedia atau sulit dikelola melalui UI Windows standar.

*   **Kontrol Penuh atas Pembaruan Windows:** Alih-alih hanya "menjeda" pembaruan, skrip memodifikasi kebijakan sistem untuk menghentikan mekanisme otomatis, memberi Anda kembali kendali atas kapan pembaruan diinstal.
*   **Pengaturan Daya yang Andal:** Skrip tidak hanya mengatur tidur ke "Tidak Pernah"; ini memastikan pengaturan ini diterapkan kembali pada setiap boot, membuat konfigurasi Anda tahan terhadap perubahan yang tidak diinginkan.
*   **Akses ke Pengaturan Tingkat Administrator:** Fitur seperti menonaktifkan OneDrive melalui kebijakan sistem adalah tindakan yang biasanya terkubur di Editor Kebijakan Grup (tidak tersedia di Windows Home). Skrip ini membuatnya dapat diakses oleh semua orang.

## ✨ Fitur Utama
*   **Wizard Konfigurasi Grafis:** Tidak perlu mengedit file untuk pengaturan dasar.
*   **Dukungan Multibahasa Penuh:** Antarmuka dan log tersedia dalam 11 bahasa, dengan deteksi otomatis bahasa sistem.
*   **Manajemen Daya:** Nonaktifkan tidur mesin, tidur layar, dan Windows Fast Startup untuk stabilitas maksimum.
*   **Login Otomatis (Auto-Login):** Mengelola login otomatis, termasuk dalam sinergi dengan alat **Sysinternals AutoLogon** untuk manajemen kata sandi yang aman.
*   **Kontrol Pembaruan Windows:** Mencegah pembaruan dan reboot paksa mengganggu aplikasi Anda.
*   **Manajer Proses:** Secara otomatis meluncurkan, memantau, dan meluncurkan kembali aplikasi utama Anda dengan setiap sesi.
*   **Reboot Harian Terjadwal:** Jadwalkan reboot harian untuk menjaga kesegaran sistem.
*   **Tindakan Pra-Reboot:** Jalankan skrip khusus (cadangan, pembersihan...) sebelum reboot terjadwal.
*   **Pencatatan Rinci:** Semua tindakan dicatat dalam file log untuk diagnosis yang mudah.
*   **Notifikasi (Opsional):** Kirim laporan status melalui Gotify.

---

## 🎯 Audiens Target dan Praktik Terbaik

Proyek ini dirancang untuk mengubah PC menjadi otomat yang andal, ideal untuk kasus penggunaan di mana mesin didedikasikan untuk satu aplikasi (server untuk perangkat IoT, papan nama digital, stasiun pemantauan, dll.). Ini tidak direkomendasikan untuk komputer kantor serba guna atau komputer sehari-hari.

*   **Pembaruan Windows Utama:** Untuk pembaruan signifikan (misalnya, memutakhirkan dari Windows 10 ke 11), prosedur teraman adalah **mencopot pemasangan** WindowsAutoConfig sebelum pembaruan, lalu **menginstalnya kembali** sesudahnya.
*   **Lingkungan Perusahaan:** Jika komputer Anda berada di domain perusahaan yang dikelola oleh Objek Kebijakan Grup (GPO), hubungi departemen TI Anda untuk memastikan modifikasi yang dibuat oleh skrip ini tidak bertentangan dengan kebijakan organisasi Anda.

---

## 🚀 Instalasi dan Memulai

**Catatan Bahasa:** Skrip peluncuran (`1_install.bat` dan `2_uninstall.bat`) menampilkan instruksinya dalam **bahasa Inggris**. Ini normal. File-file ini bertindak sebagai peluncur sederhana. Segera setelah wizard grafis atau skrip PowerShell mengambil alih, antarmuka akan secara otomatis beradaptasi dengan bahasa sistem operasi Anda.

Menyiapkan **WindowsAutoConfig** adalah proses yang sederhana dan terpandu.

1.  **Unduh** atau klon proyek ke komputer yang akan dikonfigurasi.
2.  Jalankan `1_install.bat`. Skrip akan memandu Anda melalui dua langkah:
    *   **Langkah 1: Konfigurasi melalui Wizard Grafis.**
        Sesuaikan opsi sesuai dengan kebutuhan Anda. Yang paling penting biasanya adalah nama pengguna untuk login otomatis dan aplikasi yang akan diluncurkan. Klik `Simpan` untuk menyimpan.
    *   **Langkah 2: Instalasi Tugas Sistem.**
        Skrip akan meminta konfirmasi untuk melanjutkan. Jendela keamanan Windows (UAC) akan terbuka. **Anda harus menerimanya** untuk mengizinkan skrip membuat tugas terjadwal yang diperlukan.
3.  Selesai! Pada reboot berikutnya, konfigurasi Anda akan diterapkan.

---

## 🔧 Konfigurasi
Anda dapat menyesuaikan pengaturan kapan saja dengan dua cara:

### 1. Wizard Grafis (Metode sederhana)
Jalankan kembali `1_install.bat` untuk membuka kembali antarmuka konfigurasi. Ubah pengaturan Anda dan simpan.

### 2. File `config.ini` (Metode lanjutan)
Buka `config.ini` dengan editor teks untuk kontrol granular.

#### Catatan Penting tentang Auto-Login dan Kata Sandi
Untuk alasan keamanan, **WindowsAutoConfig tidak pernah mengelola atau menyimpan kata sandi dalam teks biasa.** Berikut cara mengonfigurasi login otomatis secara efektif dan aman:

*   **Skenario 1: Akun pengguna tidak memiliki kata sandi.**
    Cukup masukkan nama pengguna di wizard grafis atau di `AutoLoginUsername` di file `config.ini`.

*   **Skenario 2: Akun pengguna memiliki kata sandi (Metode yang disarankan).**
    1.  Unduh alat **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** resmi dari Microsoft (tautan unduhan langsung).
    2.  Luncurkan AutoLogon dan masukkan nama pengguna, domain, dan kata sandi. Alat ini akan menyimpan kata sandi dengan aman di Registry.
    3.  Dalam konfigurasi **WindowsAutoConfig**, Anda sekarang dapat membiarkan bidang `AutoLoginUsername` kosong (skrip akan mendeteksi pengguna yang dikonfigurasi oleh AutoLogon dengan membaca kunci Registry yang sesuai) atau mengisinya untuk memastikannya. Skrip kami akan memastikan bahwa kunci Registry `AutoAdminLogon` diaktifkan dengan benar untuk menyelesaikan konfigurasi.

#### Konfigurasi Lanjutan: `PreRebootActionCommand`
Fitur canggih ini memungkinkan Anda menjalankan skrip sebelum reboot harian. Jalurnya bisa:
- **Absolut:** `C:\Scripts\my_backup.bat`
- **Relatif terhadap proyek:** `PreReboot.bat` (skrip akan mencari file ini di root proyek).
- **Menggunakan `%USERPROFILE%`:** `%USERPROFILE%\Desktop\cleanup.ps1` (skrip akan dengan cerdas mengganti `%USERPROFILE%` dengan jalur ke profil pengguna login otomatis).

---

## 📂 Struktur Proyek
```
WindowsAutoConfig/
├── 1_install.bat                # Titik masuk untuk instalasi dan konfigurasi
├── 2_uninstall.bat              # Titik masuk untuk pencopotan pemasangan
├── config.ini                   # File konfigurasi pusat
├── config_systeme.ps1           # Skrip utama untuk pengaturan mesin (berjalan saat startup)
├── config_utilisateur.ps1       # Skrip utama untuk manajemen proses pengguna (berjalan saat login)
├── LaunchApp.bat                # (Contoh) Peluncur portabel untuk aplikasi utama Anda
├── PreReboot.bat                # Contoh skrip untuk tindakan pra-reboot
├── Logs/                        # (Dibuat secara otomatis) Berisi file log
├── i18n/                        # Berisi semua file terjemahan
│   ├── en-US/strings.psd1
│   └── ... (bahasa lain)
└── management/
    ├── defaults/default_config.ini # Templat konfigurasi awal
    ├── tools/                   # Alat diagnostik
    │   └── Find-WindowInfo.ps1
    ├── firstconfig.ps1          # Kode wizard konfigurasi grafis
    ├── install.ps1              # Skrip teknis untuk instalasi tugas
    └── uninstall.ps1            # Skrip teknis untuk penghapusan tugas
```

---

## ⚙️ Operasi Rinci
Inti dari **WindowsAutoConfig** bergantung pada Penjadwal Tugas Windows:

1.  **Saat Windows Startup**
    *   Tugas `WindowsAutoConfig_SystemStartup` berjalan dengan hak istimewa `SYSTEM`.
    *   Skrip `config_systeme.ps1` membaca `config.ini` dan menerapkan semua konfigurasi mesin. Ini juga mengelola pembuatan/pembaruan tugas reboot.

2.  **Saat Login Pengguna**
    *   Tugas `WindowsAutoConfig_UserLogon` berjalan.
    *   Skrip `config_utilisateur.ps1` membaca bagian `[Process]` dari `config.ini` dan memastikan bahwa aplikasi utama Anda diluncurkan dengan benar. Jika sudah berjalan, itu pertama-tama dihentikan kemudian diluncurkan kembali dengan bersih.

3.  **Harian (Jika dikonfigurasi)**
    *   Tugas `WindowsAutoConfig_PreRebootAction` menjalankan skrip cadangan/pembersihan Anda.
    *   Beberapa menit kemudian, tugas `WindowsAutoConfig_ScheduledReboot` me-reboot komputer.

---

### 🛠️ Alat Diagnostik dan Pengembangan

Proyek ini mencakup skrip yang berguna untuk membantu Anda mengonfigurasi dan memelihara proyek.

*   **`management/tools/Find-WindowInfo.ps1`**: Jika Anda tidak mengetahui judul pasti dari jendela aplikasi (misalnya, untuk mengonfigurasinya di `Close-AppByTitle.ps1`), jalankan skrip ini. Ini akan mencantumkan semua jendela yang terlihat dan nama prosesnya, membantu Anda menemukan informasi yang tepat.
*   **`Fix-Encoding.ps1`**: Jika Anda memodifikasi skrip, alat ini memastikan skrip disimpan dengan pengkodean yang benar (UTF-8 with BOM) untuk kompatibilitas sempurna dengan PowerShell 5.1 dan karakter internasional.

---

## 📄 Pencatatan
Untuk pemecahan masalah yang mudah, semuanya dicatat.
*   **Lokasi:** Di subfolder `Logs/`.
*   **File:** `config_systeme_ps_log.txt` dan `config_utilisateur_log.txt`.
*   **Rotasi:** Log lama secara otomatis diarsipkan untuk mencegahnya menjadi terlalu besar.

---

## 🗑️ Pencopotan Pemasangan
Untuk menghapus sistem:
1.  Jalankan `2_uninstall.bat`.
2.  **Terima permintaan hak istimewa (UAC)**.
3.  Skrip akan dengan bersih menghapus semua tugas terjadwal dan mengembalikan pengaturan sistem utama.

**Catatan tentang Reversibilitas:** Pencopotan pemasangan tidak hanya menghapus tugas terjadwal. Ini juga mengembalikan pengaturan sistem utama ke keadaan default untuk memberi Anda sistem yang bersih:
*   Pembaruan Windows diaktifkan kembali.
*   Fast Startup diaktifkan kembali.
*   Kebijakan yang memblokir OneDrive dihapus.
*   Skrip akan menawarkan untuk menonaktifkan login otomatis.

Sistem Anda dengan demikian kembali menjadi stasiun kerja standar, tanpa modifikasi sisa.

---

## ❤️ Lisensi dan Kontribusi
Proyek ini didistribusikan di bawah lisensi **GPLv3**. Teks lengkap tersedia di file `LICENSE`.

Kontribusi, baik dalam bentuk laporan bug, saran perbaikan, atau permintaan tarik, diterima.
