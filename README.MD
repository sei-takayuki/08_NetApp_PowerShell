NetAppよりCIFS共有設定情報を取得して、DR側で投入するCIFS設定コマンドを作成する
PowerShellスクリプトです。

動作環境
PowerShellを実行するサーバにNetApp PowerShell Tool Kitをインストールしておく必要があります。

手順

1.NetApp PowerShell Toolkitのダウンロード
下記URLよりNetApp_PowerShell_Toolkit_9.7.1.0.msiをダウンロードします。

NetApp PowerShell Toolkit
https://mysupport.netapp.com/site/tools/tool-eula/powershell-toolkit

※2020/06/28時点での最新Verは9.7.1です。

2.NetApp PowerShell Toolkitのインストール
NetApp_PowerShell_Toolkit_9.7.1.0.msiをダブルクリックすると、
インストーラーが起動するので、インストールして下さい。


3.NetAppへの接続
コマンドプロンプトにて、

powershell

Import-Module DataOnTap

Connect-NcController [NetAppのIP] -cred admin

でパスワードを要求されるので、
入力すると、NetAppに接続できます。

コマンドヘルプの表示
Get-NcHelp

ボリューム情報の表示
Get-NcVol

CIFS共有情報の表示
Get-NcCifsShare

CIFS共有アクセス権の表示
Get-NcCifsShareAcl

4.スクリプトの実行
get-cifs-share-info.ps1

