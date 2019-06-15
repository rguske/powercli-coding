$wui = (Get-Host).UI.RawUI
# $setwui = $wui.WindowSize
# $setwui.Width = 170
# $setwui.Height = 58
# $wui.BufferSize = $setwui
# $wui.WindowSize = $setwui
# $wui.CursorSize = "100"
# $wui.BackgroundColor = "Black"
$wui.ForegroundColor = "Green"

Set-ExecutionPolicy Unrestricted

Clear-Host

do {

[int]$userMenuChoice = 0

while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 3) {

    Write-Host ""
    Write-Host ""
    Write-Host  "      ____ _   _    _      _____  _    __  __  "
                "     / ___| \ | |  / \    |_   _|/ \  |  \/  | "
                "    | |   |  \| | / _ \     | | / _ \ | |\/| | "
                "    | |___| |\  |/ ___ \    | |/ ___ \| |  | | "
                "     \____|_| \_/_/   \_\   |_/_/   \_\_|  |_| "

                Write-Host ""
                Write-Host "1. Quit"
                Write-Host ""
                Write-Host "2. Connenct to vCenter Server"
                Write-Host ""
                Write-Host "3. Read vSphere Tag Global:URN"
                Write-Host ""

	[int]$userMenuChoice = Read-Host "Please choose an option"

	switch ($userMenuChoice) {

        2   ### Connect to vCenter Server
            {
                $vcenter = Read-Host "Enter vCenter (IP)"

                Write-host "Set PowerCLI config to ignore certificates? (Default is No)" -ForegroundColor Yellow
                $Readhost = Read-Host " ( y / n ) "
                   Switch ($ReadHost)
                    {
                    y   {
                        Set-PowerCLIConfiguration -InvalidCertificateAction ignore
                        }
                    n   {
                        Write-Host "No, Skip config"
                        }
                    Default
                        {
                        Write-Host "Default, Skip config"
                        }
                    }

                Connect-VIServer -server $vcenter
            }
        
        3   ### Read vSphere Tag Global:URN
            {
                $tagname = Read-Host Enter the name of the vSphere-Tag
                Get-Tag | Where -Property Name -eq $tagname | Format-List
		    }
	}
  }
} while ( $userMenuChoice -ne 1 )