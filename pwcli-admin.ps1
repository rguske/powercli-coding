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
    Write-Host  "    __     ____  ____        __  _____  _    __  __    "
                "    \ \   / /  \/  \ \      / / |_   _|/ \  |  \/  |   "
                "     \ \ / /| |\/| |\ \ /\ / /    | | / _ \ | |\/| |   "
                "      \ V / | |  | | \ V  V /     | |/ ___ \| |  | |   "
                "       \_/  |_|  |_|  \_/\_/      |_/_/   \_\_|  |_|   "

                Write-Host ""
                Write-Host "1. Quit"
                Write-Host ""
                Write-Host "2. Connect to vCenter Server"
                Write-Host ""
                Write-Host "3. Ignore Invalid Certification warning"
                Write-Host ""
                Write-Host "4. "
                Write-Host ""

	[int]$userMenuChoice = Read-Host "Please choose an option"

	switch ($userMenuChoice) {
        2	### Connect to vCenter Server
            {
                $vCenters = "lab-vcsa67-001.lab.jarvis.local"
                # Prompting for credentials
                $vCenterCredentials = Get-Credential -Message "Enter vCenter login credentials"
                $vCenterUser = $vCenterCredentials.UserName
                $vCenterPassword = $vCenterCredentials.GetNetworkCredential().Password
                # $viserver = read-host "vCenter Server"
                # Connect-viServer -server $viserver
            }

        3	### Ignore Invalid Certification warning
            {
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
        }

        3	### Read vSphere Tag Category
            {

            }

		}
	}
} while ( $userMenuChoice -ne 1 )