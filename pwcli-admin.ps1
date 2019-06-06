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
                Write-Host "2. Ignore Invalid Certification warning"
                Write-Host ""
                Write-Host "3. Connenct to vCenter Server"
                Write-Host ""
                Write-Host "4. Read vSphere Tag Category"
                Write-Host ""

	[int]$userMenuChoice = Read-Host "Please choose an option"

	switch ($userMenuChoice) {

        2	### Ignore Invalid Certification warning
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

        3   ### Connect to vCenter Server
            {
                $vCenters = "lab-vcsa67-001.lab.jarvis.local"
                # Prompting for credentials
                $vCenterCredentials = Get-Credential -Message "Enter vCenter login credentials"
                $vCenterUser = $vCenterCredentials.UserName
                $vCenterPassword = $vCenterCredentials.GetNetworkCredential().Password
                # $viserver = read-host "vCenter Server"
                # Connect-viServer -server $viserver
            }

        4	### Read vSphere Tag Category
            {
                ################################################
                # Configure the variables below for the vCenter
                ################################################
                $vCenters = Read-Host Enter IP address of your vCenter Server
                # Prompting for credentials
                $vCenterCredentials = Get-Credential -Message "Enter vCenter login credentials"
                $vCenterUser = $vCenterCredentials.UserName
                $vCenterPassword = $vCenterCredentials.GetNetworkCredential().Password
                #######################################################################
                # Nothing to configure below this line - Starting the main function 
                #######################################################################
                # Building AssignedTagArray object
                ################################################
                $AssignedTagArray = @()
                ################################################
                # For Each vCenter authenticating and building list of assigned tags
                ################################################
                ForEach ($vCenter in $vCenters)
                {
                ################################################
                # Building vCenter API string & invoking REST API
                ################################################
                $vCenterBaseAuthURL = "https://" + $vCenter + "/rest/com/vmware/cis/"
                $vCenterBaseURL = "https://" + $vCenter + "/rest/vcenter/"
                $vCenterSessionURL = $vCenterBaseAuthURL + "session"
                $Header = @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($vCenterUser+":"+$vCenterPassword))}
                $Type = "application/json"
                # Authenticating with API
                Try 
                {
                $vCenterSessionResponse = Invoke-RestMethod  -Method POST -Uri $vCenterSessionURL -Headers $Header -ContentType $Type -SkipCertificateCheck
                }
                Catch 
                {
                $_.Exception.ToString()
                $error[0] | Format-List -Force
                }
                # Extracting the session ID from the response
                $vCenterSessionHeader = @{'vmware-api-session-id' = $vCenterSessionResponse.value}
                ###############################################
                # Getting list of VMs
                ###############################################
                $VMListURL = $vCenterBaseURL+"vm"
                Try 
                {
                $VMListJSON = Invoke-RestMethod -Method Get -Uri $VMListURL -TimeoutSec 100 -Headers $vCenterSessionHeader -ContentType $Type -SkipCertificateCheck
                $VMList = $VMListJSON.value
                }
                Catch 
                {
                $_.Exception.ToString()
                $error[0] | Format-List -Force
                }
                ###############################################
                # Getting list of Tags
                ###############################################
                $TagsURL = $vCenterBaseAuthURL+"tagging/tag"
                Try 
                {
                $TagsJSON = Invoke-RestMethod -Method Get -Uri $TagsURL -TimeoutSec 100 -Headers $vCenterSessionHeader -ContentType $Type -SkipCertificateCheck
                $Tags = $TagsJSON.value
                }
                Catch 
                {
                $_.Exception.ToString()
                $error[0] | Format-List -Force
                }
                ###############################################
                # Getting Tags
                ###############################################
                $TagArray = @()
                ForEach ($TagID in $Tags)
                {
                # Replacing : with %3
                $TagIDURL = $TagID -replace ":","%3A"
                # Getting tag info
                $TagInfoURL = $vCenterBaseAuthURL+"tagging/tag/id:"+$TagIDURL
                Try 
                {
                $TagJSON = Invoke-RestMethod -Method Get -Uri $TagInfoURL -TimeoutSec 100 -Headers $vCenterSessionHeader -ContentType $Type -SkipCertificateCheck
                $TagInfo = $TagJSON.value
                }
                Catch 
                {
                $_.Exception.ToString()
                $error[0] | Format-List -Force
                }
                # Getting Tag category name and category ID
                $TagName = $TagInfo.name
                $TagCategoryID = $TagInfo.category_id
                # Getting name of tag category from $TagCategoryArray
                $TagCategoryName = $TagCategoryArray | Where-Object {$_.ID -eq $TagCategoryID} | Select -ExpandProperty Name
                # Adding to table/array
                $TagArrayLine = New-Object PSObject
                $TagArrayLine | Add-Member -MemberType NoteProperty -Name "Name" -Value "$TagName"
                $TagArrayLine | Add-Member -MemberType NoteProperty -Name "ID" -Value "$TagID"
                $TagArrayLine | Add-Member -MemberType NoteProperty -Name "Category" -Value "$TagCategoryName"
                $TagArrayLine | Add-Member -MemberType NoteProperty -Name "CategoryID" -Value "$TagCategoryID"
                $TagArray += $TagArrayLine
                }
            }
		}
	}
  } 
} while ( $userMenuChoice -ne 1 )