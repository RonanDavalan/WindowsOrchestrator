# Windows オーケストレーター

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

Windows オーケストレーターは、Windows のタスクスケジューラを利用して PowerShell スクリプト (`.ps1`) を実行するための一連のスクリプトです。グラフィカルアシスタント (`firstconfig.ps1`) を使用して、ユーザーは設定ファイル `config.ini` を生成できます。主要なスクリプト (`config_systeme.ps1`, `config_utilisateur.ps1`) はこのファイルを読み込み、特定の操作を実行します：
*   Windows レジストリキーの変更。
*   システムコマンドの実行 (`powercfg`, `shutdown`)。
*   Windows サービスの管理 (`wuauserv` サービスのスタートアップの種類変更と停止)。
*   ユーザーが定義したアプリケーションプロセスの開始または停止。
*   `Invoke-RestMethod` コマンドを介して、Gotify 通知サービスへの HTTP POST リクエストの送信。

スクリプトはユーザーのオペレーティングシステムの言語を検出し、`i18n` ディレクトリにある `.psd1` ファイルから文字列（ログ、GUI、通知用）を読み込みます。

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 完全な紹介は公式ホームページをご覧ください！</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/ライセンス-GPLv3-blue.svg" alt="ライセンス">
  <img src="https://img.shields.io/badge/PowerShell_バージョン-5.1%2B-blue" alt="PowerShell バージョン">
  <img src="https://img.shields.io/badge/ステータス-稼働中-brightgreen.svg" alt="ステータス">
  <img src="https://img.shields.io/badge/OS-Windows_10_|_11-informational" alt="OS">
  <img src="https://img.shields.io/badge/サポート-11_言語-orange.svg" alt="サポート">
  <img src="https://img.shields.io/badge/貢献-歓迎-brightgreen.svg" alt="貢献">
</p>

---

## スクリプトの動作

`1_install.bat` スクリプトは `management\install.ps1` を実行し、2つの主要なタスクスケジューラを作成します。
*   1つ目の **`WindowsOrchestrator-SystemStartup`** は、Windows の起動時に `config_systeme.ps1` を実行します。
*   2つ目の **`WindowsOrchestrator-UserLogon`** は、ユーザーのログオン時に `config_utilisateur.ps1` を実行します。

`config.ini` ファイルの設定に応じて、スクリプトは以下の操作を実行します：

*   **自動ログオンの管理：**
    *   `スクリプトの動作：` スクリプトはレジストリキー `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon` に値 `1` を書き込みます。
    *   `ユーザーの操作：` この機能を有効にするには、ユーザーは事前にパスワードをレジストリに保存する必要があります。スクリプトはこの情報を管理しません。**Sysinternals AutoLogon** ユーティリティは、この操作を実行できる外部ツールです。

*   **電源設定の変更：**
    *   `powercfg /change standby-timeout-ac 0` と `powercfg /change hibernate-timeout-ac 0` コマンドを実行してスリープを無効にします。
    *   `powercfg /change monitor-timeout-ac 0` コマンドを実行して画面のスリープを無効にします。
    *   レジストリキー `HiberbootEnabled` に値 `0` を書き込み、高速スタートアップを無効にします。

*   **Windows Update の管理：**
    *   レジストリキー `NoAutoUpdate` と `NoAutoRebootWithLoggedOnUsers` に値 `1` を書き込みます。
    *   Windows サービス `wuauserv` のスタートアップの種類を `Disabled` に変更し、`Stop-Service` コマンドを実行します。

*   **毎日の再起動のスケジュール：**
    *   `shutdown.exe /r /f /t 60` を定義された時刻に実行する `WindowsOrchestrator-SystemScheduledReboot` という名前のタスクスケジューラを作成します。
    *   再起動前にユーザー定義のコマンドを実行する `WindowsOrchestrator-SystemPreRebootAction` という名前のタスクスケジューラを作成します。

*   **アクションのログ記録：**
    *   `Logs` フォルダ内の `.txt` ファイルにタイムスタンプ付きの行を書き込みます。
    *   `Rotate-LogFile` 関数は、既存のログファイルをリネームしてアーカイブします。保持するファイル数は `config.ini` の `MaxSystemLogsToKeep` と `MaxUserLogsToKeep` キーで定義されます。

*   **Gotify 通知の送信：**
    *   `config.ini` の `EnableGotify` キーが `true` の場合、スクリプトは指定された URL に HTTP POST リクエストを送信します。
    *   リクエストには、タイトルとメッセージを含む JSON ペイロードが含まれます。メッセージは実行されたアクションと発生したエラーのリストです。

## 前提条件

