# Windows オーケストレーター

<p align="center">
  <img src="https://img.shields.io/badge/ライセンス-GPLv3-blue.svg" alt="ライセンス">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="PowerShell バージョン">
  <img src="https://img.shields.io/badge/サポート-11言語-orange.svg" alt="多言語サポート">
  <img src="https://img.shields.io/badge/OS-Windows_10_|_11-informational" alt="対応OS">
</p>

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | **🇯🇵 日本語** | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

---

このプロジェクトは、アプリケーションが監視なしで実行できるように、Windowsワークステーションを自動化します。

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 完全な概要については、公式ホームページをご覧ください！</strong></a>
</p>

予期せぬ再起動（停電やインシデントによる）の後、このプロジェクトはWindowsセッションを開き、アプリケーションを自動的に再起動して、サービスの継続性を確保します。また、システムの安定性を維持するために、毎日の再起動をスケジュールすることもできます。

すべてのアクションは、インストール時に作成される単一の構成ファイルによって制御されます。

### **インストール**

1.  **前提条件（自動ログオン用）：** Windowsセッションを自動で開きたい場合は、まず **[Sysinternals AutoLogon](https://learn.microsoft.com/ja-jp/sysinternals/downloads/autologon)** ツールを使用してパスワードを保存してください。これが唯一必要な外部設定です。
2.  **起動：** **`1_install.bat`** を実行します。グラフィカルウィザードが構成ファイルの作成を案内します。その後、インストールが続行され、管理者権限（UAC）が要求されます。

### **使用方法**

一度インストールされると、プロジェクトは自律的に動作します。構成を変更する（起動するアプリケーション、再起動時間などを変更する）には、プロジェクトディレクトリにある `config.ini` ファイルを編集するだけです。

### **アンインストール**

**`2_uninstall.bat`** を実行します。スクリプトはすべての自動化を削除し、主要なWindows設定をデフォルト値に復元します。

*   **重要事項：** 復元されない唯一の設定は、電源管理に関連する設定（`powercfg`）です。
*   すべてのファイルを含むプロジェクトディレクトリはディスクに残り、手動で削除できます。

### **技術ドキュメント**

アーキテクチャ、各スクリプト、およびすべての構成オプションの詳細な説明については、リファレンスドキュメントを参照してください。

➡️ **[詳細な技術ドキュメントを参照](./docs/ja-JP/KAIHATSUSHA_GUIDE.md)**

---
**ライセンス**：このプロジェクトはGPLv3ライセンスの下で配布されています。`LICENSE`ファイルを参照してください。
