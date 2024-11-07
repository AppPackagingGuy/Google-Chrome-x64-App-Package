<#
.SYNOPSIS
	This script is a template that allows you to extend the toolkit with your own custom functions.
    # LICENSE #
    PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows.
    Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
    This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
    You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is automatically dot-sourced by the AppDeployToolkitMain.ps1 script.
.NOTES
    Toolkit Exit Code Ranges:
    60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
    69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
    70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK
	https://www.powershellgallery.com/
#>
[CmdletBinding()]
Param (
)

##*===============================================
##* VARIABLE DECLARATION
##*===============================================

# Variables: Script
[string]$appDeployToolkitExtName = 'PSAppDeployToolkitExt'
[string]$appDeployExtScriptFriendlyName = 'App Deploy Toolkit Extensions'
[version]$appDeployExtScriptVersion = [version]'3.8.4'
[string]$appDeployExtScriptDate = '26/01/2021'
[hashtable]$appDeployExtScriptParameters = $PSBoundParameters

##*===============================================
##* FUNCTION LISTINGS
##*===============================================

#region Function Set-ARPSettings
Function Set-ARPSettings {
<#
.SYNOPSIS
	Add properties for the "Programs and Features" entries.
.DESCRIPTION
	Add ARPNOMODIFY=1,ARPNOREMOVE=1,APRNOREOAIR=1 to registry key accordig to provided guid and remove URLInfoAbout, URLUpdateInfo, HelpLink, HelpTelephone, Readme, Comments.
.PARAMETER Guid
	Application GUID for which the properties should be set.
.EXAMPLE
	Set-ARPSettings -Guid "{196467F1-C11F-4F76-858B-5812ADC83B94}"
.EXAMPLE
	Set-ARPSettings -Guid "FileZilla Client"
.NOTES
	AtoS Custom fucntion
.LINK
	https://www.powershellgallery.com/
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Guid
	)

	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
			If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid") {
				Write-Log -Message "Registry key is present: [HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid]." -Source ${CmdletName}
				Write-Log -Message "Adding x64 registry properties." -Source ${CmdletName}
				Set-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoRemove" -Type "Dword" -Value "1"
				Set-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoModify" -Type "Dword" -Value "1"
				Set-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoRepair" -Type "Dword" -Value "1"
                Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "URLInfoAbout"
                Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "URLUpdateInfo"
                Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "HelpLink"
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "Readme"
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "Comments"
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "HelpTelephone"
			}
			ElseIf (Test-Path -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid") {
				Write-Log -Message "Registry key is present: [HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid]." -Source ${CmdletName}
				Write-Log -Message "Adding x86 registry properties." -Source ${CmdletName}
				Set-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoRemove" -Type "Dword" -Value "1"
				Set-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoModify" -Type "Dword" -Value "1"
				Set-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoRepair" -Type "Dword" -Value "1"
                Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "URLInfoAbout"
                Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "URLUpdateInfo"
                Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "HelpLink"
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "Readme"
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "Comments"
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "HelpTelephone"
			}
			Else {Write-Log -Message "$Guid has not been found." -Source ${CmdletName}}

	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}
#endregion

#region Function Del-ARPSettings
Function Del-ARPSettings {
<#
.SYNOPSIS
	Deleting properties from the "Programs and Features" entries.
.DESCRIPTION
	Deleting ARPNOMODIFY=1,ARPNOREMOVE=1,APRNOREOAIR=1 from registry key accordig to provided guid.
.PARAMETER Guid
	Application GUID for which the properties should be deleted.
.EXAMPLE
	Del-ARPSettings -Guid "{196467F1-C11F-4F76-858B-5812ADC83B94}"
.EXAMPLE
	Del-ARPSettings -Guid "FileZilla Client"
.NOTES
	AtoS Custom fucntion
.LINK
	https://www.powershellgallery.com/
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Guid
	)

	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
			If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid") {
				Write-Log -Message "Registry key is present: [HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid]." -Source ${CmdletName}
				Write-Log -Message "Removing x64 registry properties." -Source ${CmdletName}
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoRemove" 
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoModify"
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoRepair" 
			}
			ElseIf (Test-Path -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid") {
				Write-Log -Message "Registry key is present: [HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid]." -Source ${CmdletName}
				Write-Log -Message "Removing x86 registry properties." -Source ${CmdletName}
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoRemove" 
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoModify"
				Remove-RegistryKey -Key "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$Guid" -Name "NoRepair"
			}
			Else {Write-Log -Message "$Guid has not been found." -Source ${CmdletName}}

	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}
#endregion

##*===============================================
##* END FUNCTION LISTINGS
##*===============================================

##*===============================================
##* SCRIPT BODY
##*===============================================

If ($scriptParentPath) {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] dot-source invoked by [$(((Get-Variable -Name MyInvocation).Value).ScriptName)]" -Source $appDeployToolkitExtName
} Else {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] invoked directly" -Source $appDeployToolkitExtName
}

##*===============================================
##* END SCRIPT BODY
##*===============================================
