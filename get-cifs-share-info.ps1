$netapp = "NetAppのIP"
$user = "admin"
$pass = "パスワード"

$outfile1 = "C:\TEMP\Cifs-Share.csv"
$outfile2 = "C:\TEMP\Cifs-Share-ACL.csv"
$outfile3 = "C:\TEMP\Cifs-Share-Cmd.txt"
$outfile4 = "C:\TEMP\Cifs-Share-Cmd-Default-Acl-Delete.txt"
$outfile5 = "C:\TEMP\Cifs-Share-Cmd-Acl.txt"

#-------------------------------------------------------------------------
# function Efficiency-Status
#-------------------------------------------------------------------------
function Cifs-Info()
{
   
   $logdata1 = "Cifs-Share"
   Get-NcCifsShare | select @{Name="ShareName"    ; Exp={$_.sharename}}, 
               @{Name="Path" ; Exp={$_.path}}| Export-Csv -path $outfile1 -Encoding UTF8 -NoTypeInformation
#   write-output ""`n >> $outfile1
}

function Cifs-ACL-Info()
{
   
   $logdata2 = "Cifs-Share-ACL"
   Get-NcCifsShareAcl | select @{Name="ShareName"    ; Exp={$_.share}},
               @{Name="UserOrGroup"    ; Exp={$_.userorgroup}},
               @{Name="Permission" ; Exp={$_.permission}}| Export-Csv -path $outfile2 -Encoding UTF8 -NoTypeInformation
#   write-output ""`n >> $outfile2
}

function Create-Cmd-Cifs-Share()
{
   
   $logdata3 = "Cifs-Share-Cmd"
   $logdata3 | out-file $outfile3
   Get-Date -Format g >> $outfile3
   $Cifs_Share_Record = Import-Csv $outfile1 -Encoding UTF8
   $Cifs_Share_Record2 = $Cifs_Share_Record | Where-Object {$_.sharename -notmatch "^c\$`$"} | Where-Object {$_.sharename -notmatch "^ETC\$`$"} | Where-Object {$_.sharename -notmatch "^home\$`$"}
   $Cifs_Share_Record2 | foreach { "vserver cifs share create -vserver aefs23-svm1 -share-name " + $_.sharename + " -path " + $_.path } >> $outfile3

}

function Create-Cmd-Cifs-Default-Acl-Delete()
{
   
   $logdata4 = "Cifs-Default-Acl-Delete-Cmd"
   $logdata4 | out-file $outfile4
   Get-Date -Format g >> $outfile4
   $Cifs_Share_Record = Import-Csv $outfile1 -Encoding UTF8
   $Cifs_Share_Record2 = $Cifs_Share_Record | Where-Object {$_.sharename -notmatch "^c\$`$"} | Where-Object {$_.sharename -notmatch "^ETC\$`$"} | Where-Object {$_.sharename -notmatch "^home\$`$"}
   $Cifs_Share_Record2 | foreach { "vserver cifs share access-control delete -vserver aefs23-svm1 -share " + $_.sharename + " -user-or-group Everyone" } >> $outfile4

}

function Create-Cmd-Cifs-Acl()
{
   
   $logdata5 = "Cifs-Acl-Cmd"
   $logdata5 | out-file $outfile5
   Get-Date -Format g >> $outfile5
   $Cifs_Share_Acl_Record = Import-Csv $outfile2 -Encoding UTF8
   $Cifs_Share_Acl_Record | foreach { "vserver cifs share access-control create -vserver aefs23-svm1 -share " + $_.sharename + " -user-group-type windows -user-or-group " + "`"" + $_.userorgroup + "`"" + " -permission " + $_.permission } >> $outfile5

}

function Send-Mail()
{

$From="Fromメールアドレス"
$Subject="DR切り替え時の投入コマンド"
$body="hostnameのDR切り替え時の投入コマンドを送信致します。"
#　このファイルの場所を取得
$FilePath=Split-Path ( & { $myInvocation.ScriptName } ) -parent
$File1=@($outfile3)
$File2=@($outfile4)
$File3=@($outfile5)
$To="Toメールアドレス"

# 送信メールサーバーの設定
$SMTPServer="SMTPサーバIP"
$Port="25"
$User="ユーザ名"
$Password="パスワード"
$SMTPClient=New-Object Net.Mail.SmtpClient($SMTPServer,$Port)
# SSL暗号化通信しない $false
$SMTPClient.EnableSsl=$false
$SMTPClient.Credentials=New-Object Net.NetworkCredential($User,$Password)

# メールメッセージの作成
$MailMassage=New-Object Net.Mail.MailMessage($From,$To,$Subject,$body)
# ファイルから添付ファイルを作成
$Attachment1=New-Object Net.Mail.Attachment($File1)
$Attachment2=New-Object Net.Mail.Attachment($File2)
$Attachment3=New-Object Net.Mail.Attachment($File3)
# メールメッセージに添付
$MailMassage.Attachments.Add($Attachment1)
$MailMassage.Attachments.Add($Attachment2)
$MailMassage.Attachments.Add($Attachment3)
# メールメッセージを送信
$SMTPClient.Send($MailMassage)

}

#-------------------------------------------------------------------------
# Do-Initialize
#-------------------------------------------------------------------------
$password = ConvertTo-SecureString $pass -asplaintext -force
$cred = New-Object System.Management.Automation.PsCredential $user,$password

Import-Module DataOnTap
Connect-NcController $netapp -cred $cred 

#-------------------------------------------------------------------------
# Main Application Logic
#-------------------------------------------------------------------------
Cifs-Info
Cifs-ACL-Info
Create-Cmd-Cifs-Share
Create-Cmd-Cifs-Default-Acl-Delete
Create-Cmd-Cifs-Acl
Send-Mail