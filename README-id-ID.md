# Windows Orchestrator

[🇫🇷 Prancis](README-fr-FR.md) | [🇩🇪 Jerman](README-de-DE.md) | [🇪🇸 Spanyol](README-es-ES.md) | [🇮🇳 Hindi](README-hi-IN.md) | [🇯🇵 Jepang](README-ja-JP.md) | [🇷🇺 Rusia](README-ru-RU.md) | [🇨🇳 Tiongkok](README-zh-CN.md) | [🇸🇦 Arab](README-ar-SA.md) | [🇧🇩 Bengali](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

**Autopilot Anda untuk workstation Windows khusus. Konfigurasi sekali, dan biarkan sistem mengelola dirinya sendiri dengan andal.**

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Kunjungi Halaman Utama Resmi untuk tur lengkap!</strong></a>
</p>

![Lisensi](https://img.shields.io/badge/Lisensi-GPLv3-blue.svg)![Versi PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Status](https://img.shields.io/badge/Status-Operasional-brightgreen.svg)![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Dukungan](https://img.shields.io/badge/Support-11_Bahasa-orange.svg)![Kontribusi](https://img.shields.io/badge/Contributions-Selamat_Datang-brightgreen.svg)

---

## Misi Kami

Bayangkan workstation Windows yang sangat andal dan otonom. Mesin yang Anda konfigurasi sekali untuk misinya dan kemudian dapat melupakannya. Sistem yang memastikan aplikasi Anda tetap **beroperasi secara permanen**, tanpa gangguan.

Inilah tujuan yang **Windows Orchestrator** bantu Anda capai. Tantangannya adalah PC Windows standar tidak dirancang secara native untuk ketahanan ini. Ini dirancang untuk interaksi manusia: ia masuk ke mode tidur, menginstal pembaruan ketika dianggap sesuai, dan tidak secara otomatis memulai ulang aplikasi setelah reboot.

**Windows Orchestrator** adalah solusinya: seperangkat skrip yang bertindak sebagai pengawas cerdas dan permanen. Ini mengubah PC apa pun menjadi automaton yang andal, memastikan aplikasi kritis Anda selalu beroperasi, tanpa intervensi manual.



Kami dihadapkan bukan pada satu, tetapi pada dua jenis kegagalan sistemik:

#### 1. Kegagalan Mendadak: Pemadaman Tak Terduga

Skenarionya sederhana: mesin yang dikonfigurasi untuk akses jarak jauh dan pemadaman listrik di malam hari. Bahkan dengan BIOS yang diatur untuk restart otomatis, misi gagal. Windows restart tetapi tetap di layar login; aplikasi kritis tidak diluncurkan ulang, sesi tidak dibuka. Sistem tidak dapat diakses.

#### 2. Degradasi Lambat: Ketidakstabilan Jangka Panjang

Yang lebih berbahaya adalah perilaku Windows seiring waktu. Dirancang sebagai OS interaktif, ia tidak dioptimalkan untuk proses yang berjalan tanpa gangguan. Secara bertahap, kebocoran memori dan degradasi kinerja muncul, membuat sistem tidak stabil dan memerlukan restart manual.

### Jawabannya: Lapisan Keandalan Native

Menghadapi tantangan ini, utilitas pihak ketiga terbukti tidak memadai. Oleh karena itu, kami memutuskan untuk **membangun lapisan ketahanan sistem kami sendiri.**

`Windows Orchestrator` bertindak sebagai autopilot yang mengambil kendali OS untuk:

- **Memastikan Pemulihan Otomatis:** Setelah kegagalan, ia menjamin pembukaan sesi dan restart aplikasi utama Anda.
- **Menjamin Pemeliharaan Preventif:** Ini memungkinkan Anda untuk menjadwalkan restart harian yang terkontrol dengan eksekusi skrip kustom sebelumnya.
- **Melindungi Aplikasi** dari gangguan yang tidak tepat waktu dari Windows (pembaruan, mode tidur...).

`Windows Orchestrator` adalah alat penting bagi siapa pun yang membutuhkan workstation Windows untuk tetap **andal, stabil, dan beroperasi tanpa pemantauan terus-menerus.**

---

## Kasus Penggunaan Umum

*   **Digital Signage:** Pastikan perangkat lunak signage berjalan 24/7 di layar publik.
*   **Server Rumah dan IoT:** Kontrol server Plex, gateway Home Assistant, atau objek yang terhubung dari PC Windows.
*   **Stasiun Pengawasan:** Jaga agar aplikasi pemantauan (kamera, log jaringan) selalu aktif.
*   **Kios Interaktif:** Pastikan aplikasi kios restart secara otomatis setelah setiap reboot.
*   **Otomatisasi Ringan:** Jalankan skrip atau proses terus-menerus untuk tugas penambangan data atau pengujian.

---

## Fitur Utama

*   **Wizard Konfigurasi Grafis:** Tidak perlu mengedit file untuk pengaturan dasar.
*   **Dukungan Multibahasa Penuh:** Antarmuka dan log tersedia dalam 11 bahasa, dengan deteksi otomatis bahasa sistem.
*   **Manajemen Daya:** Nonaktifkan mode tidur mesin, mode tidur tampilan, dan Mulai Cepat Windows untuk stabilitas maksimum.
*   **Login Otomatis (Auto-Login):** Mengelola login otomatis, termasuk bersinergi dengan alat **Sysinternals AutoLogon** untuk manajemen kata sandi yang aman.
*   **Kontrol Pembaruan Windows:** Mencegah pembaruan paksa dan reboot mengganggu aplikasi Anda.
*   **Manajer Proses:** Secara otomatis meluncurkan, memantau, dan meluncurkan ulang aplikasi utama Anda dengan setiap sesi.
*   **Reboot Harian Terjadwal:** Jadwalkan reboot harian untuk menjaga kesegaran sistem.
*   **Tindakan Pra-Reboot:** Jalankan skrip kustom (cadangan, pembersihan...) sebelum reboot terjadwal.
*   **Pencatatan Rinci:** Semua tindakan dicatat dalam file log untuk diagnosis yang mudah.
*   **Pemberitahuan (Opsional):** Kirim laporan status melalui Gotify.

---

## Target Audiens dan Praktik Terbaik

Proyek ini dirancang untuk mengubah PC menjadi automaton yang andal, ideal untuk kasus penggunaan di mana mesin didedikasikan untuk satu aplikasi (server untuk perangkat IoT, digital signage, stasiun pemantauan, dll.). Ini tidak direkomendasikan untuk komputer kantor tujuan umum atau sehari-hari.

*   **Pembaruan Windows Utama:** Untuk pembaruan signifikan (misalnya, peningkatan dari Windows 10 ke 11), prosedur teraman adalah **mencopot pemasangan** Windows Orchestrator sebelum pembaruan, lalu **memasang kembali** setelahnya.
*   **Lingkungan Perusahaan:** Jika komputer Anda berada di domain perusahaan yang dikelola oleh Objek Kebijakan Grup (GPO), periksa dengan departemen IT Anda untuk memastikan modifikasi yang dilakukan oleh skrip ini tidak bertentangan dengan kebijakan organisasi Anda.

---

## Instalasi dan Memulai

**Catatan Bahasa:** Skrip peluncuran (`1_install.bat` dan `2_uninstall.bat`) menampilkan instruksinya dalam **Bahasa Inggris**. Ini normal. File-file ini bertindak sebagai peluncur sederhana. Segera setelah wizard grafis atau skrip PowerShell mengambil alih, antarmuka akan secara otomatis beradaptasi dengan bahasa sistem operasi Anda.

Menyiapkan **Windows Orchestrator** adalah proses yang sederhana dan terpandu.

1.  **Unduh** atau klon proyek ke komputer yang akan dikonfigurasi.
2.  Jalankan `1_install.bat`. Skrip akan memandu Anda melalui dua langkah:
    *   **Langkah 1: Konfigurasi melalui Wizard Grafis.**
        Sesuaikan opsi sesuai kebutuhan Anda. Yang paling penting biasanya adalah nama pengguna untuk login otomatis dan aplikasi yang akan diluncurkan. Klik `Simpan` untuk menyimpan.
        
        ![Wizard Konfigurasi](assets/screenshot-wizard.png)
        
    *   **Langkah 2: Instalasi Tugas Sistem.**
        Skrip akan meminta konfirmasi untuk melanjutkan. Jendela keamanan Windows (UAC) akan terbuka. **Anda harus menerimanya** untuk memungkinkan skrip membuat tugas terjadwal yang diperlukan.
3.  Itu saja! Setelah reboot berikutnya, konfigurasi Anda akan diterapkan.

---

## Konfigurasi
Anda dapat menyesuaikan pengaturan kapan saja dengan dua cara:

### 1. Wizard Grafis (Metode sederhana)
Jalankan kembali `1_install.bat` untuk membuka kembali antarmuka konfigurasi. Ubah pengaturan Anda dan simpan.

### 2. File `config.ini` (Metode lanjutan)
Buka `config.ini` dengan editor teks untuk kontrol granular.

#### Catatan Penting tentang Login Otomatis dan Kata Sandi
Untuk alasan keamanan, **Windows Orchestrator tidak pernah mengelola atau menyimpan kata sandi dalam teks biasa.** Berikut cara mengonfigurasi login otomatis secara efektif dan aman:

*   **Skenario 1: Akun pengguna tidak memiliki kata sandi.**
    Cukup masukkan nama pengguna di wizard grafis atau di `AutoLoginUsername` di file `config.ini`.

*   **Skenario 2: Akun pengguna memiliki kata sandi (Metode yang direkomendasikan).**
    1.  Unduh alat resmi **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** dari Microsoft (tautan unduhan langsung).
    2.  Luncurkan AutoLogon dan masukkan nama pengguna, domain, dan kata sandi. Alat ini akan menyimpan kata sandi dengan aman di Registri.
    3.  Dalam konfigurasi **Windows Orchestrator**, Anda sekarang dapat membiarkan bidang `AutoLoginUsername` kosong (skrip akan mendeteksi pengguna yang dikonfigurasi oleh AutoLogon dengan membaca kunci Registri yang sesuai) atau mengisinya untuk memastikan. Skrip kami akan memastikan bahwa kunci Registri `AutoAdminLogon` diaktifkan dengan benar untuk menyelesaikan konfigurasi.

#### Konfigurasi Lanjutan: `PreRebootActionCommand`
Fitur canggih ini memungkinkan Anda untuk menjalankan skrip sebelum reboot harian. Jalurnya bisa:
- **Absolut:** `C:\Scripts\my_backup.bat`
- **Relatif terhadap proyek:** `PreReboot.bat` (skrip akan mencari file ini di root proyek).
- **Menggunakan `%USERPROFILE%`:** `%USERPROFILE%\Desktop\cleanup.ps1` (skrip akan secara cerdas mengganti `%USERPROFILE%` dengan jalur ke profil pengguna login otomatis).

---

## Struktur Proyek
```
WindowsOrchestrator/
├── 1_install.bat                # Titik masuk untuk instalasi dan konfigurasi
├── 2_uninstall.bat              # Titik masuk untuk uninstalasi
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
    ├── defaults/default_config.ini # Template konfigurasi awal
    ├── tools/                   # Alat diagnostik
    │   └── Find-WindowInfo.ps1
    ├── firstconfig.ps1          # Kode wizard konfigurasi grafis
    ├── install.ps1              # Skrip teknis untuk instalasi tugas
    └── uninstall.ps1            # Skrip teknis untuk penghapusan tugas
```

---

## Operasi Rinci
Inti dari **Windows Orchestrator** bergantung pada Penjadwal Tugas Windows:

1.  **Saat Startup Windows**
    *   Tugas `WindowsOrchestrator_SystemStartup` berjalan dengan hak istimewa `SYSTEM`.
    *   Skrip `config_systeme.ps1` membaca `config.ini` dan menerapkan semua konfigurasi mesin. Ini juga mengelola pembuatan/pembaruan tugas reboot.

2.  **Saat Login Pengguna**
    *   Tugas `WindowsOrchestrator_UserLogon` berjalan.
    *   Skrip `config_utilisateur.ps1` membaca bagian `[Process]` dari `config.ini` dan memastikan bahwa aplikasi utama Anda diluncurkan dengan benar. Jika sudah berjalan, itu pertama-tama dihentikan kemudian diluncurkan ulang dengan bersih.

3.  **Harian (Jika dikonfigurasi)**
    *   Tugas `WindowsOrchestrator_PreRebootAction` menjalankan skrip cadangan/pembersihan Anda.
    *   Beberapa menit kemudian, tugas `WindowsOrchestrator_ScheduledReboot` me-reboot komputer.

---

### Alat Diagnostik dan Pengembangan

Proyek ini mencakup skrip yang berguna untuk membantu Anda mengonfigurasi dan memelihara proyek.

*   **`management/tools/Find-WindowInfo.ps1`**: Jika Anda tidak tahu judul pasti jendela aplikasi (misalnya, untuk mengonfigurasinya di `Close-AppByTitle.ps1`), jalankan skrip ini. Ini akan mencantumkan semua jendela yang terlihat dan nama prosesnya, membantu Anda menemukan informasi yang tepat.
*   **`Fix-Encoding.ps1`**: Jika Anda memodifikasi skrip, alat ini memastikan bahwa mereka disimpan dengan pengkodean yang benar (UTF-8 dengan BOM) untuk kompatibilitas sempurna dengan PowerShell 5.1 dan karakter internasional.

---

## Pencatatan
Untuk pemecahan masalah yang mudah, semuanya dicatat.
*   **Lokasi:** Di subfolder `Logs/`.
*   **File:** `config_systeme_ps_log.txt` dan `config_utilisateur_log.txt`.
*   **Rotasi:** Log lama secara otomatis diarsipkan untuk mencegahnya menjadi terlalu besar.

---

## Pencopotan Pemasangan
Untuk menghapus sistem:
1.  Jalankan `2_uninstall.bat`.
2.  **Terima permintaan hak istimewa (UAC)**.
3.  Skrip akan menghapus semua tugas terjadwal dengan bersih dan mengembalikan pengaturan sistem utama.

**Catatan tentang Reversibilitas:** Pencopotan pemasangan tidak hanya menghapus tugas terjadwal. Ini juga mengembalikan pengaturan sistem utama ke keadaan default untuk memberi Anda sistem yang bersih:
*   Pembaruan Windows diaktifkan kembali.
*   Mulai Cepat diaktifkan kembali.
*   Kebijakan yang memblokir OneDrive dihapus.
*   Skrip akan menawarkan untuk menonaktifkan login otomatis.

Sistem Anda dengan demikian kembali menjadi workstation standar, tanpa modifikasi sisa.

---

## Lisensi dan Kontribusi
Proyek ini didistribusikan di bawah lisensi **GPLv3**. Teks lengkap tersedia di file `LICENSE`.

Kontribusi, baik dalam bentuk laporan bug, saran perbaikan, atau permintaan tarik, disambut baik.