- **オペレーティングシステム**：Windows 10 または Windows 11。ソースコードには PowerShell スクリプト用の `#Requires -Version 5.1` ディレクティブが含まれています。
- **権限**：`1_install.bat` と `2_uninstall.bat` の実行時に、ユーザーは権限昇格の要求（UAC）を承認する必要があります。この操作は、スクリプトがタスクスケジューラを作成し、システムレベルのレジストリキーを変更するために必要です。
- **自動ログオン（Auto-Login）**：ユーザーがこのオプションを有効にする場合、**Microsoft Sysinternals AutoLogon** のような外部ツールを使用してパスワードをレジストリに保存する必要があります。

## インストールと初期設定

ユーザーは **`1_install.bat`** ファイルを実行します。

1.  **設定 (`firstconfig.ps1`)**
    *   `management\firstconfig.ps1` スクリプトが実行され、グラフィカルインターフェースが表示されます。
    *   `config.ini` ファイルが存在しない場合、テンプレート `management\defaults\default_config.ini` から作成されます。
    *   存在する場合、スクリプトはユーザーにテンプレートで上書きするかどうかを尋ねます。
    *   ユーザーがパラメータを入力します。「保存して閉じる」をクリックすると、スクリプトは値を `config.ini` に書き込みます。

2.  **タスクのインストール (`install.ps1`)**
    *   アシスタントを閉じた後、`1_install.bat` は権限昇格を要求して `management\install.ps1` を実行します。
    *   `install.ps1` スクリプトは2つのタスクスケジューラを作成します：
        *   **`WindowsOrchestrator-SystemStartup`**：Windows の起動時に `NT AUTHORITY\SYSTEM` アカウントで `config_systeme.ps1` を実行します。
        *   **`WindowsOrchestrator-UserLogon`**：インストールを開始したユーザーのログオン時に `config_utilisateur.ps1` を実行します。
    *   再起動を待たずに設定を適用するため、`install.ps1` はプロセスの最後に `config_systeme.ps1` と `config_utilisateur.ps1` を一度だけ実行します。

## インストール後の使用と設定

インストール後の設定変更はすべて `config.ini` ファイルを介して行われます。

### 1. `config.ini` ファイルの手動変更

*   **ユーザーの操作：** ユーザーはテキストエディタで `config.ini` ファイルを開き、希望の値を変更します。
*   **スクリプトの動作：**
    *   `[SystemConfig]` セクションの変更は、**次回のコンピュータ再起動時**に `config_systeme.ps1` によって読み込まれ、適用されます。
    *   `[Process]` セクションの変更は、**次回のユーザーログオン時**に `config_utilisateur.ps1` によって読み込まれ、適用されます。

### 2. グラフィカルアシスタントの使用

*   **ユーザーの操作：** ユーザーは再度 `1_install.bat` を実行します。`config.ini` の現在の値が事前に入力されたグラフィカルインターフェースが開きます。ユーザーは設定を変更し、「保存して閉じる」をクリックします。
*   **スクリプトの動作：** `firstconfig.ps1` スクリプトは新しい値を `config.ini` に書き込みます。
*   **使用状況：** アシスタントを閉じた後、コマンドプロンプトはタスクのインストールを続けるかどうかを尋ねます。ユーザーはこのウィンドウを閉じて、設定のみを更新することができます。

## アンインストール

ユーザーは **`2_uninstall.bat`** ファイルを実行します。これは権限昇格の要求（UAC）の後、`management\uninstall.ps1` を実行します。

`uninstall.ps1` スクリプトは以下の操作を実行します：

1.  **自動ログオン：** スクリプトは自動ログオンを無効にするかどうかを尋ねるプロンプトを表示します。ユーザーが `o` (はい) と応答した場合、スクリプトはレジストリキー `AutoAdminLogon` に値 `0` を書き込みます。
2.  **一部のシステム設定の復元：**
    *   **アップデート：** レジストリ値 `NoAutoUpdate` を `0` に設定し、`wuauserv` サービスのスタートアップの種類を `Automatic` に設定します。
    *   **高速スタートアップ：** レジストリ値 `HiberbootEnabled` を `1` に設定します。
    *   **OneDrive：** レジストリ値 `DisableFileSyncNGSC` を削除します。
3.  **タスクスケジューラの削除：** スクリプトは `WindowsOrchestrator-SystemStartup`、`WindowsOrchestrator-UserLogon`、`WindowsOrchestrator-SystemScheduledReboot`、および `WindowsOrchestrator-SystemPreRebootAction` タスクを検索して削除します。

### 設定の復元に関する注意

**アンインストールスクリプトは、`powercfg` コマンドで変更された電源設定を復元しません。**
*   **ユーザーへの影響：** スクリプトによってマシンまたは画面のスリープが無効にされた場合、アンインストール後もその状態が維持されます。
*   **ユーザーが必要な操作：** スリープを再度有効にするには、ユーザーは Windows の「電源とスリープの設定」でこれらのオプションを手動で再設定する必要があります。

アンインストールプロセスは**どのファイルも削除しません**。プロジェクトディレクトリとその内容はディスク上に残ります。

## プロジェクトの構造

