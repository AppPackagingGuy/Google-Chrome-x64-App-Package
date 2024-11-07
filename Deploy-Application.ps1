[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall')]
    [String]$DeploymentType = 'Uninstall',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [String]$DeployMode = 'Interactive',
    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $true,
    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false
)

Try {
    ## Set the script execution policy for this process
    Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop'
    }
    Catch {
    }

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
	[String]$appVendor = 'Google'
	[String]$appName = 'Chrome'
	[String]$appVersion = '130.0.6723.117'
	[String]$appBit = 'x64'
	[String]$appLanguage = 'English'
	[String]$appInstaller = 'googlechromestandaloneenterprise64.msi'
	[String]$appTransform = 'googlechromestandaloneenterprise64.mst'
	[String]$releaseNumber = 'R01'
	[String]$buildNumber = 'B01'
	[String]$targetPlatform = 'Win11'
	[String]$processes2Kill = 'chrome'
	[String]$packageAuthor = 'App Packaging Guy'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [String]$installName = ''
    [String]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.9.3'
    [String]$deployAppScriptDate = '02/05/2023'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters
    [String]$appVendorD = $appVendor -replace '\s',''
	[String]$appNameD = $appName -replace '\s',''
	[String]$appVersionD = $appVersion -replace '\s',''
    [String]$installDateD = Get-Date -Format "dd MMM yyyy HH:mm:ss"
    [String]$packageVersion = $appVersionD + ' ' + $releaseNumber + ' ' + $buildNumber
	[String]$detectionRegKey = "HKLM:\SOFTWARE\InstalledSoftwarePackages\$appVendor $appName $appBit"

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [String]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]."
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging
        }
        Else {
            . $moduleAppDeployToolkitMain
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [Int32]$mainExitCode = 60008
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit
        }
        Else {
            Exit $mainExitCode
        }
    }
	
	## Disable baloon messages
	[boolean]$configShowBalloonNotifications = $false

    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ieq 'Install') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, close defined processes if required and persist the prompt (Close Apps Countdown is equal 15 min)
        if($processes2Kill){Show-InstallationWelcome -CloseApps $processes2Kill -CloseAppsCountdown 900 -PersistPrompt}

		## Close GoogleUpdate.exe silently
		Show-InstallationWelcome -CloseApps 'GoogleUpdate' -Silent
		
        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## Remove user installations
		$winUsers = Get-ChildItem "${Env:SystemDrive}\Users"
		foreach ($user in $winUsers){
			## Remove installation folder for all users
			$appFolder2Del = "$($user.fullname)\AppData\Local\$appVendor\$appName\Application"
			$updateFolder2Del = "$($user.fullname)\AppData\Local\$appVendor\Update"
			If (Test-Path $appFolder2Del) {Remove-Folder -Path $appFolder2Del}
			If (Test-Path $updateFolder2Del) {Remove-Folder -Path $updateFolder2Del}	
			
			## Remove shortcuts for all users
			$desktopShortcut = "$($user.fullname)\Desktop\$appVendor $appName.lnk"
			$startMenuShortcut = "$($user.fullname)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$appVendor $appName.lnk"
			$chromeAppsShortcuts = "$($user.fullname)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$appName Apps"
			If (Test-Path $desktopShortcut) {Remove-File -Path $desktopShortcut}
			If (Test-Path $startMenuShortcut) {Remove-File -Path $startMenuShortcut}
			If (Test-Path $chromeAppsShortcuts) {Remove-Folder -Path $chromeAppsShortcuts}			
		}
		
		## Remove system MSI installations
		Remove-MSIApplications -Name "$appVendor $appName"
		Remove-MSIApplications -Name "$appVendor Update Helper"
		Remove-MSIApplications -Name "$appVendor Legacy Browser Support"
		
		## Remove system EXE installations
		If(Test-Path -Path "${Env:ProgramFiles}\$appVendor\$appName\Application\$appName.exe"){
			Write-Log -Message "Found $appVendor $appName installed from .EXE, uninstalling..."
			$chromeSetup = Get-ChildItem "${Env:ProgramFiles}\$appVendor\$appName\Application" -filter setup.exe -Recurse
			Execute-Process -Path $chromeSetup.FullName -Parameters '--uninstall --system-level --force-uninstall' -WindowStyle 'Hidden' -IgnoreExitCodes '*'
		}

		## Remove leftovers
		Remove-Folder -Path "${Env:ProgramFiles}\$appVendor\$appName"
		Remove-Folder -Path "${Env:ProgramFiles(x86)}\$appVendor\$appName"

        ##*===============================================
        ##* INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Installation'
				
		## Install Google Chrome
		Execute-MSI -Action "Install" -Path "$dirSource\$appInstaller" -Transform "$dirSource\$appTransform" -private:"$appVendor $appName $appVersion MSI"

        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Installation'
		
		## Remove Desktop shortcut
		Remove-File -Path "${Env:SystemDrive}\Users\Public\Desktop\Google Chrome.lnk"

    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Uninstallation'

        ## Show Welcome Message, close defined processes if required and persist the prompt (Close Apps Countdown is equal 15 min)
        if($processes2Kill){Show-InstallationWelcome -CloseApps $processes2Kill -CloseAppsCountdown 900 -PersistPrompt}

		## Close GoogleUpdate.exe silently
		Show-InstallationWelcome -CloseApps 'GoogleUpdate' -Silent

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Uninstallation'

        ## Remove Google Chrome
		Remove-MSIApplications -Name "$appVendor $appName"

        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Uninstallation'

		## Uninstall Google Updater if present
		If(Test-Path -Path "${Env:ProgramFiles(x86)}\$appVendor\Update\GoogleUpdate.exe"){
			Execute-Process -Path "${Env:ProgramFiles(x86)}\$appVendor\Update\GoogleUpdate.exe" -Parameters '-Uninstall' -WindowStyle 'Hidden' -IgnoreExitCodes '*' -NoWait
		}Else{Write-Log -Message "$appVendor Updater was not found."}

		## Remove leftovers
		Remove-Folder -Path "${Env:ProgramFiles}\$appVendor\$appName"
		Remove-Folder -Path "${Env:ProgramFiles(x86)}\$appVendor\$appName"
		Remove-Folder -Path "${Env:ProgramFiles(x86)}\$appVendor\$Update"

    }

    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================
	
	## PACKAGE DETECTION KEY
	If ((($mainExitCode -eq 0) -or ($mainExitCode -eq 3010) -or ($mainExitCode -eq 1641)) -and ($deploymentType -eq 'Install'))
	{
		Set-RegistryKey -Key $detectionRegKey -Name "appBit" -Value $appBit
        Set-RegistryKey -Key $detectionRegKey -Name "appName" -Value $appName
        Set-RegistryKey -Key $detectionRegKey -Name "appVendor" -Value $appVendor
        Set-RegistryKey -Key $detectionRegKey -Name "appVersion" -Value $appVersion
        Set-RegistryKey -Key $detectionRegKey -Name "packageVersion" -Value $packageVersion
        Set-RegistryKey -Key $detectionRegKey -Name "installDate" -Value $installDateD
	}
	elseif ((($mainExitCode -eq 0) -or ($mainExitCode -eq 3010) -or ($mainExitCode -eq 1641)) -and ($deploymentType -eq 'Uninstall'))
	{
		$getPackageVersion = Get-RegistryKey -Key $detectionRegKey -Value 'packageVersion'
        if($getPackageVersion -eq $packageVersion){Remove-RegistryKey -Key $detectionRegKey}
	}
    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [Int32]$mainExitCode = 60001
    [String]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}