```
WindowsOrchestrator/
├── 1_install.bat                # グラフィカル設定を実行し、タスクをインストールします。
├── 2_uninstall.bat              # アンインストールスクリプトを実行します。
├── Close-App.bat                # PowerShell スクリプト Close-AppByTitle.ps1 を実行します。
├── Close-AppByTitle.ps1         # ウィンドウをタイトルで見つけ、キーストロークシーケンスを送信するスクリプト。
├── config.ini                   # 主要スクリプトが読み込む設定ファイル。
├── config_systeme.ps1           # マシン設定用スクリプト、起動時に実行。
├── config_utilisateur.ps1       # プロセス管理用スクリプト、ログオン時に実行。
├── Fix-Encoding.ps1             # スクリプトファイルを UTF-8 with BOM エンコーディングに変換するツール。
├── LaunchApp.bat                # 外部アプリケーションを起動するためのサンプルバッチスクリプト。
├── List-VisibleWindows.ps1      # 表示されているウィンドウとそのプロセスを一覧表示するユーティリティ。
├── i18n/
│   ├── en-US/
│   │   └── strings.psd1         # 英語用の文字列ファイル。
│   └── ... (他の言語)
└── management/
    ├── firstconfig.ps1          # グラフィカル設定アシスタントを表示します。
    ├── install.ps1              # タスクスケジューラを作成し、スクリプトを一度実行します。
    ├── uninstall.ps1            # タスクを削除し、システム設定を復元します。
    └── defaults/
        └── default_config.ini   # 初期の config.ini ファイルを作成するためのテンプレート。
```

## 技術的な原則

*   **ネイティブコマンド**：プロジェクトは Windows と PowerShell のネイティブコマンドのみを使用します。外部の依存関係をインストールする必要はありません。
*   **システムライブラリ**：システムとの高度な対話は、Windows に組み込まれたライブラリ（例：`user32.dll`）のみに依存しています。

## 主要ファイルの説明

### `1_install.bat`
このバッチファイルはインストールプロセスのエントリポイントです。設定のために `management\firstconfig.ps1` を実行し、その後、昇格された権限で `management\install.ps1` を実行します。

### `2_uninstall.bat`
このバッチファイルはアンインストールプロセスのエントリポイントです。昇格された権限で `management\uninstall.ps1` を実行します。

### `config.ini`
これは中央の設定ファイルです。`config_systeme.ps1` と `config_utilisateur.ps1` スクリプトがどのアクションを実行するかを決定するために読み込む指示（キーと値）が含まれています。

### `config_systeme.ps1`
タスクスケジューラによってコンピュータの起動時に実行されるこのスクリプトは、`config.ini` ファイルの `[SystemConfig]` セクションを読み込みます。Windows レジストリの変更、システムコマンド（`powercfg`）の実行、サービス（`wuauserv`）の管理によって設定を適用します。

### `config_utilisateur.ps1`
タスクスケジューラによってユーザーのログオン時に実行されるこのスクリプトは、`config.ini` ファイルの `[Process]` セクションを読み込みます。その役割は、ターゲットプロセスの既存のインスタンスをすべて停止し、提供されたパラメータを使用して再起動することです。

### `management\firstconfig.ps1`
この PowerShell スクリプトは、`config.ini` ファイルのパラメータを読み書きするためのグラフィカルインターフェースを表示します。

### `management\install.ps1`
このスクリプトには、`WindowsOrchestrator-SystemStartup` と `WindowsOrchestrator-UserLogon` タスクスケジューラを作成するロジックが含まれています。

### `management\uninstall.ps1`
このスクリプトには、タスクスケジューラを削除し、システムのレジストリキーをデフォルト値に復元するロジックが含まれています。

## タスクスケジューラによる管理

自動化は Windows のタスクスケジューラ (`taskschd.msc`) に依存しています。以下のタスクがスクリプトによって作成されます：

*   **`WindowsOrchestrator-SystemStartup`**：PC の起動時にトリガーされ、`config_systeme.ps1` を実行します。
*   **`WindowsOrchestrator-UserLogon`**：ログオン時にトリガーされ、`config_utilisateur.ps1` を実行します。
*   **`WindowsOrchestrator-SystemScheduledReboot`**：`config.ini` で `ScheduledRebootTime` が定義されている場合に `config_systeme.ps1` によって作成されます。
*   **`WindowsOrchestrator-SystemPreRebootAction`**：`config.ini` で `PreRebootActionCommand` が定義されている場合に `config_systeme.ps1` によって作成されます。

**重要**：タスクスケジューラを介してこれらのタスクを手動で削除すると、自動化は停止しますが、システム設定は復元されません。完全かつ制御されたアンインストールのために、ユーザーは必ず `2_uninstall.bat` を使用する必要があります。

## ライセンスとコントリビューション

このプロジェクトは **GPLv3** ライセンスの下で配布されています。全文は `LICENSE` ファイルで確認できます。

バグレポート、改善提案、プルリクエストなどのコントリビューションを歓迎します。
